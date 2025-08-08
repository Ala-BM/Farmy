import 'package:equatable/equatable.dart';
import 'package:farmy/src/models/messages.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;

  const LoadMessagesEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class LoadChatsEvent extends ChatEvent {
  final String userId;

  const LoadChatsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
class NewChatEvent extends ChatEvent{
  final String userId1;
  final String userId2;
  const NewChatEvent(this.userId1, this.userId2);
    @override
  List<Object> get props => [userId1,userId2];

}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final Message msg;

  const SendMessageEvent(this.msg, this.chatId);

  @override
  List<Object> get props => [msg];
}
