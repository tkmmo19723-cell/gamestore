-- NTPGame starter schema
create table if not exists products(
 id uuid primary key default gen_random_uuid(),
 name text not null, category text not null, price integer not null default 0,
 description text, image_url text, active boolean default true, created_at timestamptz default now()
);
create table if not exists orders(
 id uuid primary key default gen_random_uuid(),
 user_id uuid, total integer not null default 0, status text default 'pending',
 created_at timestamptz default now()
);
create table if not exists order_items(
 id uuid primary key default gen_random_uuid(),
 order_id uuid references orders(id) on delete cascade,
 product_id uuid references products(id), name text, price integer, quantity integer default 1
);
