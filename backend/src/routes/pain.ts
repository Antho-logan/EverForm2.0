/**
 * FixPain AI Routes
 * 
 * Curl (dev):
 * # Complete a pain assessment (example: right shoulder, acute, sharp pain)
 * curl -X POST http://localhost:4000/api/v1/pain/assessment/complete \
 *   -H "Content-Type: application/json" \
 *   -d '{
 *     "bodyRegion": "shoulder",
 *     "side": "right",
 *     "painDuration": "acute",
 *     "painIntensity": 7,
 *     "painCharacter": ["sharp","clicking"],
 *     "aggravatingFactors": ["overhead lifting","sleeping on side"],
 *     "relievingFactors": ["rest","heat"],
 *     "activityContext": ["gym","desk_work"],
 *     "redFlags": [],
 *     "functionalLimitations": ["overhead reach","pressing"],
 *     "notes": "Started after heavy overhead presses last week",
 *     "photoUrl": null
 *   }'
 * 
 * # Get latest AI plan
 * curl -X GET http://localhost:4000/api/v1/pain/assessment/latest
 */

import { Router } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../types';
import { createPainAssessment, getLatestPainAssessment } from '../services/painAssessmentService';
import { analyzePainPhoto } from '../services/painPhotoService';
import { generatePainPlan } from '../services/painAiService';

const router = Router();

const stringArray = z.array(z.string().min(1)).optional().default([]);

const painBodyRegions = [
  'neck',
  'upper_back',
  'lower_back',
  'shoulder',
  'hip',
  'knee',
  'ankle',
  'elbow',
  'wrist',
  'hand',
  'foot',
] as const;

const painSides = ['left', 'right', 'both', 'center', 'unspecified'] as const;

const painDurations = ['acute', 'subacute', 'chronic', 'sudden', 'unknown'] as const;

export const painAssessmentInputSchema = z.object({
  bodyRegion: z.enum(painBodyRegions),
  side: z.enum(painSides),
  painDuration: z.enum(painDurations),
  painIntensity: z.number().int().min(0).max(10),
  painCharacter: stringArray,
  aggravatingFactors: stringArray,
  relievingFactors: stringArray,
  activityContext: stringArray,
  redFlags: stringArray,
  functionalLimitations: stringArray,
  notes: z.string().optional(),
  photoUrl: z
    .string()
    .url()
    .optional()
    .or(z.literal('').transform(() => undefined))
    .nullable(),
});

router.post('/assessment/complete', async (req: AuthenticatedRequest, res) => {
  try {
    console.log('[Pain] POST /assessment/complete', {
      bodyRegion: (req.body as any)?.bodyRegion,
      side: (req.body as any)?.side,
      painIntensity: (req.body as any)?.painIntensity,
    });

    const userId = req.user?.id as string;
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const parsed = painAssessmentInputSchema.parse(req.body ?? {});
    const assessment = await createPainAssessment(userId, {
      ...parsed,
      photoUrl: parsed.photoUrl ?? undefined,
    });
    const photoFindings = await analyzePainPhoto(parsed.photoUrl ?? undefined);
    const aiPlan = await generatePainPlan(userId, assessment, photoFindings);

    return res.status(201).json(aiPlan);
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ error: 'validation_failed', issues: err.issues });
    }
    console.error('[Pain] error generating plan', err);
    return res.status(500).json({
      error: 'pain_plan_generation_failed',
      message: 'Failed to generate pain plan',
    });
  }
});

router.get('/assessment/latest', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    if (!userId) return res.status(401).json({ error: 'unauthorized' });

    const latest = await getLatestPainAssessment(userId);
    if (!latest) {
      return res.status(404).json({ error: 'not_found' });
    }

    if (!latest.aiSummaryJson) {
      const photoFindings = await analyzePainPhoto(latest.photoUrl ?? undefined);
      const plan = await generatePainPlan(userId, latest, photoFindings);
      return res.json(plan);
    }

    return res.json(latest.aiSummaryJson);
  } catch (err) {
    console.error('[pain] Error fetching latest pain assessment', err);
    return res.status(500).json({ error: 'failed_to_fetch_assessment' });
  }
});

export default router;

