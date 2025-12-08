"use strict";
/**
 * Scan routes: image analysis for food/nutrition.
 *
 * ENDPOINTS:
 * - POST /api/v1/scan/analyze      - Analyze image (base64 in JSON body)
 * - POST /api/v1/scan/meal         - Analyze and log meal
 * - POST /api/v1/scan/plate-image  - Plate AI analysis (multipart file upload)
 *
 * FALLBACK: If vision API fails, returns mock analysis results
 * so the iOS app can still function during development.
 *
 * ─────────────────────────────────────────────────────────────────────────────
 * MANUAL TEST (plate-image endpoint):
 *
 *   # Start backend
 *   cd backend
 *   npm run dev
 *
 *   # In another terminal, test with a local image:
 *   curl -X POST "http://localhost:4000/api/v1/scan/plate-image" \
 *     -F "image=@/path/to/local/test-plate.jpg"
 *
 *   # Expected response (mock if SCAN_API_KEY not set):
 *   {
 *     "success": true,
 *     "source": "mock",
 *     "summary": "Grilled chicken with rice and salad.",
 *     "qualityLabel": "B",
 *     "calories": { "estimatedKcal": 620, "confidence": 0.6 },
 *     "macros": { ... },
 *     "warnings": [...],
 *     "suggestions": [...]
 *   }
 * ─────────────────────────────────────────────────────────────────────────────
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const multer_1 = __importDefault(require("multer"));
const scanService_1 = require("../services/scanService");
const plateService_1 = require("../services/plateService");
const db_1 = require("../utils/db");
const router = (0, express_1.Router)();
// ─────────────────────────────────────────────────────────────────────────────
// MULTER SETUP FOR FILE UPLOADS
// ─────────────────────────────────────────────────────────────────────────────
// Store files in memory (we convert to base64)
const upload = (0, multer_1.default)({
    storage: multer_1.default.memoryStorage(),
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB max
        files: 1
    },
    fileFilter: (_req, file, cb) => {
        // Accept only images
        const allowedMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'];
        if (allowedMimes.includes(file.mimetype)) {
            cb(null, true);
        }
        else {
            cb(new Error(`Invalid file type: ${file.mimetype}. Allowed: JPEG, PNG, WebP, HEIC`));
        }
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// SCHEMAS
// ─────────────────────────────────────────────────────────────────────────────
const analyzeSchema = zod_1.z.object({
    mode: zod_1.z.enum(['calories', 'ingredients', 'plate']),
    imageBase64: zod_1.z.string().min(1)
});
// ─────────────────────────────────────────────────────────────────────────────
// FALLBACK RESULT
// ─────────────────────────────────────────────────────────────────────────────
const FALLBACK_RESULT = {
    mode: 'calories',
    calories: 500,
    protein: 25,
    carbs: 50,
    fat: 20,
    confidence: 0.5,
    description: 'Unable to analyze image - showing estimated values',
    notes: 'Vision API unavailable. These are placeholder values.'
};
// ─────────────────────────────────────────────────────────────────────────────
// ROUTES
// ─────────────────────────────────────────────────────────────────────────────
/**
 * POST /api/v1/scan/plate-image
 *
 * Accepts multipart/form-data with an image file.
 * Returns structured Plate AI analysis with macros, quality rating, etc.
 */
router.post('/plate-image', upload.single('image'), async (req, res) => {
    const debugId = `req-${Date.now()}`;
    console.log(`[scan] ${debugId} - Plate image endpoint called`);
    try {
        // Check if file was uploaded
        if (!req.file) {
            console.log(`[scan] ${debugId} - No image file in request`);
            return res.status(400).json({
                success: false,
                error: 'No image file uploaded',
                debugId
            });
        }
        const { buffer, mimetype, size } = req.file;
        console.log(`[scan] ${debugId} - Received image: ${mimetype}, ${Math.round(size / 1024)}KB`);
        // Convert buffer to base64
        const imageBase64 = buffer.toString('base64');
        // Call the plate analysis service
        const result = await (0, plateService_1.analyzePlateImage)(imageBase64, mimetype);
        if (result.success) {
            return res.json(result);
        }
        else {
            // Error result - return 500
            return res.status(500).json(result);
        }
    }
    catch (err) {
        console.error(`[scan] ${debugId} - Unexpected error:`, err.message);
        return res.status(500).json({
            success: false,
            error: err.message || 'Internal server error',
            debugId
        });
    }
});
/**
 * POST /api/v1/scan/analyze
 *
 * Accepts JSON body with base64-encoded image.
 * Legacy endpoint for backwards compatibility.
 */
router.post('/analyze', async (req, res) => {
    try {
        const parseResult = analyzeSchema.safeParse(req.body);
        if (!parseResult.success) {
            return res.status(400).json({
                error: 'Invalid payload: mode (calories|ingredients|plate) and imageBase64 required',
                issues: parseResult.error.issues
            });
        }
        try {
            const result = await (0, scanService_1.analyzeImage)(parseResult.data);
            return res.json({ ...result, status: 'ok' });
        }
        catch (analysisErr) {
            console.error('[scan] Analysis error:', analysisErr);
            // Return fallback instead of 500
            return res.json({
                ...FALLBACK_RESULT,
                mode: parseResult.data.mode,
                status: 'fallback'
            });
        }
    }
    catch (err) {
        console.error('[scan] Unexpected error in analyze:', err);
        return res.json({ ...FALLBACK_RESULT, status: 'fallback' });
    }
});
/**
 * POST /api/v1/scan/meal
 *
 * Analyzes image and logs the result as a meal in the database.
 */
router.post('/meal', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parseResult = analyzeSchema.safeParse(req.body);
        if (!parseResult.success) {
            return res.status(400).json({
                error: 'Invalid payload',
                issues: parseResult.error.issues
            });
        }
        // Analyze image - fallback to mock if vision fails (this is fine)
        let result;
        try {
            result = await (0, scanService_1.analyzeImage)(parseResult.data);
        }
        catch (analysisErr) {
            console.error('[scan] Analysis error in meal:', analysisErr);
            result = { ...FALLBACK_RESULT, mode: parseResult.data.mode };
        }
        // Save to database using scoped helper
        const { data, error } = await (0, db_1.userInsert)('nutrition_meals', userId, {
            meal_type: 'scan',
            title: result.description ?? 'Scanned meal',
            kcal: result.calories ?? result.caloriesEstimate ?? null,
            protein_g: result.protein ?? null,
            carbs_g: result.carbs ?? null,
            fat_g: result.fat ?? null,
            logged_at: new Date().toISOString(),
            source: 'scan'
        }).select().single();
        if (error) {
            console.error('[scan] Failed to store scanned meal:', error.message);
            return res.status(500).json({
                message: 'Failed to save meal',
                error: error.message,
                analysis: result // Still return analysis so user sees what was detected
            });
        }
        return res.json({ meal: data, analysis: result, status: 'ok' });
    }
    catch (err) {
        console.error('[scan] Unexpected error in meal:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// ERROR HANDLER FOR MULTER
// ─────────────────────────────────────────────────────────────────────────────
router.use((err, req, res, next) => {
    if (err instanceof multer_1.default.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({
                success: false,
                error: 'File too large. Maximum size is 10MB.',
                debugId: `multer-${Date.now()}`
            });
        }
        return res.status(400).json({
            success: false,
            error: `Upload error: ${err.message}`,
            debugId: `multer-${Date.now()}`
        });
    }
    if (err.message?.includes('Invalid file type')) {
        return res.status(400).json({
            success: false,
            error: err.message,
            debugId: `multer-${Date.now()}`
        });
    }
    next(err);
});
exports.default = router;
//# sourceMappingURL=scan.js.map