// Supabase project for syncing the board across devices. The publishable key is meant to be public;
// the database's row-level security only lets each signed-in person read and change their own board.
window.WB_SUPA = {
  url: 'https://upsfyasanpsnjwjjigsh.supabase.co',
  key: 'sb_publishable_9Xs2wI-wHMybw2kNv1s96w_dckruvWY',
  // Google OAuth client ID (public) for Google Calendar sync. Empty turns the feature off.
  googleClientId: '483353877564-rtb6rsd4rs5u1oiuhd7jvsi36saktojl.apps.googleusercontent.com'
};
