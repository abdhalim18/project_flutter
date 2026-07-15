-- Phase 4: offline-first POS transactions

create table public.transactions (
  id uuid primary key,                          -- client-generated UUID (offline idempotency key)
  cashier_id uuid not null references public.profiles (id),
  total_amount numeric(12, 2) not null,
  discount_amount numeric(12, 2) not null default 0,
  payment_method text not null,                 -- 'cash' | 'qris' | 'debit' etc.
  payment_received numeric(12, 2) not null default 0,
  change_amount numeric(12, 2) not null default 0,
  status text not null default 'completed',     -- 'completed' | 'voided'
  client_created_at timestamptz not null,        -- when the sale actually happened offline
  synced_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.transaction_items (
  id uuid primary key,
  transaction_id uuid not null references public.transactions (id) on delete cascade,
  product_id uuid references public.products (id),
  product_name_snapshot text not null,          -- denormalized: protects historical reports
  unit_price numeric(12, 2) not null,           -- price snapshot at sale time
  qty integer not null,
  subtotal numeric(12, 2) not null
);

-- Append-only ledger; the ONLY way stock changes. Client never writes stock_qty directly.
create table public.stock_movements (
  id uuid primary key,
  product_id uuid not null references public.products (id),
  change_qty integer not null,                  -- negative for sale, positive for restock
  reason text not null,                         -- 'sale' | 'restock' | 'adjustment'
  reference_id uuid,                            -- transaction_id when reason = 'sale'
  created_at timestamptz not null default now()
);

create function public.apply_stock_movement()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.products
  set stock_qty = stock_qty + new.change_qty
  where id = new.product_id;
  return new;
end;
$$;

create trigger on_stock_movement_insert
  after insert on public.stock_movements
  for each row execute function public.apply_stock_movement();

alter table public.transactions enable row level security;
alter table public.transaction_items enable row level security;
alter table public.stock_movements enable row level security;

-- Transactions: any authenticated user can insert (kasir recording a sale);
-- kasir sees only their own, admin sees all. No update/delete — immutability
-- enforced at the DB level (voiding is a new status transition, not an edit).
create policy "transactions: insert own"
  on public.transactions for insert
  to authenticated
  with check (cashier_id = auth.uid());

create policy "transactions: select own or admin"
  on public.transactions for select
  to authenticated
  using (cashier_id = auth.uid() or public.is_admin());

create policy "transaction_items: insert if parent transaction is own"
  on public.transaction_items for insert
  to authenticated
  with check (
    exists (
      select 1 from public.transactions t
      where t.id = transaction_id and t.cashier_id = auth.uid()
    )
  );

create policy "transaction_items: select if parent transaction visible"
  on public.transaction_items for select
  to authenticated
  using (
    exists (
      select 1 from public.transactions t
      where t.id = transaction_id and (t.cashier_id = auth.uid() or public.is_admin())
    )
  );

create policy "stock_movements: insert if reason is sale on own transaction, or admin"
  on public.stock_movements for insert
  to authenticated
  with check (
    public.is_admin()
    or (
      reason = 'sale'
      and exists (
        select 1 from public.transactions t
        where t.id = reference_id and t.cashier_id = auth.uid()
      )
    )
  );

create policy "stock_movements: select all authenticated"
  on public.stock_movements for select
  to authenticated
  using (true);
