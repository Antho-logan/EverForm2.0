"use strict";
/**
 * Coach Routes
 * AI-powered coaching endpoints including chat, daily summaries, and weekly reports.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const aiService_1 = require("../services/aiService");
const coachAgent_1 = require("../services/coachAgent");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const messageSchema = zod_1.z.object({
    message: zod_1.z.string().min(1),
    context: zod_1.z.record(zod_1.z.any()).optional()
});
const FALLBACK_MESSAGE = `I'm having trouble reaching the AI coach right now, but here's a basic suggestion: focus on simple habits today – walk 10 minutes, drink extra water, and sleep on time. Try again in a moment!`;
// ─────────────────────────────────────────────────────────────────────────────
// Chat Endpoint
// ─────────────────────────────────────────────────────────────────────────────
/**
 * POST /api/v1/coach/message
 * Chat with the AI coach
 */
router.post('/message', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parseResult = messageSchema.safeParse(req.body);
        if (!parseResult.success) {
            return res.status(400).json({ error: 'Invalid payload', issues: parseResult.error.issues });
        }
        const { message, context: clientContext } = parseResult.data;
        let profile = null;
        let recentMeals = [];
        try {
            const { data: profileData } = await supabaseClient_1.supabase
                .from('profiles')
                .select('*')
                .eq('user_id', userId)
                .maybeSingle();
            profile = profileData;
        }
        catch (dbErr) {
            console.error('[coach] Failed to fetch profile:', dbErr);
        }
        try {
            const { data: mealsData } = await supabaseClient_1.supabase
                .from('nutrition_meals')
                .select('*')
                .eq('user_id', userId)
                .order('logged_at', { ascending: false })
                .limit(3);
            recentMeals = mealsData ?? [];
        }
        catch (dbErr) {
            console.error('[coach] Failed to fetch meals:', dbErr);
        }
        const fullContext = {
            ...clientContext,
            profile,
            recentMeals: recentMeals.length > 0 ? recentMeals : undefined
        };
        try {
            const reply = await (0, aiService_1.generateCoachReply)(message, fullContext);
            return res.json({ reply, status: 'ok' });
        }
        catch (aiErr) {
            console.error('[coach] AI service error:', aiErr);
            return res.json({ reply: FALLBACK_MESSAGE, status: 'fallback' });
        }
    }
    catch (err) {
        console.error('[coach] Unexpected error:', err);
        return res.json({ reply: FALLBACK_MESSAGE, status: 'fallback' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Daily Summary Endpoints
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/coach/daily
 * Returns daily summary for a specific date
 */
router.get('/daily', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = req.query.date || new Date().toISOString().slice(0, 10);
        const { data, error } = await supabaseClient_1.supabase
            .from('daily_summaries')
            .select('*')
            .eq('user_id', userId)
            .eq('date', date)
            .maybeSingle();
        if (error) {
            console.error('[coach] Failed to fetch daily summary:', error.message);
            return res.json({ summary: null, status: 'fallback' });
        }
        return res.json({ summary: data, date, status: 'ok' });
    }
    catch (err) {
        console.error('[coach] Unexpected error:', err);
        return res.json({ summary: null, date: new Date().toISOString().slice(0, 10), status: 'fallback' });
    }
});
/**
 * POST /api/v1/coach/daily/generate
 * Manually triggers daily summary generation
 */
router.post('/daily/generate', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = req.body.date || new Date().toISOString().slice(0, 10);
        const summaryData = await (0, coachAgent_1.runDailySummary)(userId, date);
        return res.json({ summary: summaryData, date, status: 'ok' });
    }
    catch (err) {
        console.error('[coach] Error generating daily summary:', err);
        return res.status(500).json({ message: 'Failed to generate daily summary' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Weekly Report Endpoints
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/coach/weekly
 * Returns the latest weekly report
 */
router.get('/weekly', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('weekly_reports')
            .select('*')
            .eq('user_id', userId)
            .order('week_start_date', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (error) {
            console.error('[coach] Failed to fetch weekly report:', error.message);
            return res.json({ report: null, status: 'fallback' });
        }
        return res.json({ report: data, status: 'ok' });
    }
    catch (err) {
        console.error('[coach] Unexpected error:', err);
        return res.json({ report: null, status: 'fallback' });
    }
});
/**
 * POST /api/v1/coach/weekly/generate
 * Manually triggers weekly report generation
 */
router.post('/weekly/generate', async (req, res) => {
    try {
        const userId = req.user?.id;
        // Calculate week range (last 7 days ending today)
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 6);
        const weekStart = startDate.toISOString().slice(0, 10);
        const weekEnd = endDate.toISOString().slice(0, 10);
        const reportData = await (0, coachAgent_1.runWeeklyReport)(userId, weekStart, weekEnd);
        return res.json({ report: reportData, weekStart, weekEnd, status: 'ok' });
    }
    catch (err) {
        console.error('[coach] Error generating weekly report:', err);
        return res.status(500).json({ message: 'Failed to generate weekly report' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Coach Messages History
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/coach/messages
 * Returns recent coach messages (tips, feedback, etc.)
 */
router.get('/messages', async (req, res) => {
    try {
        const userId = req.user?.id;
        const limit = parseInt(req.query.limit) || 10;
        const type = req.query.type;
        let query = supabaseClient_1.supabase
            .from('coach_messages')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(limit);
        if (type) {
            query = query.eq('type', type);
        }
        const { data, error } = await query;
        if (error) {
            console.error('[coach] Failed to fetch messages:', error.message);
            return res.json({ messages: [], status: 'fallback' });
        }
        return res.json({ messages: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[coach] Unexpected error:', err);
        return res.json({ messages: [], status: 'fallback' });
    }
});
exports.default = router;
//# sourceMappingURL=coach.js.map