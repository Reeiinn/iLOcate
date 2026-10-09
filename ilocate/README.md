# iLOcate

A Flutter app for getting around Iloilo City: jeepney (PUJ) routes on a map, plus a guide to local places and food.

**Member:** Reinwel G. Tingson ([@Reeiinn](https://github.com/Reeiinn)), working individually

> This is an early prototype for the SE2142 Final Project. The landmark list, photos, and PUJ route data come from my earlier iLOcate web app.

## What works so far

- **Map**: OpenStreetMap tiles with 98 landmarks as pins. Tap a pin to preview the place.
- **Jeepney routes**: pick any of the 27 PUJ routes from the Routes button to draw them on the map.
- **Places & Food**: search and filter by category (Food, Cafe, Church, Museum, and others).
- **Place details**: photo, category, and a small map of the location.
- **Likes**: heart a place to add it to the Likes tab.

## Not done yet

- Trip planner and directions (OSRM)
- Turn-by-turn navigation and live GPS location
- Likes are kept in memory only and reset when the app is closed
- Optional local login / sign up

## Running it

```
flutter pub get
flutter run
```

The map tiles need an internet connection.
