/**
 * Daily Summary Job
 * 
 * Generates end-of-day summaries for all users who logged activity.
 * Run with: npx ts-node src/jobs/dailySummary.ts
 * 
 * Typically run at end of day (e.g., 11 PM in each user's timezone).
 */

import { supabase } from '../config/supabaseClient';
import { runDailySummary } from '../services/coachAgent';

async function main() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  Daily Summary Job Started');
  console.log('  ' + new Date().toISOString());
  console.log('═══════════════════════════════════════════════════════════');
  console.log('');

  // Default to today's date
  const today = new Date().toISOString().slice(0, 10);
  const targetDate = process.argv[2] || today;

  console.log(`  Processing date: ${targetDate}`);
  console.log('');

  // Find users who have logged any activity today
  let activeUsers: any[] | null = null;
  let error: { message: string } | null = null;
  
  try {
    const result = await supabase.rpc('get_active_users_for_date', {
      target_date: targetDate
    });
    activeUsers = result.data;
    error = result.error;
  } catch {
    error = { message: 'RPC not available' };
  }

  // Fallback: get all profiles if RPC doesn't exist
  let userIds: string[] = [];
  
  if (error || !activeUsers) {
    console.log('  Using fallback: fetching all profiles');
    const { data: profiles } = await supabase
      .from('profiles')
      .select('user_id');
    
    userIds = profiles?.map(p => p.user_id) ?? [];
  } else {
    userIds = activeUsers.map((u: any) => u.user_id);
  }

  if (userIds.length === 0) {
    console.log('  No users found. Exiting.');
    process.exit(0);
  }

  console.log(`  Found ${userIds.length} users to process`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const userId of userIds) {
    try {
      console.log(`  Processing user: ${userId.slice(0, 8)}...`);
      
      const summary = await runDailySummary(userId, targetDate);
      
      console.log(`    ✓ Summary generated (overall: ${summary.overallScore}%)`);
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

