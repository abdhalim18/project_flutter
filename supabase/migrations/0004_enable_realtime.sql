-- Required for supabase_flutter's `.stream()` (used by ProductListScreen/CategoryManagerScreen)
-- to receive live updates via Postgres logical replication.
alter publication supabase_realtime add table public.products;
alter publication supabase_realtime add table public.categories;
