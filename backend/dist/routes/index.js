"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
// Aggregates all API routers under /api/v1.
const express_1 = require("express");
const profile_1 = __importDefault(require("./profile"));
const training_1 = __importDefault(require("./training"));
const nutrition_1 = __importDefault(require("./nutrition"));
const recovery_1 = __importDefault(require("./recovery"));
const mobility_1 = __importDefault(require("./mobility"));
const fixPain_1 = __importDefault(require("./fixPain"));
const breathwork_1 = __importDefault(require("./breathwork"));
const lookMax_1 = __importDefault(require("./lookMax"));
const ai_1 = __importDefault(require("./ai"));
const scan_1 = __importDefault(require("./scan"));
const coach_1 = __importDefault(require("./coach"));
const router = (0, express_1.Router)();
router.use('/profile', profile_1.default);
router.use('/training', training_1.default);
router.use('/nutrition', nutrition_1.default);
router.use('/recovery', recovery_1.default);
router.use('/mobility', mobility_1.default);
router.use('/fix-pain', fixPain_1.default);
router.use('/breathwork', breathwork_1.default);
router.use('/lookmax', lookMax_1.default);
router.use('/ai', ai_1.default);
router.use('/scan', scan_1.default);
router.use('/coach', coach_1.default);
exports.default = router;
//# sourceMappingURL=index.js.map