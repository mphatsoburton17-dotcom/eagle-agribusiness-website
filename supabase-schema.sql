-- ===========================================================
-- Eagle Agribusiness — Supabase database setup
-- Run this once in your Supabase project: SQL Editor → New query → Run
--
-- Safe to re-run: if you already set up the "products" table
-- before and are only adding the new "team_members" table now,
-- you can run this whole file again without errors — existing
-- tables and policies are dropped/recreated cleanly, and it will
-- NOT duplicate your product rows if you've already added your
-- own (it only inserts starter rows the first time the table is
-- created empty... see note near the bottom for details).
-- ===========================================================

create extension if not exists "pgcrypto";

-- ===========================================================
-- PART 1: Products (fertiliser, seedlings, manure)
-- ===========================================================
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Fertiliser',   -- Fertiliser / Seedlings / Manure
  price_label text not null,                      -- e.g. "K50 each" or "K72,500"
  description text,
  image_url text,                                 -- e.g. "images/products/tomato-select.jpg" or a full https:// link
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- If you already ran an older version of this file and just need the photo
-- column, you can also run this line on its own:
-- alter table products add column if not exists image_url text;

alter table products enable row level security;

drop policy if exists "Public can view active products" on products;
create policy "Public can view active products"
  on products for select
  using (active = true);

drop policy if exists "Logged-in users can view all products" on products;
create policy "Logged-in users can view all products"
  on products for select
  using (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can insert products" on products;
create policy "Logged-in users can insert products"
  on products for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can update products" on products;
create policy "Logged-in users can update products"
  on products for update
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can delete products" on products;
create policy "Logged-in users can delete products"
  on products for delete
  using (auth.role() = 'authenticated');

-- Starter data — only runs if the products table is completely empty,
-- so re-running this file will NOT duplicate products you've already
-- added or edited yourself.
insert into products (name, category, price_label, image_url, sort_order)
select * from (values
  ('Eagle Mbeya Fertiliser 50kg — Lilongwe', 'Fertiliser', 'K72,500', 'images/products/fert-bags-50kg.jpg', 1),
  ('Eagle Mbeya Fertiliser 25kg — Lilongwe', 'Fertiliser', 'K38,500', 'images/products/fert-bags-stack.jpg', 2),
  ('Eagle Mbeya Fertiliser 50kg — Blantyre & Mzuzu', 'Fertiliser', 'K80,000', 'images/products/fert-bags-50kg.jpg', 3),
  ('Eagle Mbeya Fertiliser 25kg — Blantyre & Mzuzu', 'Fertiliser', 'K42,500', 'images/products/fert-bags-stack.jpg', 4),
  ('Tomato Seedling (Tengeru Select)', 'Seedlings', 'K50 each', 'images/products/tomato-select.jpg', 5),
  ('Tomato Seedling (Tengeru Nyanya)', 'Seedlings', 'K30 each', 'images/products/tomato-nyanya.jpg', 6),
  ('Onion Seedling (Red Creole)', 'Seedlings', 'K20 each', null, 7),
  ('Cabbage Seedling (Star 3317)', 'Seedlings', 'K60 each', 'images/products/cabbage-field-1.jpg', 8),
  ('Lettuce Seedling', 'Seedlings', 'K100 each', 'images/products/lettuce-field.jpg', 9),
  ('Green Pepper Seedling', 'Seedlings', 'K150 each', null, 10),
  ('Eggplant Seedling', 'Seedlings', 'K150 each', null, 11),
  ('Manure (per bag)', 'Manure', 'Ask for current price', null, 12)
) as starter(name, category, price_label, image_url, sort_order)
where not exists (select 1 from products);


-- ===========================================================
-- PART 2: Team / Departments (shown on the About page)
-- Managed the same way as products: add/edit/remove from the
-- admin panel, no code changes needed.
-- ===========================================================
create table if not exists team_members (
  id uuid primary key default gen_random_uuid(),
  name text not null,                 -- e.g. "Mr Titus Chiwindo" or a department name
  role text not null,                 -- e.g. "CEO & Founder" or "Sales & Marketing Department"
  bio text,                           -- short description, optional
  image_url text,                     -- optional photo
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table team_members enable row level security;

drop policy if exists "Public can view active team members" on team_members;
create policy "Public can view active team members"
  on team_members for select
  using (active = true);

drop policy if exists "Logged-in users can view all team members" on team_members;
create policy "Logged-in users can view all team members"
  on team_members for select
  using (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can insert team members" on team_members;
create policy "Logged-in users can insert team members"
  on team_members for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can update team members" on team_members;
create policy "Logged-in users can update team members"
  on team_members for update
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can delete team members" on team_members;
create policy "Logged-in users can delete team members"
  on team_members for delete
  using (auth.role() = 'authenticated');

-- Starter data — Mr Chiwindo as CEO plus four placeholder departments.
-- Edit names, roles, and bios from the admin panel to match your real
-- team structure whenever you're ready. Like products, this only inserts
-- if the table is currently empty, so it's safe to re-run.
insert into team_members (name, role, bio, sort_order)
select * from (values
  ('Mr Titus Chiwindo', 'CEO & Founder', 'Founder and Chief Executive Officer of Eagle Agribusiness & Extension Services.', 1),
  ('Operations Department', 'Department', 'Oversees day-to-day running of all selling points and stock availability.', 2),
  ('Sales & Marketing Department', 'Department', 'Manages customer relationships, promotions, and the branch network.', 3),
  ('Agricultural Extension Department', 'Department', 'Provides farming advice and product guidance to customers.', 4),
  ('Logistics & Distribution Department', 'Department', 'Coordinates deliveries and supply across Lilongwe, Blantyre, and Mzuzu.', 5)
) as starter(name, role, bio, sort_order)
where not exists (select 1 from team_members);


-- ===========================================================
-- PART 3: Customers & Follow-ups
-- Tracks purchases, automatically calculates when a customer is
-- due for a check-in, and stores editable message templates.
-- ===========================================================
create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text,
  email text,
  location text,
  product_type text not null,          -- Fertiliser / Seedlings / Manure
  product_detail text,                 -- e.g. "Tomato Tengeru Select"
  quantity text,                       -- free text, e.g. "2 bags", "50 seedlings"
  purchase_date date not null default current_date,
  follow_up_date date,                 -- auto-calculated by trigger below
  follow_up_status text not null default 'pending',  -- pending / done
  notes text,
  submitted_by text,                   -- optional: which branch/agent logged this
  created_at timestamptz not null default now()
);

-- Automatically calculate the follow-up date whenever a purchase is added
-- or its product type / purchase date changes: Seedlings = +14 days,
-- Fertiliser and Manure = +30 days.
create or replace function eagle_set_followup_date()
returns trigger as $$
begin
  if new.product_type = 'Seedlings' then
    new.follow_up_date := new.purchase_date + interval '14 days';
  else
    new.follow_up_date := new.purchase_date + interval '30 days';
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists eagle_customers_followup on customers;
create trigger eagle_customers_followup
  before insert or update of purchase_date, product_type on customers
  for each row execute function eagle_set_followup_date();

alter table customers enable row level security;

-- Branch agents can submit new purchases WITHOUT logging in (a public form),
-- but cannot read, edit, or delete any customer data — only admins can.
drop policy if exists "Anyone can log a new purchase" on customers;
create policy "Anyone can log a new purchase"
  on customers for insert
  with check (true);

drop policy if exists "Logged-in users can view customers" on customers;
create policy "Logged-in users can view customers"
  on customers for select
  using (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can update customers" on customers;
create policy "Logged-in users can update customers"
  on customers for update
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can delete customers" on customers;
create policy "Logged-in users can delete customers"
  on customers for delete
  using (auth.role() = 'authenticated');

-- Editable follow-up message templates (one per product type).
-- {name}, {product}, {quantity} are filled in automatically when sending.
create table if not exists message_templates (
  id uuid primary key default gen_random_uuid(),
  product_type text not null unique,
  message text not null,
  updated_at timestamptz not null default now()
);

alter table message_templates enable row level security;

drop policy if exists "Logged-in users can view templates" on message_templates;
create policy "Logged-in users can view templates"
  on message_templates for select
  using (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can insert templates" on message_templates;
create policy "Logged-in users can insert templates"
  on message_templates for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can update templates" on message_templates;
create policy "Logged-in users can update templates"
  on message_templates for update
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

insert into message_templates (product_type, message)
select * from (values
  ('Seedlings', 'Hi {name}, it''s been 2 weeks since you got your {product} from Eagle Agribusiness. How are they growing? Let us know if you need more seedlings or any advice! 🌱'),
  ('Fertiliser', 'Hi {name}, it''s been a month since your {product} purchase from Eagle Agribusiness. How has it been working for your field? Let us know if you''d like to order more. 🌾'),
  ('Manure', 'Hi {name}, it''s been a month since your {product} purchase from Eagle Agribusiness. How is your soil doing? Reach out if you need another delivery. 🐄')
) as starter(product_type, message)
where not exists (select 1 from message_templates);


-- ===========================================================
-- PART 4: Testimonials (shown as an animated carousel)
-- ===========================================================
create table if not exists testimonials (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  location text,
  message text not null,
  image_url text,                     -- optional customer photo
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table testimonials enable row level security;

drop policy if exists "Public can view active testimonials" on testimonials;
create policy "Public can view active testimonials"
  on testimonials for select
  using (active = true);

drop policy if exists "Logged-in users can view all testimonials" on testimonials;
create policy "Logged-in users can view all testimonials"
  on testimonials for select
  using (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can insert testimonials" on testimonials;
create policy "Logged-in users can insert testimonials"
  on testimonials for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can update testimonials" on testimonials;
create policy "Logged-in users can update testimonials"
  on testimonials for update
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can delete testimonials" on testimonials;
create policy "Logged-in users can delete testimonials"
  on testimonials for delete
  using (auth.role() = 'authenticated');

-- Placeholder testimonials — replace these with real customer quotes from
-- the admin panel whenever Titus has them ready.
insert into testimonials (customer_name, location, message, sort_order)
select * from (values
  ('A happy farmer', 'Lilongwe', 'Add a real customer quote here from the admin panel — e.g. how their harvest improved using Eagle Agribusiness products.', 1),
  ('Another happy farmer', 'Blantyre', 'Add a second real testimonial here whenever it''s ready.', 2)
) as starter(customer_name, location, message, sort_order)
where not exists (select 1 from testimonials);


-- ===========================================================
-- PART 5: Partners (shown as a scrolling logo strip)
-- ===========================================================
create table if not exists partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  website_url text,
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table partners enable row level security;

drop policy if exists "Public can view active partners" on partners;
create policy "Public can view active partners"
  on partners for select
  using (active = true);

drop policy if exists "Logged-in users can view all partners" on partners;
create policy "Logged-in users can view all partners"
  on partners for select
  using (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can insert partners" on partners;
create policy "Logged-in users can insert partners"
  on partners for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can update partners" on partners;
create policy "Logged-in users can update partners"
  on partners for update
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Logged-in users can delete partners" on partners;
create policy "Logged-in users can delete partners"
  on partners for delete
  using (auth.role() = 'authenticated');

-- No starter partners inserted — add real ones from the admin panel once
-- Titus confirms which organisations count as official partners.
