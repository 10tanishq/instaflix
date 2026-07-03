// Fill these in with your own Supabase project values.
// Find them in your Supabase project: Settings -> API
const SUPABASE_URL = "https://alfrrcueqfmhlkjzdsle.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsZnJyY3VlcWZtaGxranpkc2xlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwODU1NDAsImV4cCI6MjA5ODY2MTU0MH0.4R0thR7DUDjmMovyvVPAs52_VOLj7HFS4fxUvjG4ya4";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
