import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import './ChatPage.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late Client client;
  late Databases databases;
  late Account account;
  late Realtime realtime;

  String? userId;
  List<Map<String, dynamic>> conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    client = Client()
      ..setEndpoint('https://nyc.cloud.appwrite.io/v1')
      ..setProject('6929cfe0000789817066');

    databases = Databases(client);
    account = Account(client);
    realtime = Realtime(client);

    _loadConversations();
    _subscribeToNewMessages();
  }

  Future<void> _loadConversations() async {
    try {
      final user = await account.get();
      userId = user.$id;

      final response = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'chat',
        queries: [
          Query.or([
            Query.equal('senderId', userId!),
            Query.equal('receiverId', userId!),
          ]),
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );

      Map<String, Map<String, dynamic>> conversationsMap = {};

      for (var doc in response.documents) {
        final senderId = doc.data['senderId'];
        final receiverId = doc.data['receiverId'];
        final otherUserId = senderId == userId ? receiverId : senderId;

        if (!conversationsMap.containsKey(otherUserId) ||
            DateTime.parse(doc.$createdAt).isAfter(
                DateTime.parse(
                    conversationsMap[otherUserId]!['lastMessageTime']))) {
          conversationsMap[otherUserId] = {
            'userId': otherUserId,
            'lastMessage': doc.data['message'],
            'lastMessageTime': doc.$createdAt,
            'isUnread': receiverId == userId,
          };
        }
      }

      setState(() {
        conversations = conversationsMap.values.toList()
          ..sort((a, b) => DateTime.parse(b['lastMessageTime'])
              .compareTo(DateTime.parse(a['lastMessageTime'])));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToNewMessages() {
    realtime.subscribe([
      'databases.6929e1e300094da69676.collections.chat.documents'
    ]).stream.listen((response) {
      if (response.events.contains(
          'databases.6929e1e300094da69676.collections.chat.documents.*.create')) {
        _loadConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2A2A2A),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: const Text(
            'Messages',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFD700)),
            onPressed: () {
              // Ouvrir une boîte de dialogue pour démarrer une nouvelle conversation
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          : conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune conversation',
                        style: TextStyle(
                          color: Color(0xFFB0B8C1),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFFFD700),
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return _buildConversationItem(conversation);
                    },
                  ),
                ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Color(0xFF1A1A1A), size: 24),
        ),
        title: Text(
          'Utilisateur ${conversation['userId'].substring(0, 8)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          conversation['lastMessage'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: conversation['isUnread']
                ? const Color(0xFFFFD700)
                : const Color(0xFFB0B8C1),
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation['lastMessageTime']),
              style: const TextStyle(
                color: Color(0xFFB0B8C1),
                fontSize: 12,
              ),
            ),
            if (conversation['isUnread'])
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverId: conversation['userId'],
                receiverName: 'Utilisateur ${conversation['userId'].substring(0, 8)}',
              ),
            ),
          ).then((_) => _loadConversations());
        },
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return '';
    }
  }
}