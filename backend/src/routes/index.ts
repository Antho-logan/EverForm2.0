// Aggregates all API routers under /api/v1.
import { Router } from 'express';
import profileRouter from './profile';
import trainingRouter from './training';
import nutritionRouter from './nutrition';
import recoveryRouter from './recovery';
import mobilityRouter from './mobility';
import fixPainRouter from './fixPain';
import breathworkRouter from './breathwork';
import lookMaxRouter from './lookMax';
import aiRouter from './ai';
import scanRouter from './scan';
import coachRouter from './coach';

const router = Router();

router.use('/profile', profileRouter);
router.use('/training', trainingRouter);
router.use('/nutrition', nutritionRouter);
router.use('/recovery', recoveryRouter);
router.use('/mobility', mobilityRouter);
router.use('/fix-pain', fixPainRouter);
router.use('/breathwork', breathworkRouter);
router.use('/lookmax', lookMaxRouter);
router.use('/ai', aiRouter);
router.use('/scan', scanRouter);
router.use('/coach', coachRouter);

export default router;
