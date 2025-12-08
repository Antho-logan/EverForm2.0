-- Pain assessments collected from the 5-step FixPain wizard

create table if not exists pain_assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),

  body_region text not null,
  side text not null,
  pain_duration text not null,
  pain_intensity integer not null check (pain_intensity between 0 and 10),
  pain_character text[] not null default '{}'::text[],
  aggravating_factors text[] not null default '{}'::text[],
  relieving_factors text[] not null default '{}'::text[],
  activity_context text[] not null default '{}'::text[],
  red_flags text[] not null default '{}'::text[],
  has_red_flags boolean not null default false,
  functional_limitations text[] not null default '{}'::text[],
  notes text,
  photo_url text,

  triage_level text not null default 'self_manage',
  ai_summary_json jsonb,
  ai_version text not null default 'v1'
);

create index if not exists pain_assessments_user_created_idx on pain_assessments (user_id, created_at desc);

alter table pain_assessments enable row level security;
create policy "pain_assessments_select" on pain_assessments for select using (auth.uid() = user_id);
create policy "pain_assessments_insert" on pain_assessments for insert with check (auth.uid() = user_id);
create policy "pain_assessments_update" on pain_assessments for update using (auth.uid() = user_id);
create policy "pain_assessments_delete" on pain_assessments for delete using (auth.uid() = user_id);

