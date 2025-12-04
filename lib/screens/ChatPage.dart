import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Client client;
  late Databases databases;
  late Account account;
  late Realtime realtime;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? userId;
  List<Map<String, dynamic>> messages = [];
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

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final user = await account.get();
      userId = user.$id;

      await _loadMessages();
      _subscribeToMessages();
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await databases.listDocuments(
        databaseId: '6929e1e300094da69676',
        collectionId: 'chat',
        queries: [
          Query.or([
            Query.and([
              Query.equal('senderId', userId!),
              Query.equal('receiverId', widget.receiverId),
            ]),
            Query.and([
              Query.equal('senderId', widget.receiverId),
              Query.equal('receiverId', userId!),
            ]),
          ]),
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );

      setState(() {
        messages = response.documents
            .map((doc) => {
                  'id': doc.$id,
                  'senderId': doc.data['senderId'],
                  'receiverId': doc.data['receiverId'],
                  'message': doc.data['message'],
                  'timestamp': doc.data['timestamp'],
                  'createdAt': doc.$createdAt,
                })
            .toList()
            .reversed
            .toList();
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToMessages() {
    realtime.subscribe([
      'databases.6929e1e300094da69676.collections.chat.documents'
    ]).stream.listen((response) {
      if (response.events.contains(
          'databases.6929e1e300094da69676.collections.chat.documents.*.create')) {
        final payload = response.payload;
        final senderId = payload['senderId'];
        final receiverId = payload['receiverId'];

        if ((senderId == userId && receiverId == widget.receiverId) ||
            (senderId == widget.receiverId && receiverId == userId)) {
          setState(() {
            messages.add({
              'id': payload['\$id'],
              'senderId': senderId,
              'receiverId': receiverId,
              'message': payload['message'],
              'timestamp': payload['timestamp'],
              'createdAt': payload['\$createdAt'],
            });
          });
          _scrollToBottom();
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || userId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await databases.createDocument(
        databaseId: '6929e1e300094da69676',
        collectionId: 'chat',
        documentId: ID.unique(),
        data: {
          'senderId': userId!,
          'receiverId': widget.receiverId,
          'message': messageText,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2A2A2A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'En ligne',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFFFD700)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          : Column(
              children: [
                Expanded(
                  child: messages.isEmpty
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
                                'Aucun message',
                                style: TextStyle(
                                  color: Color(0xFFB0B8C1),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message['senderId'] == userId;

                            return _buildMessageBubble(message, isMe);
                          },
                        ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  color: Color(0xFF1A1A1A), size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      )
                    : null,
                color: isMe ? null : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? const Color(0xFFFFD700).withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: TextStyle(
                      color: isMe ? const Color(0xFF1A1A1A) : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: TextStyle(
                      color: isMe
                          ? const Color(0xFF1A1A1A).withOpacity(0.6)
                          : const Color(0xFFB0B8C1),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  color: Color(0xFF1A1A1A), size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Votre message...',
                    hintStyle: TextStyle(color: Color(0xFFB0B8C1)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF1A1A1A)),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}