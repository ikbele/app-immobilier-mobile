# 🏠 ImmoApp - Application Mobile Immobilière

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Appwrite](https://img.shields.io/badge/Appwrite-1.5+-FD366E?logo=appwrite)](https://appwrite.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Application mobile **cross-platform** (iOS & Android) pour la recherche, consultation et publication d'annonces immobilières, développée avec **Flutter** et **Appwrite**.
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/fa4b8015-7825-43fb-acef-4bacf09df9de" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/b4f5204a-2a36-459a-8030-f938f69568b3" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/b6c5736a-79a6-40aa-9726-782fa02e4b51" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/62179289-37df-4cf8-b89d-658baf593945" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/e460e984-1ba8-495a-ac13-8e567edf6d57" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/1af8bd5f-2e64-47f6-8965-3c378bcd0df9" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/3c098cf1-1a2e-4660-bc3b-1d4e3d38496b" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/143588e4-563e-4f3b-841c-5aab91f112b5" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/97c0b660-c124-4ecd-bff4-016e02d3dd87" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/cd7d10b8-b0f2-424b-8796-23d3f5120978" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/05b6ff18-08fa-4af8-9565-d343ac8a6399" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/d5d313e1-d29e-40c1-b0ec-d2b5cd7d117e" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/ac9e3478-3d23-45d8-9e86-9ee33c195eb6" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/73ce2db5-5436-4312-b4f6-f74f8f082211" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/1e0fdb04-79ee-4031-a6df-7d98a1dec296" />
<img width="540" height="1200" alt="image" src="https://github.com/user-attachments/assets/19d441a3-7aea-405d-8646-9fe6d627f553" />


<p align="center">
  <img src="docs/assets/screenshots/app-preview.png" alt="App Preview" width="800">
</p>

---

## ✨ Fonctionnalités

### 🔐 Authentification
- Inscription/Connexion par email
- OAuth avec Google, Apple, GitHub
- Récupération de mot de passe
- Gestion de session sécurisée

### 🏘️ Gestion des Annonces
- Publication d'annonces (vente/location)
- Upload de photos multiples
- Modification et suppression
- Statistiques de vues

### 🔍 Recherche Avancée
- Filtres multiples (prix, type, localisation, équipements)
- Recherche géographique avec rayon
- Tri par pertinence, prix, date
- Sauvegarde des recherches

### 🗺️ Carte Interactive
- Visualisation sur Google Maps
- Markers cliquables avec infos
- Clustering de marqueurs
- Calcul d'itinéraire

### 💬 Messagerie Temps Réel
- Chat instantané entre utilisateurs
- Notifications en temps réel (Appwrite Realtime)
- Envoi d'images
- Indicateur "en train d'écrire"

### ⭐ Favoris
- Sauvegarde de propriétés
- Accès rapide
- Synchronisation cloud

### 🔔 Notifications
- Push notifications (Firebase Cloud Messaging)
- Alertes de nouveaux messages
- Changements de prix
- Nouvelles annonces correspondant aux critères

### 📱 Expérience Utilisateur
- Mode offline (cache local)
- Interface Material Design 3
- Animations fluides
- Support mode sombre

---

## 🛠️ Technologies

### Frontend Mobile

| Technologie | Description |
|-------------|-------------|
| **Flutter 3.16+** | Framework UI cross-platform |
| **Dart 3.0+** | Langage de programmation |
| **flutter_bloc** | State management (BLoC pattern) |
| **get_it + injectable** | Dependency injection |
| **go_router** | Navigation déclarative |
| **Hive** | Base de données locale |
| **cached_network_image** | Cache d'images optimisé |

### Backend (Appwrite)

| Service | Usage |
|---------|-------|
| **Account API** | Authentification et gestion utilisateurs |
| **Databases** | Stockage des annonces, messages, favoris |
| **Storage** | Photos et fichiers |
| **Realtime** | Messagerie temps réel via WebSocket |
| **Functions** | Recherche géographique serverless |

**Deployment** : Appwrite Cloud ou Self-hosted (Docker)

### Services Externes

- **Google Maps Platform** : Cartographie et géolocalisation
- **Firebase Cloud Messaging** : Notifications push
- **Google OAuth** : Authentification sociale

### Architecture

- **Clean Architecture** : Séparation en 3 couches (Presentation, Domain, Data)
- **BLoC Pattern** : Gestion d'état prédictible
- **Repository Pattern** : Abstraction des sources de données

---

## 🚀 Installation

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.16+
- [Dart SDK](https://dart.dev/get-dart) 3.0+
- Compte [Appwrite](https://cloud.appwrite.io) (gratuit)
- IDE : [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio)
- [Git](https://git-scm.com/)

**Vérifier l'installation** :
```bash
flutter doctor -v
```

### Étapes d'Installation

#### 1. Cloner le Repository
```bash
git clone https://github.com/votre-org/immo-app.git
cd immo-app
```

#### 2. Installer les Dépendances
```bash
flutter pub get
```

#### 3. Configurer Appwrite

**Option A : Appwrite Cloud (Recommandé)**

1. Créer un compte sur [cloud.appwrite.io](https://cloud.appwrite.io)
2. Créer un nouveau projet
3. Noter le **Project ID** et **Endpoint**

**Option B : Self-hosted**
```bash
docker run -it --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
    --entrypoint="install" \
    appwrite/appwrite:1.5.0

cd appwrite && docker compose up -d
```

#### 4. Configurer la Database Appwrite

Dans Appwrite Console, créer :

**Database** : `immo_database`

**Collections** :
- `properties` (annonces)
- `messages` (messages du chat)
- `conversations` (conversations)
- `favorites` (favoris utilisateurs)

**Storage Buckets** :
- `property_images`
- `message_images`
- `profile_images`

📖 **Guide détaillé** : [docs/guides/getting-started.md](docs/guides/getting-started.md)

#### 5. Configurer les Variables d'Environnement
```bash
cp .env.example .env
```

Éditer `.env` avec vos valeurs :
```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=votre_project_id

APPWRITE_DATABASE_ID=immo_database
APPWRITE_PROPERTIES_COLLECTION_ID=properties
# ... autres IDs

GOOGLE_MAPS_API_KEY_ANDROID=votre_cle_android
GOOGLE_MAPS_API_KEY_IOS=votre_cle_ios
```

#### 6. Générer le Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 7. Lancer l'Application
```bash
# Voir les devices disponibles
flutter devices

# Lancer sur un émulateur/device
flutter run

# Ou en mode release
flutter run --release
```

---

## 📁 Structure du Projet
```
immo-app/
├── lib/
│   ├── main.dart                    # Point d'entrée
│   ├── app/
│   │   └── routes/                  # Navigation
│   ├── core/
│   │   ├── config/                  # Configuration Appwrite
│   │   ├── di/                      # Dependency Injection
│   │   ├── theme/                   # Thème et styles
│   │   └── utils/                   # Utilitaires
│   ├── features/                    # Features (Clean Architecture)
│   │   ├── auth/                    # Authentification
│   │   │   ├── data/
│   │   │   │   ├── models/          # DTOs
│   │   │   │   ├── repositories/    # Implémentations
│   │   │   │   └── datasources/     # Sources (Appwrite)
│   │   │   ├── domain/
│   │   │   │   ├── entities/        # Modèles métier
│   │   │   │   ├── repositories/    # Interfaces
│   │   │   │   └── usecases/        # Cas d'usage
│   │   │   └── presentation/
│   │   │       ├── bloc/            # BLoC
│   │   │       ├── pages/           # Écrans
│   │   │       └── widgets/         # Composants
│   │   ├── property/                # Gestion propriétés
│   │   ├── messages/                # Messagerie
│   │   ├── profile/                 # Profil
│   │   ├── search/                  # Recherche
│   │   └── map/                     # Carte
│   └── shared/                      # Code partagé
│       └── widgets/                 # Widgets communs
│
├── test/                            # Tests
├── docs/                            # Documentation
├── assets/                          # Assets (images, fonts)
├── pubspec.yaml                     # Dependencies
└── .env                            # Variables d'environnement
```

### Architecture Clean

Chaque feature suit la **Clean Architecture** :
```
feature/
├── data/         # Implémentation accès données
├── domain/       # Logique métier (pure Dart)
└── presentation/ # UI et state management
```

**Flux de données** :
```
UI → BLoC → UseCase → Repository → DataSource (Appwrite)
```

---

## 📖 Documentation

La documentation complète est disponible dans [`docs/`](docs/README.md) :

- 🏗️ **Architecture**
  - [Architecture Générale](docs/architecture/README.md)
  - [Diagramme C4 - Niveau 1](docs/architecture/c4-model/01-context-flutter.md)
  - [Diagramme C4 - Niveau 2](docs/architecture/c4-model/02-container-flutter.md)
  - [Diagramme C4 - Niveau 3](docs/architecture/c4-model/03-component-flutter-appwrite.md)
  
- 👨‍💻 **Guides**
  - [Guide de Démarrage](docs/guides/getting-started.md)
  - [Configuration Environnement](docs/guides/setup-environment.md)
  - [Standards de Code](docs/guides/coding-standards.md)
  - [Guide de Contribution](docs/guides/contributing.md)

- 🎨 **Design**
  - [Guide de Style](docs/design/style-guide.md)
  - [Wireframes](docs/design/wireframes/)
  - [Mockups](docs/design/mockups/)

---

## 🧪 Tests

### Lancer les Tests
```bash
# Tests unitaires
flutter test

# Tests avec coverage
flutter test --coverage

# Tests d'intégration
flutter test integration_test/
```

### Coverage
```bash
# Générer rapport HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Objectif** : > 80% de coverage

---

## 🚀 Déploiement

### Android
```bash
# Build APK (debug)
flutter build apk

# Build App Bundle (production)
flutter build appbundle --release
```

Uploader sur [Google Play Console](https://play.google.com/console)

### iOS
```bash
# Build
flutter build ios --release

# Archive avec Xcode
open ios/Runner.xcworkspace
```

Soumettre via [App Store Connect](https://appstoreconnect.apple.com)

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez [CONTRIBUTING.md](docs/guides/contributing.md).

### Process

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Standards

- Code formaté : `flutter format .`
- Analyse réussie : `flutter analyze`
- Tests passants : `flutter test`
- Coverage maintenu : > 80%

---

## 📊 Roadmap

### ✅ Version 1.0 (Actuelle)

- [x] Authentification
- [x] CRUD Propriétés
- [x] Recherche avancée
- [x] Carte interactive
- [x] Messagerie temps réel
- [x] Favoris
- [x] Mode offline

### 🚧 Version 1.1 (En cours)

- [ ] Paiements (Stripe)
- [ ] Analytics
- [ ] Multi-langues
- [ ] Mode sombre

### 🔮 Version 2.0 (Planifié)

- [ ] Assistant IA
- [ ] Visite virtuelle 360°
- [ ] AR pour visualisation
- [ ] Calculateur de prêt

---

## 📄 Licence

Ce projet est sous licence MIT - voir [LICENSE](LICENSE) pour plus de détails.

---

## 👥 Équipe

| Rôle | Nom | Contact |
|------|-----|---------|
| Chef de Projet | [Nom] | [email@example.com] |
| Architecte | [Nom] | [email@example.com] |
| Développeur Lead | [Nom] | [email@example.com] |
| Designer UI/UX | [Nom] | [email@example.com] |

---

## 🙏 Remerciements

- [Appwrite](https://appwrite.io) - BaaS open source
- [Flutter](https://flutter.dev) - Framework UI
- [BLoC Library](https://bloclibrary.dev) - State management
- Communauté Flutter & Dart

---

## 📞 Support

- 📧 Email : support@immoapp.com
- 💬 Discord : [Rejoindre](https://discord.gg/immoapp)
- 🐛 Issues : [GitHub Issues](https://github.com/votre-org/immo-app/issues)
- 📖 Documentation : [docs/](docs/README.md)

---

## ⭐ Star History

Si ce projet vous aide, n'hésitez pas à lui donner une ⭐️ !

[![Star History](https://api.star-history.com/svg?repos=votre-org/immo-app&type=Date)](https://star-history.com/#votre-org/immo-app&Date)

---

<p align="center">
  Fait avec ❤️ par l'équipe ImmoApp
</p>

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter" alt="Built with Flutter">
  </a>
  <a href="https://appwrite.io">
    <img src="https://img.shields.io/badge/Powered%20by-Appwrite-FD366E?logo=appwrite" alt="Powered by Appwrite">
  </a>
</p>
