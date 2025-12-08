# 📚 Documentation - Application Immobilière

Bienvenue dans la documentation complète du projet **ImmoApp** - Application mobile de services immobiliers développée avec **Flutter** et **Appwrite**.

---

## 🎯 Vue d'Ensemble

### Objectif du Projet

Créer une application mobile **cross-platform** (iOS & Android) permettant de :
- 🔍 Rechercher des biens immobiliers avec filtres avancés
- 🏠 Consulter des annonces détaillées avec photos
- 📝 Publier des annonces de vente/location
- 🗺️ Localiser les biens sur carte interactive
- 💬 Communiquer via messagerie temps réel
- ⭐ Gérer ses favoris et recherches sauvegardées

### Technologies Principales

- **Frontend** : Flutter 3.16+ (Dart 3.0+)
- **Backend** : Appwrite (BaaS open source)
- **Architecture** : Clean Architecture + BLoC
- **State Management** : flutter_bloc
- **Cache** : Hive (local) + Appwrite (remote)

---

## 📖 Navigation Documentation

### 🏗️ Architecture et Conception

| Document | Description |
|----------|-------------|
| [**Architecture Générale**](architecture/README.md) | Vue d'ensemble de l'architecture Flutter + Appwrite |
| [**Modèle C4**](architecture/c4-model/) | Diagrammes d'architecture (3 niveaux) |
| [**Schéma Base de Données**](architecture/database-schema-appwrite.md) | Structure des collections Appwrite |
| [**Configuration Appwrite**](architecture/appwrite-setup.md) | Guide de configuration Appwrite |

#### Diagrammes C4
- [Niveau 1 : Contexte](architecture/c4-model/01-context-flutter.md) - Vue système global
- [Niveau 2 : Conteneurs](architecture/c4-model/02-container-flutter.md) - Architecture Flutter
- [Niveau 3 : Composants](architecture/c4-model/03-component-flutter-appwrite.md) - Détails internes

### 👨‍💻 Guides de Développement

| Document | Description |
|----------|-------------|
| [**Guide de Démarrage**](guides/getting-started.md) | Installation et premier lancement |
| [**Configuration Environnement**](guides/setup-environment.md) | Setup Flutter, Appwrite, Emulateurs |
| [**Standards de Code**](guides/coding-standards.md) | Conventions et bonnes pratiques |
| [**Guide de Contribution**](guides/contributing.md) | Comment contribuer au projet |
| [**Guide Testing**](guides/testing-guide.md) | Tests unitaires et d'intégration |

### 🎨 Design UI/UX

| Document | Description |
|----------|-------------|
| [**Guide de Style**](design/style-guide.md) | Couleurs, typographie, composants |
| [**Wireframes**](design/wireframes/) | Maquettes basse-fidélité |
| [**Mockups**](design/mockups/) | Maquettes haute-fidélité |
| [**Design System**](design/design-system.md) | Composants réutilisables |

---

## 🚀 Démarrage Rapide

### Prérequis

```bash
# Vérifier Flutter
flutter doctor -v

# Vérifier Dart
dart --version
```

**Requis** :
- Flutter SDK 3.16+
- Dart SDK 3.0+
- Compte Appwrite (Cloud ou Self-hosted)
- Android Studio / Xcode

### Installation en 5 Minutes

```bash
# 1. Cloner le repository
git clone https://github.com/votre-org/immo-app.git
cd immo-app

# 2. Installer les dépendances Flutter
flutter pub get

# 3. Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos clés Appwrite

# 4. Générer le code
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Lancer l'application
flutter run
```

### Configuration Appwrite

```bash
# Option 1 : Appwrite Cloud
# Créer un compte sur https://cloud.appwrite.io

# Option 2 : Self-hosted avec Docker
docker run -it --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
    --entrypoint="install" \
    appwrite/appwrite:1.5.0
```

📖 **Guide complet** : [Getting Started](guides/getting-started.md)

---

## 🏗️ Structure du Projet

```
immo-app/
├── docs/                      # 📚 Cette documentation
│   ├── architecture/          # Architecture et C4
│   ├── guides/               # Guides développeurs
│   └── design/               # Design UI/UX
│
├── lib/                       # 📱 Code Flutter
│   ├── main.dart             # Point d'entrée
│   ├── app/                  # Configuration app
│   ├── core/                 # Code partagé
│   │   ├── config/           # Configuration (Appwrite)
│   │   ├── di/               # Dependency Injection
│   │   ├── theme/            # Thème et styles
│   │   └── utils/            # Utilitaires
│   ├── features/             # Features (Clean Architecture)
│   │   ├── auth/             # Authentification
│   │   ├── property/         # Gestion propriétés
│   │   ├── messages/         # Messagerie
│   │   ├── profile/          # Profil utilisateur
│   │   ├── search/           # Recherche avancée
│   │   └── map/              # Carte interactive
│   └── shared/               # Widgets partagés
│
├── test/                      # 🧪 Tests
│   ├── unit/                 # Tests unitaires
│   ├── widget/               # Tests de widgets
│   └── integration/          # Tests d'intégration
│
├── assets/                    # 🖼️ Assets statiques
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── pubspec.yaml              # Dependencies Flutter
├── .env                      # Variables d'environnement
└── README.md                 # README principal
```

### Organisation Features (Clean Architecture)

```
lib/features/auth/
├── data/
│   ├── models/              # DTOs (toJson/fromJson)
│   ├── repositories/        # Implémentations Repository
│   └── datasources/         # Sources de données (Appwrite)
├── domain/
│   ├── entities/            # Modèles métier (pure Dart)
│   ├── repositories/        # Interfaces Repository
│   └── usecases/            # Cas d'usage métier
└── presentation/
    ├── bloc/                # BLoC (Events, States)
    ├── pages/               # Écrans
    └── widgets/             # Composants UI
```

---

## 🛠️ Stack Technique Détaillée

### Frontend Mobile

```yaml
# pubspec.yaml (extraits)
dependencies:
  flutter:
    sdk: flutter
  
  # Backend
  appwrite: ^11.0.0
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # DI
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # Cache Local
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Maps
  google_maps_flutter: ^2.5.3
  geolocator: ^11.0.0
  
  # Notifications
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

### Backend (Appwrite)

| Service | Usage dans l'App |
|---------|------------------|
| **Account API** | Authentification (Email, OAuth) |
| **Databases** | Propriétés, Messages, Favoris |
| **Storage** | Photos annonces et profils |
| **Realtime** | Chat temps réel |
| **Functions** | Recherche géographique |

**Deployment Options** :
- ☁️ **Appwrite Cloud** : https://cloud.appwrite.io
- 🐳 **Self-hosted** : Docker Compose

---

## 📊 Fonctionnalités

### ✅ Implémentées

- [x] Authentification (Email/Password + Google OAuth)
- [x] Gestion des propriétés (CRUD)
- [x] Recherche avec filtres avancés
- [x] Upload et affichage d'images
- [x] Carte interactive avec markers
- [x] Messagerie temps réel (Appwrite Realtime)
- [x] Gestion des favoris
- [x] Mode offline (cache Hive)
- [x] Notifications push (FCM)
- [x] Profil utilisateur

### 🚧 En Développement

- [ ] Paiements intégrés (Stripe)
- [ ] Analytics (Firebase Analytics)
- [ ] Partage social
- [ ] Recherche par voix
- [ ] Mode sombre
- [ ] Multi-langues (i18n)

### 🔮 Prévues

- [ ] AR pour visualisation 3D
- [ ] Assistant IA pour recommandations
- [ ] Visite virtuelle (360°)
- [ ] Calcul de prêt immobilier

---

## 🧪 Tests

### Lancer les Tests

```bash
# Tests unitaires
flutter test

# Tests avec coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Tests d'intégration
flutter test integration_test/
```

### Structure des Tests

```
test/
├── features/
│   └── auth/
│       ├── data/
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       └── login_usecase_test.dart
│       └── presentation/
│           └── bloc/
│               └── auth_bloc_test.dart
└── helpers/
    ├── test_helper.dart
    └── mock_data.dart
```

**Objectif Coverage** : > 80%

---

## 🚀 Déploiement

### Android (Google Play)

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommandé)
flutter build appbundle --release
```

### iOS (App Store)

```bash
# Build iOS
flutter build ios --release

# Ouvrir Xcode pour Archive
open ios/Runner.xcworkspace
```

### CI/CD avec GitHub Actions

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --release
```

---

## 📈 Métriques Projet

### Code

| Métrique | Valeur |
|----------|--------|
| **Lignes de code** | ~15,000 |
| **Features** | 6 |
| **Widgets custom** | 45+ |
| **Use Cases** | 28 |
| **Tests** | 150+ |
| **Coverage** | 85% |

### Performance

| Métrique | Objectif | Actuel |
|----------|----------|--------|
| **App size** | < 15MB | 12MB |
| **Cold start** | < 3s | 2.1s |
| **Hot reload** | < 300ms | 180ms |
| **API latency** | < 500ms | 320ms |

---

## 🤝 Contribution

Nous accueillons les contributions ! Consultez notre [Guide de Contribution](guides/contributing.md).

### Process

1. **Fork** le repository
2. **Créer** une branche feature (`git checkout -b feature/amazing-feature`)
3. **Commit** vos changements (`git commit -m 'Add amazing feature'`)
4. **Push** vers la branche (`git push origin feature/amazing-feature`)
5. **Ouvrir** une Pull Request

### Standards

- ✅ Code formaté (`flutter format .`)
- ✅ Analyse réussie (`flutter analyze`)
- ✅ Tests passants (`flutter test`)
- ✅ Coverage maintenu (> 80%)

---

## 📞 Support et Contact

### Équipe

| Rôle | Nom | Contact |
|------|-----|---------|
| **Chef de Projet** | [Nom] | [email] |
| **Architecte** | [Nom] | [email] |
| **Dev Lead** | [Nom] | [email] |
| **Designer** | [Nom] | [email] |

### Ressources

- 📖 [Documentation Appwrite](https://appwrite.io/docs)
- 📱 [Documentation Flutter](https://docs.flutter.dev)
- 💬 [Discord du Projet](#)
- 🐛 [Issue Tracker](https://github.com/votre-org/immo-app/issues)

---

## 📄 Licence

Ce projet est sous licence **MIT** - voir le fichier [LICENSE](../LICENSE) pour plus de détails.

---

## 🙏 Remerciements

- [Appwrite](https://appwrite.io) pour le BaaS open source
- [Flutter](https://flutter.dev) pour le framework
- [BLoC Library](https://bloclibrary.dev) pour le state management
- Communauté open source Flutter

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2024  
**Status** : 🟢 En développement actif