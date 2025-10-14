# Flutter Todo List (Firebase)

Application Flutter de todo-list avec gestion des **utilisateurs**, **catégories** et **tâches** (temps réel via Firestore).

## ✨ Fonctionnalités

- Authentification (Email/Mot de passe via Firebase Auth)
- Données par utilisateur :
  - `users/{uid}/categories/{categoryId}` : nom, description, couleur (hex), icône (codePoint), ordre
  - `users/{uid}/todos/{todoId}` : titre, terminé ?, échéance, catégorie
- Onglets par catégorie + “Non classés” + “Tous (ouverts)”
- CRUD complet (Catégories, Todos)
- Firestore en **temps réel**

---

## 🧱 Prérequis

- **Flutter** 3.35+ / **Dart** 3.9+
- **Firebase CLI** (`firebase --version`)
- **flutterfire_cli** (`dart pub global activate flutterfire_cli`)
- Android Studio (avec emulateur installer) / Xcode / Chrome selon la cible

Vérification rapide :

```bash
flutter --version
dart --version
firebase --version
```

## Démarrage

1. Cloner et installer :

```bash
git clone https://github.com/marieesss/flutter-todo-list
cd flutter-todo-list
flutter pub get
```

2. Lancer l'app :

```bash
# Web
flutter run -d chrome
# Android (exemple)
flutter devices
flutter run -d <deviceId>
# iOS (macOS requis)
flutter run -d ios
# Desktop (Windows/macOS/Linux si activé)
flutter config --enable-windows-desktop
flutter run -d windows
```

## Firebase Configuration

Nom du projet firebase :

```bash
boris-flutter-todo-2025
```

Règles sur la base de données :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      match /categories/{categoryId} {
        allow read: if request.auth != null && request.auth.uid == uid;

        allow create: if request.auth != null
                      && request.auth.uid == uid
                      && request.resource.data.keys()
                        .hasOnly(['name','description','color','icon','order','createdAt','updatedAt'])
                      && request.resource.data.name is string
                      && request.resource.data.name.size() > 0
                      && request.resource.data.description is string
                      && request.resource.data.color is string
                      && request.resource.data.icon is int;

        allow update: if request.auth != null
                      && request.auth.uid == uid
                      && request.resource.data.diff(resource.data)
                        .changedKeys().hasOnly(['name','description','color','icon','order','updatedAt'])
                      && request.resource.data.color is string;

        allow delete: if request.auth != null && request.auth.uid == uid;
      }

      match /categories/{categoryId}/todos/{todoId}{
        allow read: if request.auth != null && request.auth.uid == uid;

        function categoryExists(catId) {
          return catId == null
                 || exists(/databases/$(database)/documents/users/$(uid)/categories/$(catId));
        }

        allow create: if request.auth != null
                      && request.auth.uid == uid
                      && request.resource.data.keys()
                        .hasOnly(['title','isDone','dueAt','categoryId','createdAt','updatedAt'])
                      && request.resource.data.title is string
                      && request.resource.data.title.size() > 0
                      && request.resource.data.isDone is bool
                      && categoryExists(request.resource.data.categoryId);

        allow update: if request.auth != null
                      && request.auth.uid == uid
                      && request.resource.data.diff(resource.data)
                        .changedKeys().hasOnly(['title','isDone','dueAt','categoryId','updatedAt'])
                      && categoryExists(categoryId);

        allow delete: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
}
```

```yaml
users/{uid}
  profile: { displayName, createdAt, email, name, photoURL, updatedAt }

users/{uid}/categories/{categoryId}
  {
    name: string,
    description: string,
    color: "#RRGGBB",
    icon: int,
    order: number,
    createdAt: Timestamp,
    updatedAt: Timestamp
  }

users/{uid}/todos/{todoId}
  {
    title: string,
    isDone: bool,
    dueAt: Timestamp|null,
    categoryId: string|null,
    createdAt: Timestamp,
    updatedAt: Timestamp
  }
```
