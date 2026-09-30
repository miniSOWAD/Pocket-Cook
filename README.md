<img src="https://capsule-render.vercel.app/api?type=waving&color=0:C62828,50:E64A19,100:F9A825&height=270&section=header&text=Pocket%20Cook&fontSize=80&fontColor=ffffff&animation=fadeIn&fontAlignY=36&desc=Smart%20Recipe%20Management%20and%20Cooking%20Assistant&descSize=22&descAlignY=56" alt="Pocket Cook: Smart Recipe Management and Cooking Assistant" width="100%" />

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=22&duration=3200&pause=900&color=E64A19&center=true&vCenter=true&width=720&height=48&lines=Discover+recipes+and+save+your+favorites;Track+your+pantry+and+build+grocery+lists;Plan+your+meals+with+ease;Cook+with+what+you+already+have" alt="Discover recipes, track your pantry, plan your meals and cook with what you already have" />

**A Flutter-based recipe and cooking assistant application powered by Firebase.**

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Cloud_Firestore-E65100?style=for-the-badge&logo=firebase&logoColor=white" alt="Cloud Firestore" />
  <img src="https://img.shields.io/badge/Cloud_Functions-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Cloud Functions" />
  <img src="https://img.shields.io/badge/Provider-7B1FA2?style=for-the-badge" alt="Provider state management" />
</p>

<p>
  <a href="#features"><img src="https://img.shields.io/badge/Features-C62828?style=flat-square" alt="Features" /></a>
  <a href="#tech-stack"><img src="https://img.shields.io/badge/Tech_Stack-C62828?style=flat-square" alt="Tech stack" /></a>
  <a href="#architecture"><img src="https://img.shields.io/badge/Architecture-C62828?style=flat-square" alt="Architecture" /></a>
  <a href="#firebase-apis"><img src="https://img.shields.io/badge/Firebase_APIs-C62828?style=flat-square" alt="Firebase APIs" /></a>
  <a href="#roles"><img src="https://img.shields.io/badge/Roles-C62828?style=flat-square" alt="Roles" /></a>
  <a href="#make-ur-plate"><img src="https://img.shields.io/badge/Make_Ur_Plate-C62828?style=flat-square" alt="Make Ur Plate" /></a>
  <a href="#getting-started"><img src="https://img.shields.io/badge/Getting_Started-C62828?style=flat-square" alt="Getting started" /></a>
  <a href="#roadmap"><img src="https://img.shields.io/badge/Roadmap-C62828?style=flat-square" alt="Roadmap" /></a>
</p>

</div>

<a id="features"></a>

## ✨ Features

<table width="100%">
  <tr>
    <td align="center" width="25%">
      <b>🍲 Recipe discovery</b><br />
      <sub>Browse recipes with images, ingredients and cooking steps</sub>
    </td>
    <td align="center" width="25%">
      <b>🔍 Search</b><br />
      <sub>Find the recipe you are looking for, fast</sub>
    </td>
    <td align="center" width="25%">
      <b>❤️ Favorites</b><br />
      <sub>Save the recipes you love</sub>
    </td>
    <td align="center" width="25%">
      <b>🥕 Pantry management</b><br />
      <sub>Keep track of the ingredients you have</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <b>🛒 Grocery lists</b><br />
      <sub>Organize what you need to buy</sub>
    </td>
    <td align="center">
      <b>📅 Meal planning</b><br />
      <sub>Plan your meals ahead of time</sub>
    </td>
    <td align="center">
      <b>🍽️ Make Ur Plate</b><br />
      <sub>Recipe recommendations based on your ingredients</sub>
    </td>
    <td align="center">
      <b>🔐 Role management</b><br />
      <sub>Admin, Cook and Visitor roles</sub>
    </td>
  </tr>
</table>

<a id="tech-stack"></a>

## 🧰 Tech stack

| 🎨 Frontend | ☁️ Backend |
| :-- | :-- |
| Flutter | Firebase Authentication |
| Dart | Cloud Firestore |
| Provider (state management) | Cloud Functions |
| Material UI | Firebase Admin SDK |
| Shared Preferences | Firebase Storage *(optional)* |

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:C62828,50:E64A19,100:F9A825&height=130&section=header&text=Under%20the%20Hood&fontSize=36&fontColor=ffffff&animation=fadeIn&fontAlignY=38" alt="Under the hood" width="100%" />

<a id="architecture"></a>

## 🏗️ Architecture

### Application overview

```mermaid
flowchart TB
    APP["Flutter application"]

    subgraph FB["Firebase backend"]
        AUTH["Authentication"]
        FS["Cloud Firestore"]
        CF["Cloud Functions"]
        ADM["Admin SDK"]
        ST["Storage (optional)"]
    end

    APP --> AUTH
    APP --> FS
    APP --> CF
    APP -.-> ST
    CF --> ADM

    classDef client fill:#FFF5F2,stroke:#C62828,stroke-width:2px,color:#3E2723
    classDef backend fill:#F4FBF1,stroke:#2E7D32,stroke-width:2px,color:#1B3A1F
    class APP client
    class AUTH,FS,CF,ADM,ST backend
    style FB fill:#FAFFF7,stroke:#2E7D32,stroke-width:2px,stroke-dasharray: 6 4,color:#1B5E20
    linkStyle default stroke:#E64A19,stroke-width:2px
```

### Frontend structure

The app follows a **feature-based** Flutter architecture.

```text
lib/
├── app/
├── core/
└── features/
    ├── auth/
    ├── recipes/
    ├── favorites/
    ├── pantry/
    ├── grocery/
    ├── meal_plan/
    ├── profile/
    ├── admin/
    └── cook/
```

Data moves from the screen down to Firebase in this order:

```mermaid
flowchart LR
    S["Screen"] --> P["Provider"] --> R["Repository"] --> SDK["Firebase SDK"] --> SVC["Firebase service"]

    classDef client fill:#FFF5F2,stroke:#C62828,stroke-width:2px,color:#3E2723
    classDef backend fill:#F4FBF1,stroke:#2E7D32,stroke-width:2px,color:#1B3A1F
    class S,P,R,SDK client
    class SVC backend
    linkStyle default stroke:#E64A19,stroke-width:2px
```

<a id="firebase-apis"></a>

## 🔥 Firebase APIs used

### Firebase Authentication

> Package: `firebase_auth`

- Register users
- Login users
- Logout
- Password reset
- User identity management

```mermaid
flowchart LR
    L["User login"] --> A["Firebase Authentication"] --> U["UID generated"] --> F["Firestore account created"] --> X["Application access"]

    classDef client fill:#FFF5F2,stroke:#C62828,stroke-width:2px,color:#3E2723
    classDef backend fill:#F4FBF1,stroke:#2E7D32,stroke-width:2px,color:#1B3A1F
    class L,X client
    class A,U,F backend
    linkStyle default stroke:#E64A19,stroke-width:2px
```

### Cloud Firestore

> Package: `cloud_firestore`

Used as the main database.

<table>
  <tr>
    <th align="left" colspan="2">Stores</th>
  </tr>
  <tr valign="top">
    <td>
      <ul>
        <li>Recipes</li>
        <li>Users</li>
        <li>Roles</li>
        <li>Favorites</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Pantry items</li>
        <li>Grocery lists</li>
        <li>Meal plans</li>
        <li>Requests</li>
      </ul>
    </td>
  </tr>
</table>

```text
Cloud Firestore
├── accounts/{uid}
├── recipes/{recipeId}
├── users/{uid}/
│   ├── favorites
│   └── pantryItems
├── cookApplications
└── recipeRequests
```

### Cloud Functions

Used for secure backend operations, for example:

- Admin user management
- Delete users
- Block users
- Change roles

```mermaid
flowchart LR
    APP["Flutter app"] --> CALL["Callable function"] --> CF["Cloud Function"] --> ADM["Firebase Admin SDK"] --> SVC["Firebase services"]

    classDef client fill:#FFF5F2,stroke:#C62828,stroke-width:2px,color:#3E2723
    classDef backend fill:#F4FBF1,stroke:#2E7D32,stroke-width:2px,color:#1B3A1F
    class APP,CALL client
    class CF,ADM,SVC backend
    linkStyle default stroke:#E64A19,stroke-width:2px
```

### Firebase Admin SDK

> [!WARNING]
> The Admin SDK is used only in backend environments, never inside the Flutter app.

It is responsible for:

- Creating administrators
- Managing authentication users
- Updating roles
- Privileged operations

<a id="roles"></a>

## 🔐 Role management

Pocket Cook has three roles.

<table width="100%">
  <tr>
    <th align="center" width="33%">👀 Visitor</th>
    <th align="center" width="33%">🧑‍🍳 Cook</th>
    <th align="center" width="33%">👑 Admin</th>
  </tr>
  <tr valign="top">
    <td>
      <ul>
        <li>Browse recipes</li>
        <li>Search recipes</li>
        <li>Save favorites</li>
        <li>Request recipes</li>
        <li>Apply to become Cook</li>
      </ul>
    </td>
    <td>
      <ul>
        <li><b>Everything a Visitor can do</b></li>
        <li>Add recipes</li>
        <li>Edit recipes</li>
        <li>Manage own recipes</li>
      </ul>
    </td>
    <td>
      <b>Full authority</b>
      <ul>
        <li>Manage users</li>
        <li>Delete users</li>
        <li>Block users</li>
        <li>Promote users</li>
        <li>Approve Cook requests</li>
        <li>Manage all recipes</li>
      </ul>
    </td>
  </tr>
</table>

A Visitor becomes a Cook by applying, and an Admin approves the request:

```mermaid
flowchart LR
    V["Visitor"] -->|"applies to become Cook"| R{"Admin review"}
    R -->|"approved"| C["Cook"]

    classDef client fill:#FFF5F2,stroke:#C62828,stroke-width:2px,color:#3E2723
    class V,R,C client
    linkStyle default stroke:#E64A19,stroke-width:2px
```

## 🍲 Recipe system

Every recipe contains:

<table width="100%">
  <tr>
    <td align="center">📝 <b>Title</b></td>
    <td align="center">📖 <b>Description</b></td>
    <td align="center">🖼️ <b>Image</b></td>
  </tr>
  <tr>
    <td align="center">🥕 <b>Ingredients</b></td>
    <td align="center">👩‍🍳 <b>Cooking steps</b></td>
    <td align="center">🏷️ <b>Category</b></td>
  </tr>
  <tr>
    <td align="center">📊 <b>Difficulty</b></td>
    <td align="center">⏱️ <b>Preparation time</b></td>
    <td align="center">👤 <b>Creator information</b></td>
  </tr>
</table>

Recipes live in Firestore at `recipes/{recipeId}`. Example fields:

| Field | Holds |
| :-- | :-- |
| `title` | The recipe name |
| `ingredients` | The ingredient list |
| `steps` | The cooking steps |
| `imageUrl` | The recipe image |
| `createdByUid` | The UID of the creator |
| `cookName` | The name of the Cook who created it |

<a id="make-ur-plate"></a>

## 🍽️ Make Ur Plate

A smart recommendation feature. You enter the ingredients you have:

| Ingredient | Amount |
| :-- | --: |
| Chicken | 500 g |
| Rice | 1 kg |
| Egg | 3 pcs |

The system then works through four steps:

```mermaid
flowchart LR
    I["Your ingredients"] --> N["1. Normalize ingredients"] --> C["2. Compare with recipes"] --> M["3. Calculate match percentage"] --> R["4. Show possible recipes"]

    classDef client fill:#FFF5F2,stroke:#C62828,stroke-width:2px,color:#3E2723
    class I,N,C,M,R client
    linkStyle default stroke:#E64A19,stroke-width:2px
```

Example result:

> **🍚 Chicken Rice Bowl**
>
> <img src="https://img.shields.io/badge/Match-95%25-2E7D32?style=for-the-badge" alt="Match 95%" /> <img src="https://img.shields.io/badge/Missing-Garlic-C62828?style=for-the-badge" alt="Missing: Garlic" />

## 🥕 Pantry system

Users maintain the ingredients they have available:

| Ingredient | Amount |
| :-- | --: |
| Chicken | 500 g |
| Rice | 2 kg |
| Egg | 6 pcs |

The system compares pantry data with recipes.

## 🖼️ Image system

### Current approach

Recipe images are bundled with the app in `assets/images/recipes/`, and a recipe points to its image like this:

```json
{
  "imageAsset": "assets/images/recipes/rice.png"
}
```

### Future production

```mermaid
flowchart LR
    ST["Firebase Storage"] --> URL["Image URL"] --> REC["Firestore recipe"]

    classDef backend fill:#F4FBF1,stroke:#2E7D32,stroke-width:2px,color:#1B3A1F
    class ST,URL,REC backend
    linkStyle default stroke:#E64A19,stroke-width:2px
```

## 🛡️ Security architecture

> [!IMPORTANT]
> Security is enforced by backend rules, not only by hiding UI buttons.

Every request passes through these layers:

```mermaid
flowchart LR
    UI["Flutter UI"] --> RULES["Firestore rules"] --> CF["Cloud Functions"] --> ADM["Firebase Admin SDK"]

    classDef client fill:#FFF5F2,stroke:#C62828,stroke-width:2px,color:#3E2723
    classDef backend fill:#F4FBF1,stroke:#2E7D32,stroke-width:2px,color:#1B3A1F
    class UI client
    class RULES,CF,ADM backend
    linkStyle default stroke:#E64A19,stroke-width:2px
```

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:C62828,50:E64A19,100:F9A825&height=130&section=header&text=Ready%20to%20Cook&fontSize=36&fontColor=ffffff&animation=fadeIn&fontAlignY=38" alt="Ready to cook" width="100%" />

<a id="getting-started"></a>

## ⚙️ Getting started

### Setup

```bash
# 1. Install the command line tools
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# 2. Log in to Firebase
firebase login

# 3. Configure Firebase for the app
flutterfire configure

# 4. Install dependencies
flutter pub get
```

### Run the app

```bash
# Development
flutter run

# Firebase mode
flutter run --dart-define=USE_FIREBASE=true
```

### Build a release

```bash
# APK
flutter build apk --release --split-per-abi

# Google Play (app bundle)
flutter build appbundle --release
```

<a id="roadmap"></a>

## 🚀 Future improvements

- [ ] 🤖 AI recipe assistant
- [ ] 🥗 Nutrition tracking
- [ ] 📷 Barcode scanner
- [ ] 🎙️ Voice cooking mode
- [ ] 📥 Recipe import
- [ ] 👥 Social cooking community
- [ ] 🧑‍🍳 Chef profiles
- [ ] ⭐ Ratings and reviews

## 📋 Project information

| Project | Pocket Cook |
| :-- | :-- |
| Frontend | Flutter |
| Backend | Firebase |
| Database | Cloud Firestore |

<div align="center">

**Built by Md Mahruf**

<a href="https://github.com/your-username"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" /></a>
<a href="https://www.linkedin.com/in/your-username"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
<a href="mailto:you@example.com"><img src="https://img.shields.io/badge/Email-C62828?style=for-the-badge&logo=gmail&logoColor=white" alt="Email" /></a>

<sub>If Pocket Cook helps you cook something good, give it a star.</sub>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:C62828,50:E64A19,100:F9A825&height=160&section=footer&text=Happy%20Cooking&fontSize=30&fontColor=ffffff&animation=twinkling&fontAlignY=62" alt="" width="100%" />

</div>
