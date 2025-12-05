-- ============================================================================
-- Migration: Add training_profiles table for Smart Training Engine
-- ============================================================================
-- This table stores per-user training preferences used by the Smart Training
-- engine to generate personalized workout plans and recommendations.
--
-- NOTE: There is some overlap with existing tables:
--   - profiles.training_experience (beginner/intermediate/advanced/elite)
--   - goals.primary_goal, goals.equipment_access, goals.preferred_training_days
-- For now, this table stands alone. A future migration may reconcile or
-- sync these fields. See TODO comments in trainingProfileService.ts.
-- ============================================================================

-- Create training_profiles table (one row per user)
create table if not exists training_profiles (
    user_id uuid primary key references auth.users(id) on delete cascade,
    goal text not null check (goal in ('muscle_gain', 'fat_loss', 'performance', 'health', 'general_fitness')) default 'general_fitness',
    days_per_week integer not null check (days_per_week between 0 and 14) default 3,
    experience_level text not null check (experience_level in ('beginner', 'intermediate', 'advanced')) default 'beginner',
    equipment_access text not null check (equipment_access in ('full_gym', 'limited_home', 'bodyweight_only')) default 'full_gym',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Index on user_id (for consistency with other tables, even though it's the PK)
create index if not exists idx_training_profiles_user_id on training_profiles(user_id);

-- Enable Row Level Security
alter table training_profiles enable row level security;

-- RLS Policies: user can only access their own row
create policy "training_profiles_select" on training_profiles 
    for select using (auth.uid() = user_id);

create policy "training_profiles_insert" on training_profiles 
    for insert with check (auth.uid() = user_id);

create policy "training_profiles_update" on training_profiles 
    for update using (auth.uid() = user_id);

