-- Retires the ad-hoc "Kopi_Susu_Test" product used to verify offline sync
-- in earlier phases now that a real menu exists. Soft-deleted (is_active =
-- false) rather than hard-deleted: it already has real stock_movements rows
-- from testing, and stock_movements.product_id is NOT NULL + has no ON
-- DELETE clause, so a hard delete would fail on the foreign key (by design
-- -- the stock ledger is meant to be immutable/append-only). Inactive
-- products are already excluded from the kasir POS grid; they still show in
-- the admin product list for management.
update public.products set is_active = false where name = 'Kopi_Susu_Test';
