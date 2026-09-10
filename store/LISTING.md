# Play Store listing — Nourish me Bro

Everything Google asks for, written out so it can be pasted in. Assets in this
folder are already the right sizes.

Package name: `io.github.prasangr.nourishmebro`  (permanent, cannot change)
Category: Health & Fitness · Free · Contains ads: **No** · In-app purchases: **No**
Privacy policy: https://prasangr.github.io/NourishMeBro1/privacy.html

## App name (30 char limit)

    Nourish me Bro

## Short description (80 char limit)

    A calorie and habit tracker that counts in bowls and plates, not grams.

## Full description

    Every calorie app wants a number you do not have. Grams of rice. Grams of
    chicken. You did not weigh any of it, so you guess — and after a week of
    guessing badly, you stop opening the app.

    Nourish me Bro counts the way people actually eat. One bowl. One plate. Two
    slices. A medium banana. Pick the food, pick how much, done. No scale, no
    conversions, no pretending you measured lunch.

    WHAT IT DOES

    • Log a meal in a couple of taps, or just type what you ate on one line
    • See calories, protein, carbs, fat and fibre against your own targets
    • Track daily habits and streaks — workout, sleep, steps, whatever you pick
    • Log water by the glass
    • A weekly summary that tells you one useful thing, and says so plainly when
      the week was fine
    • Works offline; your logs sync when you are back online
    • Add your own foods when something is missing

    WHAT IT DOES NOT DO

    No ads. No subscription. No streak-shaming notifications, no social feed,
    nothing sold to anybody.

    Your logs live in your own account and are visible only to you. You can
    erase everything from inside the app at any time.

## Graphics (already in this folder)

| Asset | File | Size |
|---|---|---|
| App icon | `../icon-512.png` | 512×512 |
| Feature graphic | `feature-graphic.png` | 1024×500 |
| Phone screenshots | `01-today.png` … `04-you.png` | 1080×1920 |

## App access — DO NOT SKIP

The app is behind a sign-in, so a reviewer who cannot get in will reject it.
Under **App access**, choose "All or some functionality is restricted" and give
a demo account: make a throwaway email/password account in the app, log a
couple of days in it so it does not look empty, and paste those credentials in.

## Data safety answers

Collected, linked to the user, **not** shared with anyone, all encrypted in
transit, all deletable in-app (You → Your data → Erase everything):

| Data | Purpose | Required? |
|---|---|---|
| Email address | Account management | Yes |
| Name | App functionality | Optional |
| Health & fitness (food logs, habits, water) | App functionality | Optional |
| Body info (age, sex, height, weight) | App functionality — calorie target | Optional |

Answer **No** to: advertising or marketing, analytics, data sharing with third
parties, location, contacts, photos, files, device IDs. The app requests no
Android permissions at all.

## Content rating questionnaire

Health app, no violence, no sexual content, no gambling, no user-generated
content, no sharing of user data with other users, no ads. Result should be
Everyone / PEGI 3.

## Target audience

Choose **18 and over**. Anything including under-13 pulls the app into the
Families policy, which requires more paperwork than this app is worth.

## Release order

1. Internal testing — install it yourself, confirm no address bar at the top
   (if there is one, `assetlinks.json` and Play's signing key disagree).
2. Closed testing — needs 12 testers who stay opted in for 14 days.
3. Apply for production access, then roll out.
