"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generatePersonalPlan = generatePersonalPlan;
// DeepSeek integration with a mocked fallback to keep the API usable in offline/dev environments.
const axios_1 = __importDefault(require("axios"));
const env_1 = require("../config/env");
const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';
function buildMockPlan(profile, recentData) {
    return {
        trainingPlan: {
            summary: '3x strength / 2x conditioning weekly with progressive overload.',
            nextWeekFocus: 'Compound lifts at RPE 7-8, 2 cardio intervals, 1 mobility finisher.'
        },
        nutritionPlan: {
            kcalTarget: profile?.weight_kg ? Math.round(profile.weight_kg * 32) : 2400,
            proteinTargetG: profile?.weight_kg ? Math.round(profile.weight_kg * 1.8) : 150,
            notes: 'Prioritize whole foods, 30g protein per meal, hydration 3L/day.'
        },
        recoveryPlan: {
            sleep: 'Aim for 7.5-8.5 hours; consistent bedtime; evening wind-down routine.',
            stress: '1x weekly long walk + 2x mindfulness blocks.'
        },
        mobilityPlan: {
            routinesPerWeek: 3,
            focusAreas: recentData.mobilitySessions[0]?.mobility_routines?.target_areas ?? ['hips', 't-spine']
        },
        painPreventionPlan: {
            checks: 'Quick pain scan before each session; stop if severity >6.',
            protocol: 'Light flossing + isometric holds for painful areas after warmup.'
        },
        breathworkPlan: {
            daily: 'Box breathing 5 minutes morning; physiological sighs as needed.',
            preSleep: '4-7-8 breathing 2 sets.'
        },
        lookmaxPlan: {
            weeklyFocus: ['posture drills', 'skin hydration', 'consistent grooming'],
            habits: 'SPF daily, 2L water before noon, evening mobility for posture.'
        }
    };
}
async function generatePersonalPlan(profile, onboardingAnswers, recentData) {
    const systemPrompt = 'You are EverForm, a biohacking and fitness coach. Using the structured JSON user profile, questionnaire answers, and recent activity, generate a 12-week personalized plan that includes training, nutrition, recovery, mobility, pain-prevention, breathwork, and look-maxing guidance. Respond with strict JSON only.';
    const userPayload = {
        profile,
        onboardingAnswers,
        recentData
    };
    try {
        const response = await axios_1.default.post(DEEPSEEK_URL, {
            model: 'deepseek-chat',
            messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: JSON.stringify(userPayload) }
            ],
            response_format: { type: 'json_object' }
        }, {
            headers: {
                Authorization: `Bearer ${env_1.env.DEEPSEEK_API_KEY}`
            },
            timeout: 12000
        });
        const content = response.data?.choices?.[0]?.message?.content;
        if (content) {
            try {
                return JSON.parse(content);
            }
            catch (parseErr) {
                console.warn('DeepSeek response was not valid JSON, using mock plan.');
            }
        }
    }
    catch (err) {
        console.warn('DeepSeek API unavailable, returning mocked plan.');
    }
    return buildMockPlan(profile, recentData);
}
//# sourceMappingURL=aiService.js.map