-- ============================================================================
-- EverForm Complete Schema - AI-Ready Biohacking & Fitness Platform
-- ============================================================================
-- Designed for RAG integration, agent-driven summaries, and comprehensive
-- training/nutrition/recovery tracking.
-- ============================================================================

create extension if not exists "pgcrypto";
create extension if not exists "vector";  -- For future RAG embeddings

-- ============================================================================
-- 1. PROFILES - User demographics and baseline info
-- ============================================================================
create table if not exists profiles (
    user_id uuid primary key references auth.users(id) on delete cascade,
    name text,
    sex text check (sex in ('male', 'female', 'other')),
    dob date,
    height_cm numeric,
    weight_kg numeric,
    activity_level text check (activity_level in ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active')),
    training_experience text check (training_experience in ('beginner', 'intermediate', 'advanced', 'elite')),
    injuries text,
    time_zone text default 'UTC',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

create index if not exists idx_profiles_user_id on profiles(user_id);

alter table profiles enable row level security;
create policy "profiles_select" on profiles for select using (auth.uid() = user_id);
create policy "profiles_insert" on profiles for insert with check (auth.uid() = user_id);
create policy "profiles_update" on profiles for update using (auth.uid() = user_id);

-- ============================================================================
-- 2. GOALS - User fitness/health goals
-- ============================================================================
create table if not exists goals (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    primary_goal text check (primary_goal in ('muscle_gain', 'fat_loss', 'performance', 'health')),
    secondary_goals jsonb default '[]'::jsonb,
    preferred_training_days text[] default array[]::text[],
    session_length_minutes int default 60,
    equipment_access text default 'full_gym',
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    unique(user_id)
);

create index if not exists idx_goals_user_id on goals(user_id);

alter table goals enable row level security;
create policy "goals_select" on goals for select using (auth.uid() = user_id);
create policy "goals_insert" on goals for insert with check (auth.uid() = user_id);
create policy "goals_update" on goals for update using (auth.uid() = user_id);

-- ============================================================================
-- 3. TRAINING_TEMPLATES - Reusable workout program templates
-- ============================================================================
create table if not exists training_templates (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    goal text,
    intensity_style text check (intensity_style in ('rpe', 'percentage', 'rir', 'autoregulated')),
    weeks int default 4,
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now()
);

-- ============================================================================
-- 4. TRAINING_SESSIONS - Planned workout sessions
-- ============================================================================
create table if not exists training_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    template_id uuid references training_templates(id) on delete set null,
    date_planned date not null,
    session_label text,
    created_at timestamptz default now()
);

create index if not exists idx_training_sessions_user_date on training_sessions(user_id, date_planned);

alter table training_sessions enable row level security;
create policy "training_sessions_select" on training_sessions for select using (auth.uid() = user_id);
create policy "training_sessions_insert" on training_sessions for insert with check (auth.uid() = user_id);
create policy "training_sessions_update" on training_sessions for update using (auth.uid() = user_id);

-- ============================================================================
-- 5. TRAINING_EXERCISES - Exercises within a session
-- ============================================================================
create table if not exists training_exercises (
    id uuid primary key default gen_random_uuid(),
    session_id uuid not null references training_sessions(id) on delete cascade,
    exercise_name text not null,
    sets int default 3,
    reps int default 10,
    rest_seconds int default 90,
    intensity_target text,
    order_index int default 0,
    created_at timestamptz default now()
);

create index if not exists idx_training_exercises_session on training_exercises(session_id);

-- RLS inherited through session ownership check
alter table training_exercises enable row level security;
create policy "training_exercises_select" on training_exercises for select 
    using (exists (select 1 from training_sessions ts where ts.id = session_id and ts.user_id = auth.uid()));
create policy "training_exercises_insert" on training_exercises for insert 
    with check (exists (select 1 from training_sessions ts where ts.id = session_id and ts.user_id = auth.uid()));
create policy "training_exercises_update" on training_exercises for update 
    using (exists (select 1 from training_sessions ts where ts.id = session_id and ts.user_id = auth.uid()));

-- ============================================================================
-- 6. TRAINING_LOGS - Completed workout logs
-- ============================================================================
create table if not exists training_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    session_id uuid references training_sessions(id) on delete set null,
    date_performed date not null,
    completed_sets jsonb default '[]'::jsonb,
    perceived_effort int check (perceived_effort >= 1 and perceived_effort <= 10),
    notes text,
    created_at timestamptz default now()
);

create index if not exists idx_training_logs_user_date on training_logs(user_id, date_performed);

alter table training_logs enable row level security;
create policy "training_logs_select" on training_logs for select using (auth.uid() = user_id);
create policy "training_logs_insert" on training_logs for insert with check (auth.uid() = user_id);
create policy "training_logs_update" on training_logs for update using (auth.uid() = user_id);

-- ============================================================================
-- 7. NUTRITION_TARGETS - User macro targets
-- ============================================================================
create table if not exists nutrition_targets (
    user_id uuid primary key references auth.users(id) on delete cascade,
    daily_calories numeric default 2000,
    protein_g numeric default 150,
    carbs_g numeric default 200,
    fat_g numeric default 70,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

alter table nutrition_targets enable row level security;
create policy "nutrition_targets_select" on nutrition_targets for select using (auth.uid() = user_id);
create policy "nutrition_targets_insert" on nutrition_targets for insert with check (auth.uid() = user_id);
create policy "nutrition_targets_update" on nutrition_targets for update using (auth.uid() = user_id);

-- ============================================================================
-- 8. NUTRITION_LOGS - Food/meal logging
-- ============================================================================
create table if not exists nutrition_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date date not null,
    meal_type text check (meal_type in ('breakfast', 'lunch', 'dinner', 'snack', 'pre_workout', 'post_workout')),
    food_name text not null,
    calories numeric default 0,
    protein_g numeric default 0,
    carbs_g numeric default 0,
    fat_g numeric default 0,
    created_at timestamptz default now()
);

create index if not exists idx_nutrition_logs_user_date on nutrition_logs(user_id, date);

alter table nutrition_logs enable row level security;
create policy "nutrition_logs_select" on nutrition_logs for select using (auth.uid() = user_id);
create policy "nutrition_logs_insert" on nutrition_logs for insert with check (auth.uid() = user_id);
create policy "nutrition_logs_update" on nutrition_logs for update using (auth.uid() = user_id);

-- ============================================================================
-- 9. SLEEP_LOGS - Sleep tracking
-- ============================================================================
create table if not exists sleep_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date date not null,
    hours numeric check (hours >= 0 and hours <= 24),
    sleep_score int check (sleep_score >= 0 and sleep_score <= 100),
    notes text,
    created_at timestamptz default now()
);

create index if not exists idx_sleep_logs_user_date on sleep_logs(user_id, date);

alter table sleep_logs enable row level security;
create policy "sleep_logs_select" on sleep_logs for select using (auth.uid() = user_id);
create policy "sleep_logs_insert" on sleep_logs for insert with check (auth.uid() = user_id);
create policy "sleep_logs_update" on sleep_logs for update using (auth.uid() = user_id);

-- ============================================================================
-- 10. RECOVERY_LOGS - Recovery activities (mobility, cold plunge, etc.)
-- ============================================================================
create table if not exists recovery_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date date not null,
    activities text[] default array[]::text[],
    notes text,
    created_at timestamptz default now()
);

create index if not exists idx_recovery_logs_user_date on recovery_logs(user_id, date);

alter table recovery_logs enable row level security;
create policy "recovery_logs_select" on recovery_logs for select using (auth.uid() = user_id);
create policy "recovery_logs_insert" on recovery_logs for insert with check (auth.uid() = user_id);
create policy "recovery_logs_update" on recovery_logs for update using (auth.uid() = user_id);

-- ============================================================================
-- 11. DAILY_SUMMARIES - AI-generated daily rollups
-- ============================================================================
create table if not exists daily_summaries (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date date not null,
    training_score int check (training_score >= 0 and training_score <= 100),
    nutrition_score int check (nutrition_score >= 0 and nutrition_score <= 100),
    recovery_score int check (recovery_score >= 0 and recovery_score <= 100),
    sleep_score int check (sleep_score >= 0 and sleep_score <= 100),
    overall_score int check (overall_score >= 0 and overall_score <= 100),
    summary_text text,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    unique(user_id, date)
);

create index if not exists idx_daily_summaries_user_date on daily_summaries(user_id, date);

alter table daily_summaries enable row level security;
create policy "daily_summaries_select" on daily_summaries for select using (auth.uid() = user_id);
create policy "daily_summaries_insert" on daily_summaries for insert with check (auth.uid() = user_id);
create policy "daily_summaries_update" on daily_summaries for update using (auth.uid() = user_id);

-- ============================================================================
-- 12. WEEKLY_REPORTS - AI-generated weekly analysis
-- ============================================================================
create table if not exists weekly_reports (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    week_start_date date not null,
    week_end_date date not null,
    scores jsonb default '{}'::jsonb,
    focus_points jsonb default '[]'::jsonb,
    wins text,
    risks text,
    created_at timestamptz default now(),
    unique(user_id, week_start_date)
);

create index if not exists idx_weekly_reports_user_week on weekly_reports(user_id, week_start_date);

alter table weekly_reports enable row level security;
create policy "weekly_reports_select" on weekly_reports for select using (auth.uid() = user_id);
create policy "weekly_reports_insert" on weekly_reports for insert with check (auth.uid() = user_id);
create policy "weekly_reports_update" on weekly_reports for update using (auth.uid() = user_id);

-- ============================================================================
-- 13. COACH_MESSAGES - AI coach communications
-- ============================================================================
create table if not exists coach_messages (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamptz default now(),
    type text check (type in ('daily_tip', 'weekly_report', 'recovery_feedback', 'generic', 'goal_update')),
    content text not null
);

create index if not exists idx_coach_messages_user_created on coach_messages(user_id, created_at desc);

alter table coach_messages enable row level security;
create policy "coach_messages_select" on coach_messages for select using (auth.uid() = user_id);
create policy "coach_messages_insert" on coach_messages for insert with check (auth.uid() = user_id);

-- ============================================================================
-- 14. KNOWLEDGE_DOCUMENTS - RAG knowledge base documents
-- ============================================================================
create table if not exists knowledge_documents (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    category text,
    content text not null,
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

create index if not exists idx_knowledge_documents_category on knowledge_documents(category);

-- ============================================================================
-- 15. KNOWLEDGE_EMBEDDINGS - Vector embeddings for RAG retrieval
-- ============================================================================
create table if not exists knowledge_embeddings (
    id uuid primary key default gen_random_uuid(),
    document_id uuid not null references knowledge_documents(id) on delete cascade,
    embedding vector(1536),  -- OpenAI ada-002 dimension; adjust for other models
    chunk_index int default 0,
    chunk_text text,
    created_at timestamptz default now()
);

create index if not exists idx_knowledge_embeddings_document on knowledge_embeddings(document_id);
-- For vector similarity search (requires pgvector)
-- create index if not exists idx_knowledge_embeddings_vector on knowledge_embeddings using ivfflat (embedding vector_cosine_ops) with (lists = 100);

-- ============================================================================
-- LEGACY COMPATIBILITY TABLES (from previous schema)
-- Keep these for backward compatibility with existing app features
-- ============================================================================

-- Onboarding questionnaire answers
create table if not exists onboarding_answers (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    question_key text not null,
    answer_text text,
    answer_numeric numeric,
    metadata jsonb,
    created_at timestamptz default now()
);
create unique index if not exists idx_onboarding_user_question on onboarding_answers(user_id, question_key);

alter table onboarding_answers enable row level security;
create policy "onboarding_select" on onboarding_answers for select using (auth.uid() = user_id);
create policy "onboarding_insert" on onboarding_answers for insert with check (auth.uid() = user_id);
create policy "onboarding_update" on onboarding_answers for update using (auth.uid() = user_id);

-- Meals (legacy nutrition - keep for backward compat)
create table if not exists nutrition_meals (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    meal_type text not null,
    title text not null,
    kcal int,
    protein_g numeric,
    carbs_g numeric,
    fat_g numeric,
    logged_at timestamptz not null,
    source text,
    created_at timestamptz default now()
);
create index if not exists idx_nutrition_meals_user_logged on nutrition_meals(user_id, logged_at);

alter table nutrition_meals enable row level security;
create policy "nutrition_meals_select" on nutrition_meals for select using (auth.uid() = user_id);
create policy "nutrition_meals_insert" on nutrition_meals for insert with check (auth.uid() = user_id);
create policy "nutrition_meals_update" on nutrition_meals for update using (auth.uid() = user_id);

-- Mobility routines
create table if not exists mobility_routines (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    target_areas text[],
    duration_minutes int,
    routine_json jsonb,
    created_at timestamptz default now()
);

alter table mobility_routines enable row level security;
create policy "mobility_routines_select" on mobility_routines for select using (auth.uid() = user_id);
create policy "mobility_routines_insert" on mobility_routines for insert with check (auth.uid() = user_id);
create policy "mobility_routines_update" on mobility_routines for update using (auth.uid() = user_id);

-- Mobility sessions
create table if not exists mobility_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    routine_id uuid references mobility_routines(id) on delete set null,
    status text not null,
    performed_at timestamptz,
    created_at timestamptz default now()
);

alter table mobility_sessions enable row level security;
create policy "mobility_sessions_select" on mobility_sessions for select using (auth.uid() = user_id);
create policy "mobility_sessions_insert" on mobility_sessions for insert with check (auth.uid() = user_id);
create policy "mobility_sessions_update" on mobility_sessions for update using (auth.uid() = user_id);

-- Pain checks
create table if not exists pain_checks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    area text not null,
    severity int,
    description text,
    recommendation_json jsonb,
    created_at timestamptz default now()
);

alter table pain_checks enable row level security;
create policy "pain_checks_select" on pain_checks for select using (auth.uid() = user_id);
create policy "pain_checks_insert" on pain_checks for insert with check (auth.uid() = user_id);
create policy "pain_checks_update" on pain_checks for update using (auth.uid() = user_id);

-- Breathwork sessions
create table if not exists breathwork_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    technique text not null,
    duration_minutes int,
    completed_at timestamptz,
    created_at timestamptz default now()
);

alter table breathwork_sessions enable row level security;
create policy "breathwork_sessions_select" on breathwork_sessions for select using (auth.uid() = user_id);
create policy "breathwork_sessions_insert" on breathwork_sessions for insert with check (auth.uid() = user_id);
create policy "breathwork_sessions_update" on breathwork_sessions for update using (auth.uid() = user_id);

-- Lookmax sessions
create table if not exists lookmax_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    category text not null,
    plan_json jsonb,
    notes text,
    created_at timestamptz default now()
);

alter table lookmax_sessions enable row level security;
create policy "lookmax_sessions_select" on lookmax_sessions for select using (auth.uid() = user_id);
create policy "lookmax_sessions_insert" on lookmax_sessions for insert with check (auth.uid() = user_id);
create policy "lookmax_sessions_update" on lookmax_sessions for update using (auth.uid() = user_id);

-- AI-generated plans
create table if not exists ai_plans (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    type text not null,
    plan_json jsonb,
    created_at timestamptz default now()
);

alter table ai_plans enable row level security;
create policy "ai_plans_select" on ai_plans for select using (auth.uid() = user_id);
create policy "ai_plans_insert" on ai_plans for insert with check (auth.uid() = user_id);
create policy "ai_plans_update" on ai_plans for update using (auth.uid() = user_id);

-- ============================================================================
-- TRAINING_PROFILES - Per-user training preferences for Smart Training Engine
-- ============================================================================
-- NOTE: There is some overlap with existing tables:
--   - profiles.training_experience (beginner/intermediate/advanced/elite)
--   - goals.primary_goal, goals.equipment_access, goals.preferred_training_days
-- For now, this table stands alone. A future migration may reconcile these.
-- ============================================================================
create table if not exists training_profiles (
    user_id uuid primary key references auth.users(id) on delete cascade,
    goal text not null check (goal in ('muscle_gain', 'fat_loss', 'performance', 'health', 'general_fitness')) default 'general_fitness',
    days_per_week integer not null check (days_per_week between 0 and 14) default 3,
    experience_level text not null check (experience_level in ('beginner', 'intermediate', 'advanced')) default 'beginner',
    equipment_access text not null check (equipment_access in ('full_gym', 'limited_home', 'bodyweight_only')) default 'full_gym',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_training_profiles_user_id on training_profiles(user_id);

alter table training_profiles enable row level security;
create policy "training_profiles_select" on training_profiles for select using (auth.uid() = user_id);
create policy "training_profiles_insert" on training_profiles for insert with check (auth.uid() = user_id);
create policy "training_profiles_update" on training_profiles for update using (auth.uid() = user_id);

-- ============================================================================
-- HELPER FUNCTION: Get current date in user's timezone
-- ============================================================================
create or replace function get_user_date(p_user_id uuid)
returns date as $$
declare
    v_tz text;
begin
    select coalesce(time_zone, 'UTC') into v_tz from profiles where user_id = p_user_id;
    return (now() at time zone coalesce(v_tz, 'UTC'))::date;
end;
$$ language plpgsql stable;
