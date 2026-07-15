-- Seed a starter cafe menu (categories + products) so the app has real
-- content to demo instead of the ad-hoc test product. Photo URLs are
-- deterministic placeholder photos (picsum.photos/seed/...), not real
-- product photography -- admin can replace them later via the product
-- edit screen's photo upload. Safe to re-run: skips rows that already
-- exist by name.

insert into public.categories (name)
select v.name
from (values ('Kopi'), ('Non-Kopi'), ('Snack')) as v(name)
where not exists (select 1 from public.categories c where c.name = v.name);

insert into public.products (category_id, name, sku, price, stock_qty, photo_url, is_active)
select c.id, v.name, v.sku, v.price, v.stock_qty, v.photo_url, true
from (
  values
    ('Kopi', 'Espresso', 'ESP01', 15000, 50, 'https://picsum.photos/seed/espresso-cafe/600/600'),
    ('Kopi', 'Americano', 'AME01', 18000, 50, 'https://picsum.photos/seed/americano-cafe/600/600'),
    ('Kopi', 'Kopi Susu Gula Aren', 'KSG01', 20000, 40, 'https://picsum.photos/seed/kopi-susu-aren/600/600'),
    ('Kopi', 'Cappuccino', 'CAP01', 22000, 40, 'https://picsum.photos/seed/cappuccino-cafe/600/600'),
    ('Kopi', 'Cafe Latte', 'LAT01', 22000, 40, 'https://picsum.photos/seed/cafe-latte/600/600'),
    ('Kopi', 'Mocha', 'MOC01', 24000, 30, 'https://picsum.photos/seed/mocha-cafe/600/600'),
    ('Non-Kopi', 'Matcha Latte', 'MAT01', 23000, 30, 'https://picsum.photos/seed/matcha-latte/600/600'),
    ('Non-Kopi', 'Chocolate', 'CHO01', 21000, 30, 'https://picsum.photos/seed/hot-chocolate/600/600'),
    ('Non-Kopi', 'Thai Tea', 'THA01', 19000, 30, 'https://picsum.photos/seed/thai-tea/600/600'),
    ('Non-Kopi', 'Lemon Tea', 'LEM01', 17000, 30, 'https://picsum.photos/seed/lemon-tea/600/600'),
    ('Snack', 'Croissant', 'CRO01', 18000, 20, 'https://picsum.photos/seed/croissant-snack/600/600'),
    ('Snack', 'Donut Coklat', 'DON01', 12000, 25, 'https://picsum.photos/seed/donut-snack/600/600'),
    ('Snack', 'Banana Bread', 'BAN01', 16000, 20, 'https://picsum.photos/seed/banana-bread/600/600'),
    ('Snack', 'French Fries', 'FRI01', 15000, 25, 'https://picsum.photos/seed/french-fries/600/600')
) as v(category_name, name, sku, price, stock_qty, photo_url)
join public.categories c on c.name = v.category_name
where not exists (select 1 from public.products p where p.name = v.name);
