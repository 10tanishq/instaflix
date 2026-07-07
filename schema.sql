-- Run this in your Supabase project's SQL editor (Database -> SQL Editor)

create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  created_at timestamp with time zone default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using (true);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Automatically creates a profile row whenever someone signs up.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    new.raw_user_meta_data->>'username'
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Lets the login page accept a username (not just email) by resolving it to the
-- account's email server-side, without exposing emails through a public table/policy.
create or replace function public.get_email_for_username(uname text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  result text;
begin
  select au.email into result
  from auth.users au
  join public.profiles p on p.id = au.id
  where p.username = uname;
  return result;
end;
$$;

grant execute on function public.get_email_for_username(text) to anon, authenticated;
