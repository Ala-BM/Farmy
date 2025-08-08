import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmy/src/Home_pages/Chat_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmy/src/blocs/chat/chat_bloc.dart';
import 'package:farmy/src/blocs/chat/chat_event.dart';
import 'package:farmy/src/blocs/chat/chat_state.dart';
import 'package:farmy/src/Landing_pages/welcome.dart';

class DrawerChat extends StatefulWidget {
  const DrawerChat({super.key});

  @override
  State<DrawerChat> createState() => _DrawerChatState();
}

class _DrawerChatState extends State<DrawerChat> {
  static const Color _primaryGreen = Color.fromRGBO(0, 178, 0, 1);
  static const String _fontFamily = 'Poppins-SemiBold';

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<ChatBloc>().add(LoadChatsEvent(currentUser.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          _buildChatSection(),
          const Spacer(),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      padding: EdgeInsets.zero,
      child: Container(
        color: _primaryGreen,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.agriculture,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                "Hello Farmy",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: _fontFamily,
                  fontSize: 20,
                ),
              ),
          
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: const Text(
              "Your Conversations",
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  );
                } else if (state is ChatSLoaded) {
                  return _buildChatList(state.chats);
                } else if (state is ChatEmpty) {
                  return _buildEmptyChatState();
                } else if (state is ChatError) {
                  return _buildChatErrorState(state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
Widget _buildChatList(List<Map<String, dynamic>> chats) {
  return ListView.builder(
    itemCount: chats.length,
    itemBuilder: (context, index) {
      final chat = chats[index];
      return FutureBuilder<Widget>(
        future: _buildChatTile(chat),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(title: Text("Loading..."));
          } else if (snapshot.hasError) {
            return ListTile(title: Text("Error: ${snapshot.error}"));
          } else {
            return snapshot.data!;
          }
        },
      );
    },
  );
}


  Future<Widget> _buildChatTile(Map<String, dynamic> chat) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final participants = List<String>.from(chat['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'Unknown User',
    );

    final lastMessage = chat['lastMessage'] ?? '';
    final lastMessageTime = chat['lastMessageTime'];
    final chatId = chat['id'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _primaryGreen.withOpacity(0.1),
        child: const Icon(
          Icons.person,
          color: _primaryGreen,
          size: 20,
        ),
      ),
      title: Text(
        await _getUserDisplayName(otherUserId),
        style: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: lastMessage.isNotEmpty
          ? Text(
              lastMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              "No messages yet",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
      trailing: lastMessageTime != null
          ? Text(
              _formatChatTime(lastMessageTime),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            )
          : null,
      onTap: () => _openChat(chatId, otherUserId),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No conversations yet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start chatting with farmers",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                context.read<ChatBloc>().add(LoadChatsEvent(currentUser.uid));
              }
            },
            child: const Text(
              "Retry",
              style: TextStyle(color: _primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontFamily: _fontFamily,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() async {
    Navigator.pop(context);

    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Welcome(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logout failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openChat(String chatId, String otherUserId) async {
    Navigator.pop(context);

  final otherUserName = await _getUserDisplayName(otherUserId);

  if (!mounted) return; 

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatId: chatId,
        otherUserName: otherUserName,
      ),
    ),
  );
  }

  Future<String> _getUserDisplayName(String userId) async {
  final userDoc = await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .get();

  if (userDoc.exists) {
    final user = userDoc.data();
    return user?["name"] ?? "No name field found";
  } else {
    return "No user found with that UID";
  }
}


  String _formatChatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      DateTime dateTime;
      if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp.toString().contains('Timestamp')) {
        dateTime = timestamp.toDate();
      } else {
        return '';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return "${difference.inDays}d";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m";
      } else {
        return "now";
      }
    } catch (e) {
      return '';
    }
  }
}
