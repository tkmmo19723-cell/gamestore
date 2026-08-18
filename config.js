window.NTP_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_KEY: "YOUR_PUBLISHABLE_OR_ANON_KEY",
  SHOP_NAME: "NTPGame"
};
window.ntpSupabase = null;
if (window.supabase && !window.NTP_CONFIG.SUPABASE_URL.includes("YOUR-PROJECT")) {
  window.ntpSupabase = window.supabase.createClient(window.NTP_CONFIG.SUPABASE_URL, window.NTP_CONFIG.SUPABASE_KEY);
}