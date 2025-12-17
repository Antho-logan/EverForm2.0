"use strict";
/**
 * API Routes Index
 * Aggregates all API routers under /api/v1
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
// Core feature routes
const profile_1 = __importDefault(require("./profile"));
const goals_1 = __importDefault(require("./goals"));
const dashboard_1 = __importDefault(require("./dashboard"));
// Training & activity routes
const training_1 = __importDefault(require("./training"));
const nutrition_1 = __importDefault(require("./nutrition"));
const recovery_1 = __importDefault(require("./recovery"));
const sleep_1 = __importDefault(require("./sleep"));
const mobility_1 = __importDefault(require("./mobility"));
const breathwork_1 = __importDefault(require("./breathwork"));
const pain_1 = __importDefault(require("./pain"));
// AI & coach routes
const coach_1 = __importDefault(require("./coach"));
const ai_1 = __importDefault(require("./ai"));
// Specialized feature routes
const fixPain_1 = __importDefault(require("./fixPain"));
const lookMax_1 = __importDefault(require("./lookMax"));
const scan_1 = __importDefault(require("./scan"));
// Debug routes
const debug_1 = __importDefault(require("./debug"));
const router = (0, express_1.Router)();
// ─────────────────────────────────────────────────────────────────────────────
// Core Routes
// ─────────────────────────────────────────────────────────────────────────────
router.use('/profile', profile_1.default);
router.use('/goals', goals_1.default);
router.use('/dashboard', dashboard_1.default);
// ─────────────────────────────────────────────────────────────────────────────
// Activity Tracking Routes
// ─────────────────────────────────────────────────────────────────────────────
router.use('/training', training_1.default);
router.use('/nutrition', nutrition_1.default);
router.use('/recovery', recovery_1.default);
router.use('/sleep', sleep_1.default);
router.use('/mobility', mobility_1.default);
router.use('/breathwork', breathwork_1.default);
router.use('/pain', pain_1.default);
// ─────────────────────────────────────────────────────────────────────────────
// AI & Coaching Routes
// ─────────────────────────────────────────────────────────────────────────────
router.use('/coach', coach_1.default);
router.use('/ai', ai_1.default);
// ─────────────────────────────────────────────────────────────────────────────
// Specialized Features
// ─────────────────────────────────────────────────────────────────────────────
router.use('/fix-pain', fixPain_1.default);
router.use('/lookmax', lookMax_1.default);
router.use('/scan', scan_1.default);
// ─────────────────────────────────────────────────────────────────────────────
// Debug Routes (auth-protected)
// ─────────────────────────────────────────────────────────────────────────────
router.use('/debug', debug_1.default);
exports.default = router;
//# sourceMappingURL=index.js.map