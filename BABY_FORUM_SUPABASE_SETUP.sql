-- Paket 26: Supabase SQL Editor'de proje sahibi tarafından çalıştırılmalıdır.
-- Uygulama yalnızca publishable/anon key kullanır. service_role istemciye konmaz.
create extension if not exists pgcrypto;

create table if not exists public.baby_forum_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 100),
  body text not null check (char_length(btrim(body)) between 1 and 2000),
  category text not null check (category in ('Yenidoğan','Beslenme','Uyku','Gelişim','Sağlık','Genel')),
  created_at timestamptz not null default now()
);
create index if not exists baby_forum_posts_created_idx on public.baby_forum_posts(created_at desc);

create table if not exists public.baby_forum_replies (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.baby_forum_posts(id) on delete cascade,
  author_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  body text not null check (char_length(btrim(body)) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index if not exists baby_forum_replies_post_idx on public.baby_forum_replies(post_id, created_at);

alter table public.baby_forum_posts enable row level security;
alter table public.baby_forum_replies enable row level security;

revoke all on public.baby_forum_posts from anon;
revoke all on public.baby_forum_replies from anon;
grant select, insert, delete on public.baby_forum_posts to authenticated;
grant select, insert on public.baby_forum_replies to authenticated;

create policy "baby_posts_read_authenticated" on public.baby_forum_posts
  for select to authenticated using (true);
create policy "baby_posts_insert_self" on public.baby_forum_posts
  for insert to authenticated with check (author_id = (select auth.uid()));
create policy "baby_posts_delete_self" on public.baby_forum_posts
  for delete to authenticated using (author_id = (select auth.uid()));
create policy "baby_replies_read_authenticated" on public.baby_forum_replies
  for select to authenticated using (true);
create policy "baby_replies_insert_self" on public.baby_forum_replies
  for insert to authenticated with check (author_id = (select auth.uid()));

-- Üretim öncesi zorunlu: moderatör silme/raporlama, spam ve rate-limit,
-- KVKK ve topluluk kuralları, içerik şikayetleri, denetim kayıtları.
-- Bunlar paket 26 kapsamında henüz uygulanmamıştır.
