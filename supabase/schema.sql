-- VICECLIPS: ejecutar en Supabase > SQL Editor.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  created_at timestamptz not null default now()
);
create table if not exists public.clips (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 90),
  category text not null check (category in ('accion','fails','momentos','persecuciones')),
  video_url text not null,
  storage_path text not null,
  created_at timestamptz not null default now()
);
create table if not exists public.likes (
  clip_id uuid not null references public.clips(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (clip_id,user_id)
);
alter table public.profiles enable row level security;
alter table public.clips enable row level security;
alter table public.likes enable row level security;
create policy "Profiles are public" on public.profiles for select using (true);
create policy "Users create own profile" on public.profiles for insert with check (auth.uid()=id);
create policy "Users update own profile" on public.profiles for update using (auth.uid()=id) with check (auth.uid()=id);
create policy "Clips are public" on public.clips for select using (true);
create policy "Authenticated users publish clips" on public.clips for insert to authenticated with check (auth.uid()=user_id);
create policy "Owners delete own clips" on public.clips for delete to authenticated using (auth.uid()=user_id);
create policy "Likes are public" on public.likes for select using (true);
create policy "Users like as themselves" on public.likes for insert to authenticated with check (auth.uid()=user_id);
create policy "Users remove own likes" on public.likes for delete to authenticated using (auth.uid()=user_id);
-- Crear perfil automáticamente al registrarse (username inicial derivado del email).
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id,username)
  values(new.id, 'player_' || substr(new.id::text,1,8))
  on conflict (id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
-- Bucket público para reproducir clips. La app limita el tamaño a 100 MB en cliente.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('clips','clips',true,104857600,array['video/mp4','video/webm','video/quicktime'])
on conflict (id) do update set public=true,file_size_limit=104857600,
allowed_mime_types=array['video/mp4','video/webm','video/quicktime'];
create policy "Anyone can view clip files" on storage.objects for select using (bucket_id='clips');
create policy "Users upload to own folder" on storage.objects for insert to authenticated
with check (bucket_id='clips' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "Users delete own files" on storage.objects for delete to authenticated
using (bucket_id='clips' and (storage.foldername(name))[1]=auth.uid()::text);
