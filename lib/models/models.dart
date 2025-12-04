// Modèle pour les propriétés immobilières
class Property {
  final String id;
  final String title;
  final String description;
  final String localisation;
  final String type;
  final double prix;
  final String imageUrl;
  final String? ownerId;
  final String? ownerName;
  final DateTime? createdAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.localisation,
    required this.type,
    required this.prix,
    required this.imageUrl,
    this.ownerId,
    this.ownerName,
    this.createdAt,
  });

  // Créer un Property depuis un Map
  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] ?? map['\$id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      localisation: map['localisation'] ?? '',
      type: map['type'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'],
      ownerName: map['ownerName'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  // Convertir un Property en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'localisation': localisation,
      'type': type,
      'prix': prix,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

// Modèle pour les favoris
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

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] ?? map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

// Modèle pour les messages de chat
class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? map['\$id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Modèle pour l'utilisateur
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      avatarUrl: map['avatarUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}