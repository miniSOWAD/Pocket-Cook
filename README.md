# Pocket Cook

## Smart Recipe Management & Cooking Assistant Application

Pocket Cook is a Flutter-based recipe and cooking assistant application
powered by Firebase.

It provides:

-   Recipe discovery
-   Search
-   Favorites
-   Pantry management
-   Grocery lists
-   Meal planning
-   Make Ur Plate ingredient-based recommendations
-   Admin/Cook/Visitor role management

------------------------------------------------------------------------

# Technology Stack

## Frontend

-   Flutter
-   Dart
-   Provider state management
-   Material UI
-   Shared Preferences

## Backend

-   Firebase Authentication
-   Cloud Firestore
-   Cloud Functions
-   Firebase Admin SDK
-   Firebase Storage (optional)

------------------------------------------------------------------------

# Application Architecture

    Flutter Application
            |
            |
    Firebase Backend

    Authentication
    Firestore
    Cloud Functions
    Admin SDK
    Storage

------------------------------------------------------------------------

# Frontend Architecture

The application follows feature-based Flutter architecture.

    lib/

    app/
    core/
    features/

    auth/
    recipes/
    favorites/
    pantry/
    grocery/
    meal_plan/
    profile/
    admin/
    cook/

Data flow:

    Screen
     |
    Provider
     |
    Repository
     |
    Firebase SDK
     |
    Firebase Service

------------------------------------------------------------------------

# Firebase APIs Used

## Firebase Authentication API

Package:

    firebase_auth

Purpose:

-   Register users
-   Login users
-   Logout
-   Password reset
-   User identity management

Flow:

    User Login
        |
    Firebase Authentication
        |
    UID Generated
        |
    Firestore Account Created
        |
    Application Access

------------------------------------------------------------------------

## Cloud Firestore API

Package:

    cloud_firestore

Used as the main database.

Stores:

-   Recipes
-   Users
-   Roles
-   Favorites
-   Pantry items
-   Grocery lists
-   Meal plans
-   Requests

Structure:

    accounts/{uid}

    recipes/{recipeId}

    users/{uid}/favorites

    users/{uid}/pantryItems

    cookApplications

    recipeRequests

------------------------------------------------------------------------

## Cloud Functions API

Used for secure backend operations.

Examples:

-   Admin user management
-   Delete users
-   Block users
-   Change roles

Flow:

    Flutter App

       |

    Callable Function

       |

    Cloud Function

       |

    Firebase Admin SDK

       |

    Firebase Services

------------------------------------------------------------------------

## Firebase Admin SDK

Used only in backend environments.

Responsible for:

-   Creating administrators
-   Managing authentication users
-   Updating roles
-   Privileged operations

------------------------------------------------------------------------

# Role Management

Pocket Cook has three roles.

## Visitor

Can:

-   Browse recipes
-   Search recipes
-   Save favorites
-   Request recipes
-   Apply to become Cook

## Cook

Can:

-   Everything Visitor can do
-   Add recipes
-   Edit recipes
-   Manage own recipes

## Admin

Full authority:

-   Manage users
-   Delete users
-   Block users
-   Promote users
-   Approve Cook requests
-   Manage all recipes

------------------------------------------------------------------------

# Recipe System

Recipes contain:

-   Title
-   Description
-   Image
-   Ingredients
-   Cooking steps
-   Category
-   Difficulty
-   Preparation time
-   Creator information

Database:

    recipes/{recipeId}

Example:

    {
     title,
     ingredients,
     steps,
     imageUrl,
     createdByUid,
     cookName
    }

------------------------------------------------------------------------

# Make Ur Plate System

A smart recommendation feature.

Users enter available ingredients:

Example:

    Chicken 500g
    Rice 1kg
    Egg 3 pcs

The system:

1.  Normalizes ingredients
2.  Compares with recipes
3.  Calculates match percentage
4.  Shows possible recipes

Example:

    Chicken Rice Bowl

    Match: 95%

    Missing:
    Garlic

------------------------------------------------------------------------

# Pantry System

Users maintain available ingredients.

Example:

    Chicken 500g
    Rice 2kg
    Egg 6 pcs

The system compares pantry data with recipes.

------------------------------------------------------------------------

# Image System

Current approach:

    assets/images/recipes/

Recipe example:

``` json
{
 "imageAsset":
 "assets/images/recipes/rice.png"
}
```

Future production:

    Firebase Storage

            |

    Image URL

            |

    Firestore Recipe

------------------------------------------------------------------------

# Security Architecture

Security layers:

    Flutter UI

       |

    Firestore Rules

       |

    Cloud Functions

       |

    Firebase Admin SDK

Security is enforced by backend rules, not only by hiding UI buttons.

------------------------------------------------------------------------

# Setup

Install:

    firebase-tools
    flutterfire_cli

Login:

    firebase login

Configure Firebase:

    flutterfire configure

Install dependencies:

    flutter pub get

------------------------------------------------------------------------

# Run Application

Development:

    flutter run

Firebase mode:

    flutter run --dart-define=USE_FIREBASE=true

------------------------------------------------------------------------

# Build Release

APK:

    flutter build apk --release --split-per-abi

Google Play:

    flutter build appbundle --release

------------------------------------------------------------------------

# Future Improvements

-   AI recipe assistant
-   Nutrition tracking
-   Barcode scanner
-   Voice cooking mode
-   Recipe import
-   Social cooking community
-   Chef profiles
-   Ratings and reviews

------------------------------------------------------------------------

# Project Information

Project:

Pocket Cook

Frontend:

Flutter

Backend:

Firebase

Database:

Cloud Firestore
