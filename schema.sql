-- NTPGame v3 - Supabase schema
create extension if not exists pgcrypto;

create table if not exists public.profiles(
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  email text,
  role text not null default 'user' check(role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.products(
  id uuid primary key default gen_random_uuid(),
  name text not null,
  game text not null,
  category text not null check(category in ('account','service','digital')),
  description text default '',
  price bigint not null check(price >= 0),
  old_price bigint,
  image text default '🎮',
  tag text,
  stock integer not null default 1,
  is_active boolean not null default true,
  delivery_note text,
  created_at timestamptz not null default now()
);

create table if not exists public.orders(
  id uuid primary key default gen_random_uuid(),
  order_code text unique not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  customer_name text,
  phone text,
  note text,
  total_amount bigint not null default 0,
  status text not null default 'pending' check(status in ('pending','paid','processing','completed','cancelled')),
  delivery_note text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items(
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text,
  unit_price bigint not null default 0,
  quantity integer not null default 1 check(quantity > 0),
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,display_name,email)
  values(new.id,coalesce(new.raw_user_meta_data->>'display_name',''),new.email)
  on conflict(id) do update set display_name=excluded.display_name,email=excluded.email;
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "profiles own read" on public.profiles;
create policy "profiles own read" on public.profiles for select using(auth.uid()=id or exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));

drop policy if exists "products public read" on public.products;
create policy "products public read" on public.products for select using(is_active=true or exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));

drop policy if exists "products admin write" on public.products;
create policy "products admin write" on public.products for all using(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin')) with check(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));

drop policy if exists "orders own read" on public.orders;
create policy "orders own read" on public.orders for select using(auth.uid()=user_id or exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));

drop policy if exists "orders admin update" on public.orders;
create policy "orders admin update" on public.orders for update using(exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));

drop policy if exists "items own read" on public.order_items;
create policy "items own read" on public.order_items for select using(exists(select 1 from public.orders o where o.id=order_id and (o.user_id=auth.uid() or exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'))));

create or replace function public.create_order(
  p_items jsonb,
  p_note text default '',
  p_phone text default '',
  p_customer_name text default ''
) returns text language plpgsql security definer set search_path=public as $$
declare
  uid uuid := auth.uid();
  oid uuid;
  code text;
  item jsonb;
  pid uuid;
  qty integer;
  price bigint;
  pname text;
  total bigint := 0;
begin
  if uid is null then raise exception 'Bạn cần đăng nhập'; end if;
  if jsonb_array_length(p_items)=0 then raise exception 'Giỏ hàng trống'; end if;

  code := 'NTG-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into public.orders(order_code,user_id,customer_name,phone,note,total_amount)
  values(code,uid,p_customer_name,p_phone,p_note,0) returning id into oid;

  for item in select * from jsonb_array_elements(p_items) loop
    pid := (item->>'product_id')::uuid;
    qty := greatest(1,coalesce((item->>'quantity')::integer,1));
    select name,price into pname,price from public.products where id=pid and is_active=true;
    if pname is null then raise exception 'Sản phẩm không tồn tại hoặc đã ẩn'; end if;
    if price is null then raise exception 'Giá sản phẩm không hợp lệ'; end if;
    total := total + price*qty;
    insert into public.order_items(order_id,product_id,product_name,unit_price,quantity)
    values(oid,pid,pname,price,qty);
  end loop;
  update public.orders set total_amount=total where id=oid;
  return code;
end; $$;

revoke all on function public.create_order(jsonb,text,text,text) from public;
grant execute on function public.create_order(jsonb,text,text,text) to authenticated;

-- Sau khi tạo user admin:
-- update public.profiles set role='admin' where email='EMAIL_ADMIN';

-- Dữ liệu demo:
insert into public.products(name,game,category,description,price,old_price,image,tag,stock)
select * from (values
('Free Fire VIP — Rank Cao','Free Fire','account','Acc demo: rank cao, skin và vật phẩm.',399000,499000,'🔥','HOT',1),
('Liên Quân — Full Tướng','Liên Quân','account','Acc demo: full tướng, nhiều trang phục.',299000,399000,'⚔️','NEW',1),
('ZingSpeed — Acc Đua','ZingSpeed','account','Acc demo dành cho người chơi đua xe.',199000,249000,'🏎️','SALE',1),
('Play Together — Gói VIP','Play Together','account','Acc demo với vật phẩm nổi bật.',259000,329000,'🌳','HOT',1),
('TFT — Tài khoản rank','TFT','account','Acc demo TFT.',349000,449000,'♟️','NEW',1),
('Cày thuê Free Fire','Free Fire','service','Cày rank/nhiệm vụ theo mục tiêu.',50000,null,'🔥',null,99),
('Cày thuê Liên Quân','Liên Quân','service','Hỗ trợ leo rank và nhiệm vụ.',60000,null,'⚔️',null,99),
('Hỗ trợ Instagram','Instagram','digital','Hỗ trợ vận hành tài khoản/nội dung hợp lệ.',50000,null,'◎',null,99),
('Hỗ trợ TikTok','TikTok','digital','Hỗ trợ nội dung và vận hành kênh.',70000,null,'♪',null,99),
('Hỗ trợ YouTube','YouTube','digital','Hỗ trợ kênh và thiết lập cơ bản.',80000,null,'▶',null,99),
('Hỗ trợ Website','Website','digital','Tư vấn, chỉnh sửa giao diện và hỗ trợ website.',150000,null,'⌘',null,99)
) as v(name,game,category,description,price,old_price,image,tag,stock)
where not exists(select 1 from public.products p where p.name=v.name);