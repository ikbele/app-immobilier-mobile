# C4 Model - Niveau 1 : Diagramme de Contexte (Flutter)

## 📌 Vue d'ensemble

Application mobile **cross-platform** développée avec **Flutter/Dart** pour la gestion d'annonces immobilières.

## 🎯 Stack Technique Principal

- **Framework** : Flutter 3.x
- **Langage** : Dart 3.x
- **Plateformes** : iOS & Android
- **Architecture** : Clean Architecture + BLoC

---

## 📊 Diagramme

```mermaid
graph TB
    User[("👤 Utilisateur Mobile<br/>(iOS/Android)")]
    
    subgraph FlutterApp["Application Flutter ImmoApp"]
        ImmoApp["📱 ImmoApp<br/>---<br/>Flutter 3.x / Dart 3.x<br/>iOS & Android<br/>Clean Architecture + BLoC"]
    end
    
    subgraph Backend["Backend Services"]
        API["🚪 REST API<br/>---<br/>Node.js + Express<br/>Authentification JWT"]
        WSServer["🔌 WebSocket<br/>---<br/>Socket.io<br/>Messagerie temps réel"]
    end
    
    subgraph Firebase["Firebase Services"]
        FCM["🔔 Cloud Messaging<br/>---<br/>Push Notifications"]
        Storage["☁️ Storage<br/>---<br/>Images & Fichiers"]
        Auth["🔐 Authentication<br/>---<br/>OAuth Provider"]
    end
    
    Database[("💾 PostgreSQL<br/>---<br/>Base de données")]
    Cache[("⚡ Redis<br/>---<br/>Cache & Sessions")]
    
    Maps["🗺️ Google Maps API<br/>---<br/>Géolocalisation"]
    Email["📧 SendGrid<br/>---<br/>Emails"]
    
    User -->|"HTTPS/WSS"| ImmoApp
    
    ImmoApp -->|"REST API<br/>(Dio)"| API
    ImmoApp -->|"WebSocket<br/>(socket_io_client)"| WSServer
    ImmoApp -->|"Push<br/>(firebase_messaging)"| FCM
    ImmoApp -->|"Upload/Download<br/>(firebase_storage)"| Storage
    ImmoApp -->|"OAuth<br/>(firebase_auth)"| Auth
    ImmoApp -->|"Maps<br/>(google_maps_flutter)"| Maps
    
    API --> Database
    API --> Cache
    WSServer --> Database
    API --> Email
    FCM -.->|"Notifications"| User
    
    style ImmoApp fill:#02569B,stroke:#014A7F,color:#ffffff
    style User fill:#075E8C,stroke:#034A6D,color:#ffffff
    style API fill:#68BC71,stroke:#4A8B4F,color:#ffffff
    style WSServer fill:#68BC71,stroke:#4A8B4F,color:#ffffff
    style FCM fill:#FFCA28,stroke:#F9A825,color:#000000
    style Storage fill:#FFCA28,stroke:#F9A825,color:#000000
    style Auth fill:#FFCA28,stroke:#F9A825,color:#000000
    style Maps fill:#4285F4,stroke:#1967D2,color:#ffffff
```

---

## 📱 Application Flutter

### Caractéristiques Techniques

**Framework** : Flutter 3.16+
- Single codebase pour iOS et Android
- Performance native (compilation AOT)
- Hot reload pour développement rapide
- Widget tree déclaratif

**Packages Flutter Principaux** :
```yaml
flutter_bloc: ^8.1.3        # State management
dio: ^5.4.0                  # HTTP client
hive: ^2.2.3                 # Local database
google_maps_flutter: ^2.5.3  # Maps
socket_io_client: ^2.0.3     # WebSocket
firebase_messaging: ^14.7.9  # Push notifications
image_picker: ^1.0.7         # Camera/Gallery
```

### Fonctionnalités

✅ **Authentification sécurisée**
- Email/Password avec Firebase Auth
- OAuth (Google, Facebook)
- Biométrie (TouchID/FaceID)

✅ **Recherche avancée**
- Filtres multiples (prix, type, localisation)
- Recherche géographique avec rayon
- Sauvegarde des recherches

✅ **Gestion d'annonces**
- Publication avec photos multiples
- Édition/Suppression
- Statistiques de vue

✅ **Messagerie temps réel**
- Chat en direct (WebSocket)
- Notifications push
- Historique persistant

✅ **Carte interactive**
- Google Maps intégré
- Markers cliquables
- Clustering
- Itinéraire vers propriété

✅ **Mode Offline**
- Cache local (Hive)
- Synchronisation automatique
- Favoris accessibles hors ligne

---

## 🔌 Intégrations Flutter

### Firebase Services

**firebase_core** : Initialisation
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**firebase_messaging** : Notifications Push
```dart
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission();
FirebaseMessaging.onMessage.listen((message) {
  // Afficher notification
});
```

**firebase_storage** : Upload Images
```dart
final ref = FirebaseStorage.instance.ref('properties/$id');
await ref.putFile(imageFile);
final url = await ref.getDownloadURL();
```

### Google Maps

**google_maps_flutter** : Carte Interactive
```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(36.8065, 10.1815),
    zoom: 12,
  ),
  markers: _markers,
  onMapCreated: _onMapCreated,
)
```

**geolocator** : Géolocalisation
```dart
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);
```

### Networking

**Dio** : Client HTTP
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.immoapp.com',
  connectTimeout: Duration(seconds: 30),
));
dio.interceptors.add(AuthInterceptor());
```

**socket_io_client** : WebSocket
```dart
final socket = io('wss://api.immoapp.com', <String, dynamic>{
  'transports': ['websocket'],
  'auth': {'token': token},
});
socket.on('new_message', (data) {
  // Gérer message
});
```

---

## 🔐 Sécurité Flutter

### Stockage Sécurisé
```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'access_token', value: token);
```

### Certificate Pinning
```dart
dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () {
    final client = HttpClient();
    client.badCertificateCallback = 
      (X509Certificate cert, String host, int port) {
        return cert.sha256.toString() == expectedSHA256;
      };
    return client;
  },
);
```

### Chiffrement Local (Hive)
```dart
final key = await Hive.generateSecureKey();
final encryptedBox = await Hive.openBox(
  'secure_data',
  encryptionCipher: HiveAesCipher(key),
);
```

---

## 📊 Performance Flutter

### Optimisations

**Images** :
```dart
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 800,
  memCacheHeight: 600,
  placeholder: (context, url) => Shimmer(...),
)
```

**Listes** :
```dart
ListView.builder(
  itemCount: items.length,
  cacheExtent: 1000, // Preload
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

**Build Optimization** :
```dart
@override
Widget build(BuildContext context) {
  return const PropertyCard(); // const constructor
}
```

---

## 🚀 Déploiement

### iOS (App Store)
```bash
flutter build ios --release
# Ouvrir Xcode et Archive
```

### Android (Google Play)
```bash
flutter build appbundle --release
# Upload sur Play Console
```

### CI/CD avec Codemagic
```yaml
workflows:
  build-deploy:
    environment:
      flutter: 3.16.0
    scripts:
      - flutter test
      - flutter build apk --release
      - flutter build ios --release
```

---

## 🔗 Navigation

- [Niveau 2 : Conteneurs Flutter →](02-container-flutter.md)
- [Niveau 3 : Composants Flutter →](03-component-flutter.md)
- [← Retour Architecture](../README.md)

---

**Technologie** : Flutter 3.x  
**Version** : 1.0  
**Dernière mise à jour** : Décembre 2024