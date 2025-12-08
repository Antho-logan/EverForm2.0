/**
 * API Routes Index
 * Aggregates all API routers under /api/v1
 */

import { Router } from 'express';

// Core feature routes
import profileRouter from './profile';
import goalsRouter from './goals';
import dashboardRouter from './dashboard';

// Training & activity routes
import trainingRouter from './training';
import nutritionRouter from './nutrition';
import recoveryRouter from './recovery';
import sleepRouter from './sleep';
import mobilityRouter from './mobility';
import breathworkRouter from './breathwork';
import painRouter from './pain';

// AI & coach routes
import coachRouter from './coach';
import aiRouter from './ai';

// Specialized feature routes
import fixPainRouter from './fixPain';
import lookMaxRouter from './lookMax';
import scanRouter from './scan';

// Debug routes
import debugRouter from './debug';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Core Routes
// ─────────────────────────────────────────────────────────────────────────────

router.use('/profile', profileRouter);
router.use('/goals', goalsRouter);
router.use('/dashboard', dashboardRouter);

// ─────────────────────────────────────────────────────────────────────────────
// Activity Tracking Routes
// ─────────────────────────────────────────────────────────────────────────────

router.use('/training', trainingRouter);
router.use('/nutrition', nutritionRouter);
router.use('/recovery', recoveryRouter);
router.use('/sleep', sleepRouter);
router.use('/mobility', mobilityRouter);
router.use('/breathwork', breathworkRouter);
router.use('/pain', painRouter);

// ─────────────────────────────────────────────────────────────────────────────
// AI & Coaching Routes
// ─────────────────────────────────────────────────────────────────────────────

router.use('/coach', coachRouter);
router.use('/ai', aiRouter);

// ─────────────────────────────────────────────────────────────────────────────
// Specialized Features
// ─────────────────────────────────────────────────────────────────────────────

router.use('/fix-pain', fixPainRouter);
router.use('/lookmax', lookMaxRouter);
router.use('/scan', scanRouter);

// ─────────────────────────────────────────────────────────────────────────────
// Debug Routes (auth-protected)
// ─────────────────────────────────────────────────────────────────────────────

router.use('/debug', debugRouter);

export default router;
