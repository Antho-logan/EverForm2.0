-- Mobility Assessments & Profiles
-- Stores per-assessment raw results plus an aggregated per-user profile

create table if not exists mobility_assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  overall_score int not null check (overall_score between 0 and 100),
  hips_score int null check (hips_score between 0 and 100),
  thoracic_score int null check (thoracic_score between 0 and 100),
  shoulders_score int null check (shoulders_score between 0 and 100),
  ankles_score int null check (ankles_score between 0 and 100),
  raw_results jsonb not null,
  notes text null
);

create table if not exists mobility_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  overall_score int not null check (overall_score between 0 and 100),
  hips_score int null check (hips_score between 0 and 100),
  thoracic_score int null check (thoracic_score between 0 and 100),
  shoulders_score int null check (shoulders_score between 0 and 100),
  ankles_score int null check (ankles_score between 0 and 100),
  focus_areas text[] not null default '{}'::text[],
  risk_notes text[] not null default '{}'::text[],
  last_assessment_at timestamptz not null,
  summary_json jsonb not null default '{}'::jsonb
);

alter table mobility_assessments enable row level security;
alter table mobility_profiles enable row level security;

create policy "mobility_assessments_select" on mobility_assessments for select using (auth.uid() = user_id);
create policy "mobility_assessments_insert" on mobility_assessments for insert with check (auth.uid() = user_id);
create policy "mobility_assessments_update" on mobility_assessments for update using (auth.uid() = user_id);
create policy "mobility_assessments_delete" on mobility_assessments for delete using (auth.uid() = user_id);

create policy "mobility_profiles_select" on mobility_profiles for select using (auth.uid() = user_id);
create policy "mobility_profiles_insert" on mobility_profiles for insert with check (auth.uid() = user_id);
create policy "mobility_profiles_update" on mobility_profiles for update using (auth.uid() = user_id);
create policy "mobility_profiles_delete" on mobility_profiles for delete using (auth.uid() = user_id);

