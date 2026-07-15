-- Phase 5: flag products for admin review when a stock movement drives
-- stock_qty negative (e.g. two offline cashiers both sell the last unit of
-- the same product before either syncs). Stock is intentionally allowed to
-- go negative rather than clamped/hidden -- see plan section "Risiko
-- double-spend stok". The flag is only cleared by an explicit admin action,
-- never automatically by a later positive movement.

alter table public.products
  add column needs_review boolean not null default false;

create or replace function public.apply_stock_movement()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.products
  set stock_qty = stock_qty + new.change_qty,
      needs_review = needs_review or (stock_qty + new.change_qty < 0)
  where id = new.product_id;
  return new;
end;
$$;

-- Admin-only write policy on public.products already covers clearing this
-- flag (UPDATE products SET needs_review = false ...); no separate RPC needed.
