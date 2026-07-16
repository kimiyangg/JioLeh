# Demo community setup

The onboarding checkbox **Join the demo community** is always visible. When a
new user selects it, the app calls the `join_demo_community` Supabase function.
That function creates sample content only for the signed-in user; it is safe to
call more than once because each user can enrol only once.

## One-time setup

1. Apply `20260716170000_demo_community.sql` to the Supabase project.
2. Create three ordinary Auth users for the demo personas and complete their
   JioLeh profiles. Use clearly artificial names, such as `Demo Mia`,
   `Demo Kai`, and `Demo Noor`.
3. In the Supabase SQL editor, register their profile IDs in the chosen order:

```sql
insert into public.demo_community_bots (profile_id, display_order) values
  ('<mia-profile-id>', 1),
  ('<kai-profile-id>', 2),
  ('<noor-profile-id>', 3);
```

Do not use real users as demo personas. The migration deliberately does not
create Auth users or store passwords.

## What a tester receives

- Three accepted demo friends
- Three friend-visible recommendation pins around a sample map area
- One pending “Demo coffee catch-up” OpenJio invitation
- Existing messages from the demo friends; they become visible after the tester
  accepts the invitation

Use a blank onboarding account when testing the true first-use experience:
leave the checkbox unchecked.
