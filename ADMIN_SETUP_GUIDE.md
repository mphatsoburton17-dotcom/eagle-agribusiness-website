# Eagle Agribusiness Website — Admin & Database Setup Guide

This website now has a real product database with a login-protected admin panel,
built on **Supabase** (a free-to-start backend service — no coding needed for setup).

Follow these steps once. After that, adding/editing/removing products **and now
team members/departments** is just logging into `eagle-portal-7719.html` and
using the forms — no code required.

**Already did this setup before, and just want the new Team feature?** You only
need to re-run Step 2 (the SQL script) — it's safe to run again, it will add the
new `team_members` table without touching or duplicating your existing products.
Then skip straight to using the admin panel's new "Team & Departments" tab.

---

## 0. Change the staff access code

Before anything else, open `eagle-portal-7719.html` in a text editor and find
this line near the top of the `<script>` section:

```js
const ACCESS_CODE = 'EAGLE2026';
```

Change `'EAGLE2026'` to a code only you and Titus know. This is a light
screen that keeps casual visitors from finding the login form — it is
**not** the real security. The real protection is the Supabase login in
Step 4 below, which is always required no matter what.

## 1. Create a free Supabase project

1. Go to **https://supabase.com** and sign up (free).
2. Click **New Project**. Choose any name (e.g. "eagle-agribusiness"), set a
   database password (save it somewhere safe), and pick a region close to
   Malawi (e.g. Europe/South Africa if offered).
3. Wait ~1 minute for the project to finish setting up.

*Free tier covers this business easily. If you outgrow it later (very high
traffic), Supabase has paid tiers you can upgrade to without rebuilding
anything.*

## 2. Create the products table

1. In your Supabase project, open **SQL Editor** (left sidebar) → **New query**.
2. Open the file `supabase-schema.sql` (included in this folder), copy all of
   it, and paste it into the SQL Editor.
3. Click **Run**. This creates the `products` table, sets up permissions so
   only logged-in users can add/edit/delete, and loads your current price
   list as starter data.

## 3. Connect the website to your project

1. In Supabase, go to **Project Settings → API**.
2. Copy the **Project URL** and the **anon public** key (NOT the
   `service_role` key — that one must stay secret).
3. Open `config.js` in this folder and paste them in:
   ```js
   export const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   export const SUPABASE_ANON_KEY = "eyJhbGciOi....";
   ```
4. Save the file.

## 4. Create the admin login

There is no public sign-up page — admin accounts are created directly in
Supabase, so only people you choose can manage products.

1. In Supabase, go to **Authentication → Users → Add user**.
2. Enter an email and password for Mr Chiwindo (or whoever will manage
   products). Confirm "Auto Confirm User" is ticked so no email verification
   step is needed.
3. That email + password is now the login for `eagle-portal-7719.html`.

*Add more admin users the same way if more than one person needs access.*

## 5. Upload the website

Upload the whole folder (all the `.html` files, `style.css`, `config.js`,
and the `images` folder) to your web host — for example:

- **Netlify** or **Vercel** (free tiers, drag-and-drop the folder)
- Any shared hosting plan your developer sets up later

The `eagle-portal-7719.html` page will still work wherever the site is hosted, since the
login and product data live in Supabase, not on the web host.

## 6. Test it

1. Visit `yoursite.com/eagle-portal-7719.html`, log in with the account from Step 4.
2. Add a test product, save it.
3. Visit `yoursite.com/products.html` — the new product should appear, and
   tapping it should open WhatsApp with a pre-filled message.
4. Delete the test product from the admin panel once you've confirmed it works.

---

## Notes

- **Before Step 3 is done**, the Products page will still show a fallback
  list (today's prices) so the site never looks broken — but that list won't
  update until the database is connected.
- **Product photos**: the `images/products/` folder holds the real product
  photos. To add a new one from the admin panel, upload the photo into that
  folder (via your host or developer) and type its file name — e.g.
  `images/products/my-new-photo.jpg` — into the "Photo file name" field when
  adding or editing a product. Leave it blank for no photo.
- Only **active** products (the "Visible on the website" checkbox in the
  admin form) appear on the live Products page — useful for hiding an
  out-of-stock item without deleting it.
- The WhatsApp message sent when someone taps a product includes the product
  name and price, and asks how many they'd like to order.
- Keep your Supabase database password and the `service_role` key private —
  only the `anon` key and your admin login belong in files you might share
  with a developer.

---

## Customers & Follow-ups (new)

The admin panel now has a third tab: **Customers**. This is a lightweight
CRM that:

- Stores every purchase (customer name, phone, location, product, quantity, date)
- Automatically works out when that customer is "due" for a check-in —
  **2 weeks** after a Seedlings purchase, **1 month** after Fertiliser or Manure
- Shows a **"Follow-ups due"** list at the top of the tab every time you open
  it, with one-tap **WhatsApp, SMS, and Email** buttons already carrying a
  written message — you just tap Send in that app
- Lets you edit the wording of that message per product type (the
  **"Follow-up message templates"** card) — use `{name}`, `{product}`, and
  `{quantity}` anywhere and they'll be filled in automatically
- Has a **"Download Excel"** button that exports every customer as a `.csv`
  file (opens directly in Excel or Google Sheets)

**Important — this is one-tap sending, not fully automatic.** Nothing
messages a customer without a person tapping Send in WhatsApp, their SMS
app, or their email app first. Truly automatic sending (no human involved,
happens on a schedule by itself) would need a paid SMS/WhatsApp/email
service and a server running around the clock — a real recurring cost, not
something built into this free setup. If that's ever wanted later, it's an
upgrade path, not a rebuild.

### Branch agents can log sales without logging in

Share this link with your branches — it needs no password, just the basic
purchase details:

**`yoursite.com/log-purchase.html`**

It writes straight into the same Customers database the admin panel reads
from, but branch agents **cannot see, edit, or delete** any customer data
through that form — it's insert-only, so customer privacy is protected even
though no login is required to submit it.

### One more SQL step

If you already ran `supabase-schema.sql` before this update, just run the
**whole file again** in the Supabase SQL Editor — it's safe to re-run and
will only add the new `customers` and `message_templates` tables without
touching your existing products or team data.

---

## Testimonials & Partners (new)

The admin panel has a fourth tab: **Testimonials & Partners**.

- **Testimonials** — add a customer name, location, their quote, and
  (optionally) a photo. These appear on the About page as an **animated,
  auto-rotating carousel** — one testimonial fades in at a time, cycling
  automatically every 5 seconds, with dots underneath to jump between them
  or tap manually.
- **Partners** — add a name, an optional logo image, and an optional
  website link. These appear as a **continuously scrolling logo strip**
  underneath the testimonials. If no logo is added, the partner's name
  shows as a text badge instead — so it's fine to add a partner before you
  have their logo file ready.

Both sections start with placeholder/example content so the About page
never looks empty — replace them with real testimonials and partners
whenever you have them, right from the admin panel.

### One more SQL step

Same as before — if you already ran `supabase-schema.sql`, just run the
**whole file again** in the Supabase SQL Editor. It's safe to re-run and
will only add the new `testimonials` and `partners` tables.
