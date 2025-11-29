-- Schema for EverForm backend (Supabase/Postgres)
-- Enables RLS-backed tables for user-owned data across training, nutrition, recovery, and supporting pillars.

create extension if not exists "pgcrypto";

-- User profile and baseline demographics.
create table if not exists profiles (
    id uuid primary key default gen_random_uuid(),
    user_id uuid unique not null references auth.users(id),
    full_name text,
    email text,
    date_of_birth date,
    gender text,
    height_cm integer,
    weight_kg numeric,
    activity_level text,
    primary_goal text,
    created_at timestamptz default now()
);

alter table profiles enable row level security;
create policy "Users can read own rows" on profiles for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on profiles for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on profiles for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Onboarding questionnaire answers (flexible key/value + metadata).
create table if not exists onboarding_answers (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    question_key text not null,
    answer_text text,
    answer_numeric numeric,
    metadata jsonb,
    created_at timestamptz default now()
);
create unique index if not exists onboarding_answers_user_question_idx on onboarding_answers (user_id, question_key);

alter table onboarding_answers enable row level security;
create policy "Users can read own rows" on onboarding_answers for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on onboarding_answers for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on onboarding_answers for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- AI-generated or manually curated workout plans.
create table if not exists workout_plans (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    name text not null,
    goal text,
    weeks integer,
    plan_json jsonb,
    created_at timestamptz default now()
);

alter table workout_plans enable row level security;
create policy "Users can read own rows" on workout_plans for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on workout_plans for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on workout_plans for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Individual workout sessions (linked to plans when applicable).
create table if not exists workout_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    plan_id uuid references workout_plans(id),
    title text not null,
    status text not null,
    duration_minutes integer,
    performed_at timestamptz,
    notes text,
    created_at timestamptz default now()
);

alter table workout_sessions enable row level security;
create policy "Users can read own rows" on workout_sessions for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on workout_sessions for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on workout_sessions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Nutrition logs for meals.
create table if not exists meals (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    meal_type text not null,
    title text not null,
    kcal integer,
    protein_g numeric,
    carbs_g numeric,
    fat_g numeric,
    logged_at timestamptz not null,
    source text,
    created_at timestamptz default now()
);

alter table meals enable row level security;
create policy "Users can read own rows" on meals for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on meals for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on meals for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Recovery logs (sleep, stress, etc.).
create table if not exists recovery_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    sleep_hours numeric,
    sleep_score integer,
    stress_level integer,
    notes text,
    logged_at timestamptz not null,
    created_at timestamptz default now()
);

alter table recovery_logs enable row level security;
create policy "Users can read own rows" on recovery_logs for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on recovery_logs for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on recovery_logs for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Mobility routines (templates) owned by the user.
create table if not exists mobility_routines (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    name text not null,
    target_areas text[],
    duration_minutes integer,
    routine_json jsonb,
    created_at timestamptz default now()
);

alter table mobility_routines enable row level security;
create policy "Users can read own rows" on mobility_routines for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on mobility_routines for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on mobility_routines for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Mobility sessions tied to routines.
create table if not exists mobility_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    routine_id uuid references mobility_routines(id),
    status text not null,
    performed_at timestamptz,
    created_at timestamptz default now()
);

alter table mobility_sessions enable row level security;
create policy "Users can read own rows" on mobility_sessions for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on mobility_sessions for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on mobility_sessions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Pain checks and AI recommendations.
create table if not exists pain_checks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    area text not null,
    severity integer,
    description text,
    recommendation_json jsonb,
    created_at timestamptz default now()
);

alter table pain_checks enable row level security;
create policy "Users can read own rows" on pain_checks for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on pain_checks for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on pain_checks for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Breathwork sessions.
create table if not exists breathwork_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    technique text not null,
    duration_minutes integer,
    completed_at timestamptz,
    created_at timestamptz default now()
);

alter table breathwork_sessions enable row level security;
create policy "Users can read own rows" on breathwork_sessions for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on breathwork_sessions for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on breathwork_sessions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Look max sessions (aesthetics/posture/skin routines).
create table if not exists lookmax_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id),
    category text not null,
    plan_json jsonb,
    notes text,
    created_at timestamptz default now()
);

alter table lookmax_sessions enable row level security;
create policy "Users can read own rows" on lookmax_sessions for select using (auth.uid() = user_id);
create policy "Users can insert own rows" on lookmax_sessions for insert with check (auth.uid() = user_id);
create policy "Users can update own rows" on lookmax_sessions for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
