drop extension if exists "pg_net";


  create table "public"."friendships" (
    "id" uuid not null default gen_random_uuid(),
    "requester_id" uuid not null,
    "addressee_id" uuid not null,
    "status" text not null default 'pending'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."friendships" enable row level security;


  create table "public"."pinned_locations" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "name" text not null default 'Unnamed place'::text,
    "emoji" text not null default '📍'::text,
    "latitude" double precision not null,
    "longitude" double precision not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."pinned_locations" enable row level security;


  create table "public"."places" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "name" text,
    "category" text,
    "latitude" double precision,
    "longitude" double precision,
    "provider" text,
    "provider_place_id" text
      );


alter table "public"."places" enable row level security;


  create table "public"."profiles" (
    "id" uuid not null,
    "username" text not null,
    "display_name" text not null,
    "avatar_url" text default ''::text,
    "bio" text default ''::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "birthday" date
      );


alter table "public"."profiles" enable row level security;


  create table "public"."user_pins" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "user_id" uuid,
    "place_id" uuid,
    "custom_name" text,
    "emoji" text,
    "visibility" text,
    "is_private" boolean,
    "ratings" smallint,
    "reviews" text
      );


alter table "public"."user_pins" enable row level security;

CREATE UNIQUE INDEX friendships_pair_uniq ON public.friendships USING btree (LEAST(requester_id, addressee_id), GREATEST(requester_id, addressee_id));

CREATE UNIQUE INDEX friendships_pkey ON public.friendships USING btree (id);

CREATE UNIQUE INDEX friendships_requester_id_addressee_id_key ON public.friendships USING btree (requester_id, addressee_id);

CREATE UNIQUE INDEX pinned_locations_pkey ON public.pinned_locations USING btree (id);

CREATE UNIQUE INDEX places_pkey ON public.places USING btree (id);

CREATE UNIQUE INDEX profiles_pkey1 ON public.profiles USING btree (id);

CREATE UNIQUE INDEX profiles_username_key1 ON public.profiles USING btree (username);

CREATE UNIQUE INDEX user_pins_pkey ON public.user_pins USING btree (id);

alter table "public"."friendships" add constraint "friendships_pkey" PRIMARY KEY using index "friendships_pkey";

alter table "public"."pinned_locations" add constraint "pinned_locations_pkey" PRIMARY KEY using index "pinned_locations_pkey";

alter table "public"."places" add constraint "places_pkey" PRIMARY KEY using index "places_pkey";

alter table "public"."profiles" add constraint "profiles_pkey1" PRIMARY KEY using index "profiles_pkey1";

alter table "public"."user_pins" add constraint "user_pins_pkey" PRIMARY KEY using index "user_pins_pkey";

alter table "public"."friendships" add constraint "friendships_addressee_id_fkey" FOREIGN KEY (addressee_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."friendships" validate constraint "friendships_addressee_id_fkey";

alter table "public"."friendships" add constraint "friendships_check" CHECK ((requester_id <> addressee_id)) not valid;

alter table "public"."friendships" validate constraint "friendships_check";

alter table "public"."friendships" add constraint "friendships_requester_id_addressee_id_key" UNIQUE using index "friendships_requester_id_addressee_id_key";

alter table "public"."friendships" add constraint "friendships_requester_id_fkey" FOREIGN KEY (requester_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."friendships" validate constraint "friendships_requester_id_fkey";

alter table "public"."friendships" add constraint "friendships_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'blocked'::text]))) not valid;

alter table "public"."friendships" validate constraint "friendships_status_check";

alter table "public"."pinned_locations" add constraint "pinned_locations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."pinned_locations" validate constraint "pinned_locations_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey1" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey1";

alter table "public"."profiles" add constraint "profiles_username_key1" UNIQUE using index "profiles_username_key1";

alter table "public"."user_pins" add constraint "user_pins_place_id_fkey" FOREIGN KEY (place_id) REFERENCES public.places(id) ON DELETE CASCADE not valid;

alter table "public"."user_pins" validate constraint "user_pins_place_id_fkey";

alter table "public"."user_pins" add constraint "user_pins_ratings_check" CHECK (((ratings >= 0) AND (ratings <= 5))) not valid;

alter table "public"."user_pins" validate constraint "user_pins_ratings_check";

alter table "public"."user_pins" add constraint "user_pins_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."user_pins" validate constraint "user_pins_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.profiles (id, username, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || substr(NEW.id::text, 1, 8)),
    NEW.raw_user_meta_data->>'display_name'
  );
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

grant delete on table "public"."friendships" to "anon";

grant insert on table "public"."friendships" to "anon";

grant references on table "public"."friendships" to "anon";

grant select on table "public"."friendships" to "anon";

grant trigger on table "public"."friendships" to "anon";

grant truncate on table "public"."friendships" to "anon";

grant update on table "public"."friendships" to "anon";

grant delete on table "public"."friendships" to "authenticated";

grant insert on table "public"."friendships" to "authenticated";

grant references on table "public"."friendships" to "authenticated";

grant select on table "public"."friendships" to "authenticated";

grant trigger on table "public"."friendships" to "authenticated";

grant truncate on table "public"."friendships" to "authenticated";

grant update on table "public"."friendships" to "authenticated";

grant delete on table "public"."friendships" to "service_role";

grant insert on table "public"."friendships" to "service_role";

grant references on table "public"."friendships" to "service_role";

grant select on table "public"."friendships" to "service_role";

grant trigger on table "public"."friendships" to "service_role";

grant truncate on table "public"."friendships" to "service_role";

grant update on table "public"."friendships" to "service_role";

grant delete on table "public"."pinned_locations" to "anon";

grant insert on table "public"."pinned_locations" to "anon";

grant references on table "public"."pinned_locations" to "anon";

grant select on table "public"."pinned_locations" to "anon";

grant trigger on table "public"."pinned_locations" to "anon";

grant truncate on table "public"."pinned_locations" to "anon";

grant update on table "public"."pinned_locations" to "anon";

grant delete on table "public"."pinned_locations" to "authenticated";

grant insert on table "public"."pinned_locations" to "authenticated";

grant references on table "public"."pinned_locations" to "authenticated";

grant select on table "public"."pinned_locations" to "authenticated";

grant trigger on table "public"."pinned_locations" to "authenticated";

grant truncate on table "public"."pinned_locations" to "authenticated";

grant update on table "public"."pinned_locations" to "authenticated";

grant delete on table "public"."pinned_locations" to "service_role";

grant insert on table "public"."pinned_locations" to "service_role";

grant references on table "public"."pinned_locations" to "service_role";

grant select on table "public"."pinned_locations" to "service_role";

grant trigger on table "public"."pinned_locations" to "service_role";

grant truncate on table "public"."pinned_locations" to "service_role";

grant update on table "public"."pinned_locations" to "service_role";

grant delete on table "public"."places" to "anon";

grant insert on table "public"."places" to "anon";

grant references on table "public"."places" to "anon";

grant select on table "public"."places" to "anon";

grant trigger on table "public"."places" to "anon";

grant truncate on table "public"."places" to "anon";

grant update on table "public"."places" to "anon";

grant delete on table "public"."places" to "authenticated";

grant insert on table "public"."places" to "authenticated";

grant references on table "public"."places" to "authenticated";

grant select on table "public"."places" to "authenticated";

grant trigger on table "public"."places" to "authenticated";

grant truncate on table "public"."places" to "authenticated";

grant update on table "public"."places" to "authenticated";

grant delete on table "public"."places" to "service_role";

grant insert on table "public"."places" to "service_role";

grant references on table "public"."places" to "service_role";

grant select on table "public"."places" to "service_role";

grant trigger on table "public"."places" to "service_role";

grant truncate on table "public"."places" to "service_role";

grant update on table "public"."places" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."user_pins" to "anon";

grant insert on table "public"."user_pins" to "anon";

grant references on table "public"."user_pins" to "anon";

grant select on table "public"."user_pins" to "anon";

grant trigger on table "public"."user_pins" to "anon";

grant truncate on table "public"."user_pins" to "anon";

grant update on table "public"."user_pins" to "anon";

grant delete on table "public"."user_pins" to "authenticated";

grant insert on table "public"."user_pins" to "authenticated";

grant references on table "public"."user_pins" to "authenticated";

grant select on table "public"."user_pins" to "authenticated";

grant trigger on table "public"."user_pins" to "authenticated";

grant truncate on table "public"."user_pins" to "authenticated";

grant update on table "public"."user_pins" to "authenticated";

grant delete on table "public"."user_pins" to "service_role";

grant insert on table "public"."user_pins" to "service_role";

grant references on table "public"."user_pins" to "service_role";

grant select on table "public"."user_pins" to "service_role";

grant trigger on table "public"."user_pins" to "service_role";

grant truncate on table "public"."user_pins" to "service_role";

grant update on table "public"."user_pins" to "service_role";


  create policy "friendships_delete_own"
  on "public"."friendships"
  as permissive
  for delete
  to authenticated
using (((auth.uid() = requester_id) OR (auth.uid() = addressee_id)));



  create policy "friendships_insert_as_requester"
  on "public"."friendships"
  as permissive
  for insert
  to authenticated
with check (((auth.uid() = requester_id) AND (status = 'pending'::text)));



  create policy "friendships_select_own"
  on "public"."friendships"
  as permissive
  for select
  to authenticated
using (((auth.uid() = requester_id) OR (auth.uid() = addressee_id)));



  create policy "friendships_update_by_addressee"
  on "public"."friendships"
  as permissive
  for update
  to authenticated
using ((auth.uid() = addressee_id))
with check ((auth.uid() = addressee_id));



  create policy "Users can create their own pins"
  on "public"."pinned_locations"
  as permissive
  for insert
  to authenticated
with check ((auth.uid() = user_id));



  create policy "Users can delete their own pins"
  on "public"."pinned_locations"
  as permissive
  for delete
  to authenticated
using ((auth.uid() = user_id));



  create policy "Users can read their own pins"
  on "public"."pinned_locations"
  as permissive
  for select
  to authenticated
using ((auth.uid() = user_id));



  create policy "Users can update their own pins"
  on "public"."pinned_locations"
  as permissive
  for update
  to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "Users can insert own profile"
  on "public"."profiles"
  as permissive
  for insert
  to authenticated
with check ((auth.uid() = id));



  create policy "Users can update own profile"
  on "public"."profiles"
  as permissive
  for update
  to authenticated
using ((auth.uid() = id))
with check ((auth.uid() = id));



  create policy "Users can view own profile"
  on "public"."profiles"
  as permissive
  for select
  to authenticated
using ((auth.uid() = id));


CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


