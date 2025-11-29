"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const scanService_1 = require("../services/scanService");
const router = (0, express_1.Router)();
const analyzeSchema = zod_1.z.object({
    mode: zod_1.z.enum(['calories', 'ingredients', 'plate']),
    imageBase64: zod_1.z.string().min(1)
});
router.post('/analyze', async (req, res) => {
    try {
        const parseResult = analyzeSchema.safeParse(req.body);
        if (!parseResult.success) {
            return res.status(400).json({ error: 'Invalid payload: mode (calories|ingredients|plate) and imageBase64 required' });
        }
        const result = await (0, scanService_1.analyzeImage)(parseResult.data);
        return res.json(result);
    }
    catch (err) {
        console.error('Analyze route error:', err);
        return res.status(500).json({ error: 'Internal server error' });
    }
});
exports.default = router;
//# sourceMappingURL=scan.js.map