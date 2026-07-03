# Instaflix

Instagram-style signup/login pages backed by Supabase auth + database. Plain HTML/CSS/JS, no build step required.

## 1. Create a Supabase project

1. Go to https://supabase.com, sign in, and create a new project (free tier).
2. In the project, open the **SQL Editor** and run the contents of [schema.sql](schema.sql). This creates a `profiles` table and a trigger that saves each user's `username` on signup.
3. Go to **Settings -> API** and copy your **Project URL** and **anon public** key.

## 2. Configure the app

Open [supabase-config.js](supabase-config.js) and replace the placeholders:

```js
const SUPABASE_URL = "https://xxxxx.supabase.co";
const SUPABASE_ANON_KEY = "eyJ...";
```

## 3. Run it locally

No build tools needed. Just open `index.html` in a browser, or serve the folder with any static server, e.g.:

```
npx serve .
```

## 4. Deploy to Vercel

1. Push this folder to a GitHub repository.
2. In Vercel, click **New Project**, import the repo, and set:
   - Framework Preset: **Other**
   - Build command: (leave empty)
   - Output directory: (leave empty / root)
3. Deploy.

## How it works

- **Sign up** (`signup.html`): creates a real account via `supabase.auth.signUp` with email, username, and password. Supabase hashes and stores the password securely; the trigger in `schema.sql` saves the username to the `profiles` table.
- **Log in** (`index.html`): verifies email/password against Supabase via `supabase.auth.signInWithPassword`. Only accounts that were actually signed up can log in; wrong credentials show the real error from Supabase.
- **Home** (`home.html`): a protected page that redirects back to login if there's no active session, otherwise shows the logged-in user's username with a logout button.

By default, Supabase requires email confirmation before a new account can log in. You can turn this off in **Authentication -> Providers -> Email -> Confirm email** in the Supabase dashboard if you want signups to log in immediately.
