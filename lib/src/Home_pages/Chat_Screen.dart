import 'package:farmy/src/models/messages.dart';
import 'package:farmy/src/blocs/chat/chat_bloc.dart';
import 'package:farmy/src/blocs/chat/chat_event.dart';
import 'package:farmy/src/blocs/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
   static const Color _primaryGreen = Color.fromRGBO(0, 178, 0, 1);
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      context.read<ChatBloc>().add(LoadMessagesEvent(widget.chatId));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || currentUserId == null) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text.trim(),
      senderId: currentUserId!,
      timestamp: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessageEvent(
      message,
      widget.chatId, 
    ));

    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.otherUserName}"),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: currentUserId == null
          ? const Center(child: Text("Please login to continue"))
          : Column(
              children: [
                Expanded(
                  child: BlocConsumer<ChatBloc, ChatState>(
                    listener: (context, state) {
                      if (state is ChatError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is ChatNewMsg) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is ChatInitial) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ChatLoaded) {
                        if (state.messages.isEmpty) {
                          return const Center(
                            child: Text(
                              "No messages yet. Start the conversation!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            return messageBubble(
                              state.messages[index],
                              currentUserId!,
                            );
                          },
                        );
                      } else if (state is ChatError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ChatBloc>().add(
                                    LoadMessagesEvent(widget.chatId),
                                  );
                                },
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -2),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: _primaryGreen,
                          child: IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

Widget messageBubble(Message message, String currentUserId) {
  bool isMe = message.senderId == currentUserId;
  
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(
        maxWidth: 280,
      ),
      decoration: BoxDecoration(
        color: isMe ? const Color.fromRGBO(0, 178, 0, 1) : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: isMe ? Colors.white70 : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

String _formatTime(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  
  if (difference.inDays > 0) {
    return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
  } else if (difference.inHours > 0) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes}m ago";
  } else {
    return "Just now";
  }
}