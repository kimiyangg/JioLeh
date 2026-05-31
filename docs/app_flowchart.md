# JioLeh! — App Flowchart

This diagram describes the runtime flow of the current Flutter app: bootstrap,
the auth gate that routes between sign-in / onboarding / map, and the map
experience (location tracking, pins, profile).

```mermaid
flowchart TD
    Start([App launch]) --> Boot

    subgraph Bootstrap["main.dart — Bootstrap"]
        Boot["WidgetsFlutterBinding.ensureInitialized()"]
        Boot --> Validate["ValidateEnv.validateEnvironment()"]
        Validate --> Mapbox["MapboxOptions.setAccessToken()"]
        Mapbox --> Supa["Supabase.initialize(url, anonKey)"]
        Supa --> RunApp["runApp(MyApp)"]
    end

    RunApp --> Gate

    subgraph AuthGate["app.dart — AuthGate (listens to authStateChanges)"]
        Gate{"isSignedIn()?"}
        Gate -->|No| SignedOut["State: signedOut"]
        Gate -->|Yes| Loading["State: loading"]
        Loading --> ProfileCheck{"profileExists()?<br/>(query profiles table)"}
        ProfileCheck -->|Error| ErrState["State: error"]
        ProfileCheck -->|No| NeedsOnb["State: needsOnboarding"]
        ProfileCheck -->|Yes| Ready["State: ready"]
        ErrState --> Retry["Show 'Something went wrong' + Retry"]
        Retry -->|tap Retry| Gate
    end

    SignedOut --> AuthPage
    NeedsOnb --> Onboarding
    Ready --> MapPage

    subgraph Auth["AuthPage"]
        AuthPage["Show JioLeh! brand + 'Continue with Google'"]
        AuthPage -->|tap| GoogleSignIn["AuthServices.signInWithGoogle()<br/>(Supabase OAuth → Google)"]
        GoogleSignIn -->|success: auth state changes| Gate
        GoogleSignIn -->|error| AuthErr["SnackBar: 'Unexpected Error.'"]
        AuthErr --> AuthPage
    end

    subgraph Onb["OnboardingPage"]
        Onboarding["Prefill display name from Google metadata"]
        Onboarding --> Form["Enter username, display name, pick birthday"]
        Form -->|tap Continue| CreateProfile["AccountServices.createProfile()<br/>(insert profiles row)"]
        CreateProfile -->|success| OnComplete["onComplete() → re-resolve gate"]
        OnComplete --> Gate
        CreateProfile -->|error| OnbErr["SnackBar: 'Could not save profile'"]
        OnbErr --> Form
    end

    subgraph Map["MapPage"]
        MapPage["initState → _booting()"]
        MapPage --> ReloadPins["_reloadPins()<br/>PinServices.loadPinnedLocations()"]
        ReloadPins --> TrackLoc["_startLocationTracking()"]
        TrackLoc --> Perm{"ensureLocationPermission()"}
        Perm -->|denied / off / blocked| LocDialog["Show location error dialog<br/>(Retry / open settings)"]
        LocDialog -->|Retry| TrackLoc
        Perm -->|granted| GetPos["getCurrentLocation()"]
        GetPos --> Viewport["Set viewport + show map"]
        Viewport --> Geocode["GeoCodingServices.fetchAreaName()<br/>→ current area bar"]
        Viewport --> Stream["startLocationTracking()<br/>(live position stream)"]
        Stream -->|on update| Geocode

        MapUI["Map UI overlays"]
        Viewport --> MapUI
        MapUI --> Recenter["Toolbar: Recenter → _moveCameraToPos()"]
        MapUI --> AddPin["Toolbar: Add pin → _addPin()<br/>savePinnedLocation() → _reloadPins()"]
        MapUI --> Profile["Profile button → ProfilePage<br/>(getUserProfile())"]
        MapUI --> Logout["Logout button → AuthServices.signOut()"]
        Logout -->|auth state changes| Gate
    end
```

## Key components

| Layer | Files |
|---|---|
| Bootstrap | `lib/main.dart`, `lib/config/` |
| Routing / auth gate | `lib/app.dart` |
| Pages | `lib/pages/auth_page.dart`, `onboarding_page.dart`, `map_page.dart`, `profile_page.dart` |
| Services | `lib/services/auth_services.dart`, `account_services.dart`, `pin_services.dart`, `location_services.dart`, `geocoding_services.dart` |
| Backend | Supabase Auth (Google OAuth), Postgres (`profiles`, `pinned_locations`), Mapbox |
