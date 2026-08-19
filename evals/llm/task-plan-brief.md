# Fixed brief — plan-quality golden task (do not edit; this is the baseline)

Add a "saved searches" feature to the frontend: a logged-in user can save the current
filter set under a name, list their saved searches, apply one, and delete one. Saved
searches are per-user, capped at 20, names unique per user, and must survive session
logout. The list appears in a sidebar panel on the search page.

Constraints: existing search filters live in Redux state; backend is the TS API;
persistence in Postgres via the data layer; no design changes beyond the sidebar panel.
