# Architecture - Application Immobilière (Flutter + Appwrite)

## 📌 Introduction

Documentation complète de l'architecture de l'application mobile de services immobiliers développée avec **Flutter** et **Appwrite** comme backend BaaS (Backend-as-a-Service).

## 📋 Table des Matières

1. [Modèle C4](#modèle-c4)
2. [Stack Technique](#stack-technique)
3. [Architecture Appwrite](#architecture-appwrite)
4. [Patterns et Principes](#patterns-et-principes)
5. [Sécurité](#sécurité)
6. [Performance](#performance)

---

## 🏗️ Modèle C4

Nous utilisons la méthode C4 pour documenter l'architecture à différents niveaux d'abstraction.

### Diagrammes Disponibles

- **[Niveau 1 : Contexte](c4-model/01-context-flutter.md)** - Vue système global avec Appwrite
- **[Niveau 2 : Conteneurs](c4-model/02-container-flutter.md)** - Architecture Flutter + Services Appwrite
- **[Niveau 3 : Composants](c4-model/03-component-flutter-appwrite.md)** - Détails internes de l'app Flutter

### Vue d'Ensemble

```
┌─────────────────────────────────────────────────────┐
│                  Utilisateur Mobile                  │
│                    (iOS/Android)                     │
└──────────────────────┬──────────────────────────────┘
                       │
                       │ HTTPS/WSS
                       │
┌──────────────────────▼──────────────────────────────┐
│          Application Flutter (Clean Architecture)    │
│  ┌────────────────────────────────────────────────┐ │
│  │  Presentation Layer (BLoC + UI Widgets)        │ │
│  └────────────────────┬───────────────────────────┘ │
│  ┌────────────────────▼───────────────────────────┐ │
│  │  Domain Layer (Use Cases + Entities)           │ │
│  └────────────────────┬───────────────────────────┘ │
│  ┌────────────────────▼───────────────────────────┐ │
│  │  Data Layer (Repositories + Data Sources)      │ │
│  └────────────────────┬───────────────────────────┘ │
└───────────────────────┼─────────────────────────────┘
                        │
         ┌──────────────┼──────────────┐
         │              │              │
         │              │              │
┌────────▼────────┐ ┌──▼──────────┐ ┌─▼─────────────┐
│  Appwrite Core  │ │   Firebase  │ │ Google Maps   │
│                 │ │     FCM     │ │      API      │
│ • Auth          │ │             │ │               │
│ • Database      │ │ Push        │ │ Géoloc &      │
│ • Storage       │ │ Notifications│ │ Cartographie  │
│ • Realtime      │ │             │ │               │
│ • Functions     │ │             │ │               │
└─────────────────┘ └─────────────┘ └───────────────┘
```

---

## 🛠️ Stack Technique

### Frontend Mobile

| Composant | Technologie | Version | Description |
|-----------|-------------|---------|-------------|
| **Framework** | Flutter | 3.16+ | Framework UI cross-platform |
| **Langage** | Dart | 3.0+ | Langage de programmation |
| **State Management** | flutter_bloc | 8.1.3 | Pattern BLoC pour gestion d'état |
| **Architecture** | Clean Architecture | - | Séparation en couches |
| **DI** | get_it + injectable | 7.6.4 / 2.3.2 | Injection de dépendances |
| **Routing** | go_router | 13.0.0 | Navigation déclarative |
| **Cache Local** | Hive | 2.2.3 | Base de données NoSQL locale |
| **Secure Storage** | flutter_secure_storage | 9.0.0 | Stockage sécurisé |

### Backend (Appwrite)

| Service | Technologie | Description |
|---------|-------------|-------------|
| **Backend** | Appwrite | Backend-as-a-Service open source |
| **Auth** | Appwrite Account API | Email/Password + OAuth2 |
| **Database** | Appwrite Database | Base de données documentaire |
| **Storage** | Appwrite Storage | Stockage fichiers avec CDN |
| **Realtime** | Appwrite Realtime | WebSocket pour temps réel |
| **Functions** | Appwrite Functions | Serverless computing |

**Options de déploiement** :
- ☁️ Appwrite Cloud (géré)
- 🐳 Self-hosted (Docker)

### Services Externes

| Service | Utilisation |
|---------|-------------|
| **Firebase Cloud Messaging** | Notifications push |
| **Google Maps Platform** | Cartographie et géolocalisation |
| **Google OAuth** | Authentification sociale |

### Base de Données Locale

| Type | Technologie | Usage |
|------|-------------|-------|
| **Cache structuré** | Hive | Propriétés, messages, favoris |
| **Préférences** | SharedPreferences | Settings utilisateur |
| **Sécurisé** | FlutterSecureStorage | Tokens, credentials |

---

## 🔥 Architecture Appwrite

### Structure de la Base de Données

```
immo_database/
├── properties          # Annonces immobilières
├── messages           # Messages du chat
├── conversations      # Conversations entre utilisateurs
├── favorites          # Favoris des utilisateurs
├── users_data         # Données utilisateur étendues
└── notifications      # Historique des notifications
```

### Buckets de Storage

```
Storage/
├── property_images/    # Photos des annonces (max 10MB)
├── message_images/     # Images dans les messages (max 5MB)
└── profile_images/     # Photos de profil (max 2MB)
```

### Services Appwrite Utilisés

#### 1. Account API (Authentification)
```dart
// Login
final session = await account.createEmailPasswordSession(
  email: email,
  password: password,
);

// OAuth
await account.createOAuth2Session(
  provider: OAuthProvider.google,
);

// Current user
final user = await account.get();
```

#### 2. Databases API (Collections)
```dart
// Query avec filtres
final docs = await databases.listDocuments(
  databaseId: databaseId,
  collectionId: propertiesCollection,
  queries: [
    Query.equal('type', 'apartment'),
    Query.greaterThanEqual('price', 100000),
    Query.lessThanEqual('price', 300000),
    Query.orderDesc('\$createdAt'),
    Query.limit(25),
  ],
);
```

#### 3. Storage API (Fichiers)
```dart
// Upload image
final file = await storage.createFile(
  bucketId: propertyImagesBucket,
  fileId: ID.unique(),
  file: InputFile.fromPath(path: imagePath),
);

// Get URL
final url = '${endpoint}/storage/buckets/${bucketId}/files/${fileId}/view';
```

#### 4. Realtime API (WebSocket)
```dart
// Subscribe to messages
final subscription = realtime.subscribe([
  'databases.$databaseId.collections.$messagesCollection.documents'
]);

subscription.stream.listen((response) {
  if (response.events.contains('documents.*.create')) {
    // Nouveau message reçu
    final message = Message.fromJson(response.payload);
  }
});
```

#### 5. Functions API (Serverless)
```dart
// Appeler une fonction (ex: recherche géo)
final result = await functions.createExecution(
  functionId: 'geo-search',
  body: jsonEncode({
    'latitude': 36.8065,
    'longitude': 10.1815,
    'radius': 5,
  }),
);
```

---

## 🏛️ Patterns et Principes

### Clean Architecture

Architecture en **3 couches** avec séparation stricte des responsabilités :

```
┌─────────────────────────────────────────────────┐
│         PRESENTATION LAYER (UI)                  │
│  • Pages (Screens)                               │
│  • Widgets (Components)                          │
│  • BLoCs (State Management)                      │
│                                                   │
│  Dependencies: Domain Layer                       │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│         DOMAIN LAYER (Business Logic)            │
│  • Entities (Pure Dart objects)                  │
│  • Use Cases (Business rules)                    │
│  • Repository Interfaces (Contracts)             │
│                                                   │
│  Dependencies: None (Pure Dart)                   │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│         DATA LAYER (Data Access)                 │
│  • Models (DTOs)                                 │
│  • Repository Implementations                     │
│  • Data Sources (Remote/Local)                   │
│    - Appwrite Client                             │
│    - Hive Database                               │
│                                                   │
│  Dependencies: Domain Layer + External SDKs       │
└─────────────────────────────────────────────────┘
```

**Avantages** :
- ✅ Testabilité maximale (chaque couche testable indépendamment)
- ✅ Maintenabilité (changements isolés)
- ✅ Scalabilité (ajout de features facilité)
- ✅ Indépendance du framework (domaine pur)

### BLoC Pattern (Business Logic Component)

**Flux unidirectionnel** :
```
UI Event → BLoC → Use Case → Repository → Data Source
                                              │
UI ← State ← BLoC ← Result ← Repository ←────┘
```

**Exemple concret** :
```dart
// 1. UI émet un Event
context.read<PropertyBloc>().add(
  LoadPropertiesEvent(limit: 25, offset: 0),
);

// 2. BLoC traite l'Event
Future<void> _onLoadProperties(
  LoadPropertiesEvent event,
  Emitter<PropertyState> emit,
) async {
  emit(PropertyState.loading());
  
  final result = await getPropertiesUseCase(
    GetPropertiesParams(limit: event.limit, offset: event.offset),
  );
  
  result.fold(
    (failure) => emit(PropertyState.error(failure.message)),
    (properties) => emit(PropertyState.loaded(properties)),
  );
}

// 3. UI réagit au State
BlocBuilder<PropertyBloc, PropertyState>(
  builder: (context, state) {
    return state.when(
      loading: () => LoadingWidget(),
      loaded: (properties) => PropertyListView(properties),
      error: (message) => ErrorWidget(message),
    );
  },
)
```

### Repository Pattern

**Abstraction de la source de données** :

```dart
// Interface (Domain Layer)
abstract class PropertyRepository {
  Future<Either<Failure, List<Property>>> getProperties();
  Future<Either<Failure, Property>> getPropertyById(String id);
}

// Implementation (Data Layer)
class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource; // Appwrite
  final PropertyLocalDataSource localDataSource;   // Hive
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Property>>> getProperties() async {
    if (await networkInfo.isConnected) {
      // Online: Fetch from Appwrite
      final properties = await remoteDataSource.getProperties();
      await localDataSource.cacheProperties(properties);
      return Right(properties);
    } else {
      // Offline: Load from cache
      final cached = await localDataSource.getCachedProperties();
      return Right(cached);
    }
  }
}
```

**Avantages** :
- ✅ Mode offline automatique
- ✅ Cache transparent
- ✅ Facilite les tests (mock facile)
- ✅ Peut changer de backend sans toucher la logique métier

### Dependency Injection

**get_it + injectable** pour l'injection automatique :

```dart
// Configuration
@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}

// Usage dans BLoC
@injectable
class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final GetPropertiesUseCase getProperties;
  final SearchPropertiesUseCase searchProperties;

  PropertyBloc({
    required this.getProperties,
    required this.searchProperties,
  }) : super(PropertyState.initial());
}

// Résolution automatique
final bloc = getIt<PropertyBloc>();
```

---

## 🔐 Sécurité

### Authentification Appwrite

**Méthodes supportées** :
- ✅ Email/Password (avec vérification email)
- ✅ Magic URL (lien de connexion par email)
- ✅ OAuth2 (Google, Apple, GitHub, Facebook)
- ✅ Anonymous Sessions
- ✅ JWT Sessions avec expiration

**Gestion des sessions** :
```dart
// Appwrite gère automatiquement les sessions
// Session stockée en cookie HTTP-only côté Appwrite
// Token JWT valide 15 jours par défaut

// Vérifier session active
final session = await account.getSession(sessionId: 'current');

// Prolonger session
await account.updateSession(sessionId: 'current');

// Logout (supprimer session)
await account.deleteSession(sessionId: 'current');
```

### Stockage Sécurisé Local

```dart
// flutter_secure_storage pour données sensibles
final storage = FlutterSecureStorage();

// Sauvegarder
await storage.write(key: 'user_id', value: userId);

// Lire
final userId = await storage.read(key: 'user_id');

// Supprimer
await storage.delete(key: 'user_id');
```

### Permissions Appwrite

**Système de permissions granulaire** :

```dart
// Création de document avec permissions
await databases.createDocument(
  databaseId: databaseId,
  collectionId: propertiesCollection,
  documentId: ID.unique(),
  data: propertyData,
  permissions: [
    Permission.read(Role.any()),                    // Tout le monde peut lire
    Permission.update(Role.user(userId)),           // Seul le créateur peut modifier
    Permission.delete(Role.user(userId)),           // Seul le créateur peut supprimer
  ],
);
```

**Rôles disponibles** :
- `Role.any()` - Tous (connectés ou non)
- `Role.guests()` - Utilisateurs non connectés
- `Role.users()` - Tous les utilisateurs connectés
- `Role.user(userId)` - Utilisateur spécifique
- `Role.team(teamId)` - Équipe spécifique

### Validation des Données

**Côté Client (Flutter)** :
```dart
// Validation formulaire
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email requis';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email invalide';
  }
  return null;
}
```

**Côté Serveur (Appwrite)** :
- Validation automatique des types
- Contraintes sur les attributs (required, min, max)
- Validation des formats (email, URL, etc.)

### Protection des Données

| Aspect | Solution |
|--------|----------|
| **Transport** | HTTPS/TLS 1.3 obligatoire |
| **Stockage** | Encryption at rest (Appwrite) |
| **Cache local** | Hive avec encryption |
| **Tokens** | JWT avec expiration |
| **Files** | Bucket permissions + antivirus |
| **Rate Limiting** | Intégré dans Appwrite |
| **CORS** | Configuré dans Appwrite Console |

---

## ⚡ Performance

### Stratégie de Cache

**3 niveaux de cache** :

```
┌─────────────────────────────────────────────┐
│  1. Memory Cache (In-App)                   │
│     • BLoC State                             │
│     • Image cache (cached_network_image)     │
│     • Durée: Session                         │
└─────────────────────────────────────────────┘
                    ▼
┌─────────────────────────────────────────────┐
│  2. Local Database (Hive)                    │
│     • Properties, Messages, Favorites        │
│     • Durée: 24h - 7 jours                   │
│     • Mode offline                           │
└─────────────────────────────────────────────┘
                    ▼
┌─────────────────────────────────────────────┐
│  3. Remote (Appwrite)                        │
│     • Source de vérité                       │
│     • Synchronisation automatique            │
└─────────────────────────────────────────────┘
```

### Optimisations Flutter

**Images** :
```dart
CachedNetworkImage(
  imageUrl: AppwriteConfig().getImagePreview(
    bucketId: propertyImagesBucket,
    fileId: imageId,
    width: 400,
    height: 300,
  ),
  memCacheWidth: 800,
  memCacheHeight: 600,
  placeholder: (context, url) => ShimmerWidget(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**Listes** :
```dart
ListView.builder(
  itemCount: properties.length,
  cacheExtent: 1000, // Preload
  itemBuilder: (context, index) {
    return const PropertyCard(property: properties[index]);
  },
)
```

**Pagination** :
```dart
// Infinite scroll
ScrollController _scrollController;

@override
void initState() {
  _scrollController.addListener(() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<PropertyBloc>().add(LoadMorePropertiesEvent());
    }
  });
}
```

### Optimisations Appwrite

**Indexes** :
- Créer des indexes sur les champs fréquemment filtrés
- Index composites pour requêtes complexes

**Queries optimisées** :
```dart
// Utiliser limit/offset pour pagination
Query.limit(25)
Query.offset(page * 25)

// Sélectionner uniquement les champs nécessaires
Query.select(['title', 'price', 'images'])

// Ordonner côté serveur
Query.orderDesc('\$createdAt')
```

**Realtime** :
- Subscribe uniquement aux channels nécessaires
- Unsubscribe quand le widget est dispose

---

## 📚 Ressources

### Documentation Officielle

- 📖 [Appwrite Documentation](https://appwrite.io/docs)
- 📱 [Flutter Documentation](https://docs.flutter.dev)
- 🏗️ [BLoC Library](https://bloclibrary.dev)
- 🧩 [GetIt (DI)](https://pub.dev/packages/get_it)

### Guides Internes

- [Guide de Démarrage](../guides/getting-started.md)
- [Spécifications Techniques](technical-specs.md)
- [Schéma Base de Données Appwrite](database-schema-appwrite.md)
- [Standards de Code](../guides/coding-standards.md)

### Diagrammes C4

- [Niveau 1 : Contexte](c4-model/01-context-flutter.md)
- [Niveau 2 : Conteneurs](c4-model/02-container-flutter.md)
- [Niveau 3 : Composants](c4-model/03-component-flutter-appwrite.md)

---

## 🎯 Avantages de l'Architecture

### Pourquoi Flutter + Appwrite ?

| Aspect | Avantage |
|--------|----------|
| **Développement** | Single codebase iOS + Android |
| **Time-to-Market** | Backend ready-to-use avec Appwrite |
| **Coûts** | Open source, self-hostable |
| **Scalabilité** | Architecture modulaire + microservices |
| **Maintenabilité** | Clean Architecture + BLoC |
| **Performance** | AOT compilation + cache multi-niveaux |
| **Sécurité** | Auth intégré + permissions granulaires |
| **Offline-first** | Cache local automatique |

---

## 📊 Métriques de Qualité

### Tests

```
lib/
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
```

**Objectifs** :
- ✅ Code coverage > 80%
- ✅ Tests unitaires pour Use Cases
- ✅ Tests de Repositories avec mocks
- ✅ Tests de BLoCs avec bloc_test

### Performance

**Objectifs** :
- ✅ First load < 3s
- ✅ Navigation < 300ms
- ✅ Image load < 1s
- ✅ API response < 500ms
- ✅ Realtime latency < 100ms

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2024  
**Auteurs** : Équipe de développement ImmoApp