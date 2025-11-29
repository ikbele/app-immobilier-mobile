// lib/models/models.dart

/// Modèle pour une propriété immobilière
class Property {
  final String id;
  final String title;
  final String description;
  final String type;
  final double prix;
  final String localisation;
  final double lat;
  final double lng;
  final String imageUrl;
  final String ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.prix,
    required this.localisation,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  /// Créer un Property depuis un document Appwrite
  factory Property.fromMap(Map<String, dynamic> map, String id) {
    return Property(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      localisation: map['localisation'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      createdAt: map['\$createdAt'] != null 
          ? DateTime.parse(map['\$createdAt']) 
          : null,
      updatedAt: map['\$updatedAt'] != null 
          ? DateTime.parse(map['\$updatedAt']) 
          : null,
    );
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'prix': prix,
      'localisation': localisation,
      'lat': lat,
      'lng': lng,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
    };
  }

  /// Copier avec modifications
  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    double? prix,
    String? localisation,
    double? lat,
    double? lng,
    String? imageUrl,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      prix: prix ?? this.prix,
      localisation: localisation ?? this.localisation,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modèle pour un favori
class Favorite {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime? createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.propertyId,
    this.createdAt,
  });

  /// Créer un Favorite depuis un document Appwrite
  factory Favorite.fromMap(Map<String, dynamic> map, String id) {
    return Favorite(
      id: id,
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      createdAt: map['\$createdAt'] != null 
          ? DateTime.parse(map['\$createdAt']) 
          : null,
    );
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'propertyId': propertyId,
    };
  }
}

/// Modèle pour un message de chat
class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime? timestamp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.timestamp,
    this.createdAt,
    this.updatedAt,
  });

  /// Créer un ChatMessage depuis un document Appwrite
  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : null,
      createdAt: map['\$createdAt'] != null 
          ? DateTime.parse(map['\$createdAt']) 
          : null,
      updatedAt: map['\$updatedAt'] != null 
          ? DateTime.parse(map['\$updatedAt']) 
          : null,
    );
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Copier avec modifications
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modèle pour un utilisateur
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.createdAt,
  });

  /// Créer un AppUser depuis un document Appwrite
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt: map['\$createdAt'] != null 
          ? DateTime.parse(map['\$createdAt']) 
          : null,
    );
  }

  /// Convertir en Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }

  /// Copier avec modifications
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Types de propriétés disponibles
class PropertyType {
  static const String villa = 'Villa';
  static const String appartement = 'Appartement';
  static const String maison = 'Maison';
  static const String studio = 'Studio';
  static const String penthouse = 'Penthouse';
  static const String terrain = 'Terrain';
  static const String bureau = 'Bureau';
  static const String commerce = 'Commerce';

  static List<String> get all => [
    villa,
    appartement,
    maison,
    studio,
    penthouse,
    terrain,
    bureau,
    commerce,
  ];
}

/// Statuts de paiement
enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
}

/// Méthodes de paiement
enum PaymentMethod {
  card,
  paypal,
  mobile,
  cash,
}

/// Extension pour convertir PaymentStatus en String
extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.completed:
        return 'Complété';
      case PaymentStatus.failed:
        return 'Échoué';
      case PaymentStatus.cancelled:
        return 'Annulé';
    }
  }
}

/// Extension pour convertir PaymentMethod en String
extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.mobile:
        return 'mobile';
      case PaymentMethod.cash:
        return 'cash';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.card:
        return 'Carte bancaire';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.mobile:
        return 'Paiement mobile';
      case PaymentMethod.cash:
        return 'Espèces';
    }
  }
}