/**
 * Weekly Report Job
 * 
 * Generates weekly reports for all users.
 * Run with: npx ts-node src/jobs/weeklyReport.ts
 * 
 * In production, wire this to:
 * - Supabase pg_cron
 * - External cron service (Render, Railway, etc.)
 * - GitHub Actions scheduled workflow
 */

import { supabase } from '../config/supabaseClient';
import { runWeeklyReport } from '../services/coachAgent';

async function main() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  Weekly Report Job Started');
  console.log('  ' + new Date().toISOString());
  console.log('═══════════════════════════════════════════════════════════');
  console.log('');

  // Calculate week range (last 7 days ending yesterday)
  const endDate = new Date();
  endDate.setDate(endDate.getDate() - 1); // Yesterday
  const startDate = new Date(endDate);
  startDate.setDate(startDate.getDate() - 6);

  const weekStart = startDate.toISOString().slice(0, 10);
  const weekEnd = endDate.toISOString().slice(0, 10);

  console.log(`  Week range: ${weekStart} to ${weekEnd}`);
  console.log('');

  // Fetch all user IDs from profiles
  const { data: profiles, error } = await supabase
    .from('profiles')
    .select('user_id');

  if (error) {
    console.error('  ✗ Failed to fetch profiles:', error.message);
    process.exit(1);
  }

  if (!profiles || profiles.length === 0) {
    console.log('  No users found. Exiting.');
    process.exit(0);
  }

  console.log(`  Found ${profiles.length} users to process`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const profile of profiles) {
    const userId = profile.user_id;
    
    try {
      console.log(`  Processing user: ${userId.slice(0, 8)}...`);
      
      const report = await runWeeklyReport(userId, weekStart, weekEnd);
      
      console.log(`    ✓ Report generated (overall: ${report.scores.avgOverall}%)`);
      successCount++;
    } catch (err) {
      console.error(`    ✗ Failed:`, err instanceof Error ? err.message : err);
      errorCount++;
    }
  }

  console.log('');
  console.log('═══════════════════════════════════════════════════════════');
  console.log(`  Job Complete`);
  console.log(`  Success: ${successCount}, Errors: ${errorCount}`);
  console.log('═══════════════════════════════════════════════════════════');

  process.exit(errorCount > 0 ? 1 : 0);
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});

