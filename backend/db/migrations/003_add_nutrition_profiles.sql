-- Adds per-user nutrition profiles for goals, targets, and preferences

create table if not exists nutrition_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  goal text check (goal in ('maintenance', 'fat_loss', 'recomposition', 'muscle_gain', 'performance', 'longevity')) default 'maintenance',
  calorie_target int default 2600,
  protein_target_g int default 180,
  carb_target_g int default 280,
  fat_target_g int default 80,
  diet_type text check (diet_type in ('omnivore', 'high_protein', 'mediterranean', 'vegetarian', 'vegan', 'low_carb', 'low_fat')) default 'omnivore',
  constraints jsonb default '{}'::jsonb,
  biohacker_flags jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table nutrition_profiles enable row level security;
create policy "nutrition_profiles_select" on nutrition_profiles for select using (auth.uid() = user_id);
create policy "nutrition_profiles_insert" on nutrition_profiles for insert with check (auth.uid() = user_id);
create policy "nutrition_profiles_update" on nutrition_profiles for update using (auth.uid() = user_id);

