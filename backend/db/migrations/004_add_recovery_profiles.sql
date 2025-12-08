-- Adds per-user recovery profiles for sleep and recovery preferences

create table if not exists recovery_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  goal text not null default 'optimal',
  target_sleep_minutes int not null default 480 check (target_sleep_minutes between 240 and 600),
  preferred_bedtime time with time zone null,
  preferred_wake_time time with time zone null,
  caffeine_cutoff_hour int null check (caffeine_cutoff_hour between 0 and 23),
  timezone text not null default 'Europe/Amsterdam',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table recovery_profiles enable row level security;
create policy "recovery_profiles_select" on recovery_profiles for select using (auth.uid() = user_id);
create policy "recovery_profiles_insert" on recovery_profiles for insert with check (auth.uid() = user_id);
create policy "recovery_profiles_update" on recovery_profiles for update using (auth.uid() = user_id);
create policy "recovery_profiles_delete" on recovery_profiles for delete using (auth.uid() = user_id);

