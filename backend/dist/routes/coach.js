"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const router = (0, express_1.Router)();
const messageSchema = zod_1.z.object({
    userId: zod_1.z.string(),
    message: zod_1.z.string().min(1),
});
router.post('/message', async (req, res) => {
    const parseResult = messageSchema.safeParse(req.body);
    if (!parseResult.success) {
        return res.status(400).json({ error: 'Invalid payload' });
    }
    const { message } = parseResult.data;
    // Simple echo response for now
    const reply = `Thanks for sharing, here is a first step you can take: ${message}`;
    return res.json({ reply });
});
exports.default = router;
//# sourceMappingURL=coach.js.map