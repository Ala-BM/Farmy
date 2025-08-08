import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmy/src/blocs/chat/chat_event.dart';
import 'package:farmy/src/blocs/chat/chat_state.dart';
import 'package:farmy/src/models/messages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
   StreamSubscription? _subscription;
  ChatBloc() : super(ChatInitial()) {
    on<LoadChatsEvent>(_onLoadChatsEvent);
    on<ListenerMessagesEvent>(_onListenerMessangerEvent);
    on<LoadMessagesEvent>(_onLoadMessagesEvent);
    on<SendMessageEvent>(_onSendMessageEvent);
    on<NewChatEvent>(_onNewChatEvent);
  }
  FutureOr<void> _onLoadMessagesEvent(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      final messagesQuery = await FirebaseFirestore.instance
          .collection("chats")  
          .doc(event.chatId)  
          .collection("messages") 
          .orderBy('timestamp') 
          .get();
      if (messagesQuery.docs.isEmpty){
        emit(ChatEmpty());
      }

      final messages = messagesQuery.docs
          .map((doc) => Message.fromMap(doc.data()))
          .toList();
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError("Failed to load messages: $e"));
    }
  }

  FutureOr<void> _onSendMessageEvent(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(event.chatId)  
          .collection("messages")
          .add({
            ...event.msg.toMap(),
            'timestamp': FieldValue.serverTimestamp(), 
          });

      await FirebaseFirestore.instance
          .collection("chats")
          .doc(event.chatId)  
          .update({
            "lastMessage": event.msg.text,
            "lastMessageTime": FieldValue.serverTimestamp(),
          });

      add(LoadMessagesEvent(event.chatId));
    } catch (e) {
      emit(const ChatError("Failed to send message"));
    }
  }

  Future<void> _onLoadChatsEvent(
      LoadChatsEvent event, Emitter<ChatState> emit) async {
    try {
      final chats = await FirebaseFirestore.instance
          .collection("chats")
          .where('participants', arrayContains: event.userId)
          .orderBy('lastMessageTime', descending: true) 
          .get();

      if (chats.docs.isEmpty) {
        emit(ChatEmpty());
        return;
      }

      List<Map<String, dynamic>> chatsList = chats.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      emit(ChatSLoaded(chatsList));
    } catch (e) {
      emit(ChatError("Failed to Load Chats! $e"));
    }
  }

  FutureOr<void> _onNewChatEvent(NewChatEvent event, Emitter<ChatState> emit) async {
    try {
      await FirebaseFirestore.instance.collection("chats").add({
        "participants": [event.userId1, event.userId2],
        "createdAt": FieldValue.serverTimestamp(),
        "lastMessage": "",
        "lastMessageTime": FieldValue.serverTimestamp(),
      });
      add(LoadChatsEvent(event.userId1));//only buyer can start a chat
    } catch (e) {
      emit(const ChatError("Failed to create new chat!"));
    }
  }

  Future<void> _onListenerMessangerEvent(ListenerMessagesEvent event, Emitter<ChatState> emit) async {
     await _subscription?.cancel();

     _subscription=FirebaseFirestore.instance
          .collection("chats")  
          .doc(event.chatId)  
          .collection("messages") 
          .snapshots().listen((snapshot){
             if (snapshot.docs.isEmpty) {
        emit(ChatEmpty());
      } else {
        add(LoadMessagesEvent(event.chatId));
      }
          },
              onError: (error) {
      if (!emit.isDone) {
        emit(ChatError(error.toString()));
      }
    },
          );
  }
    @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}