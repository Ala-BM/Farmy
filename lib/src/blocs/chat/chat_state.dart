import 'package:equatable/equatable.dart';
import 'package:farmy/src/models/messages.dart';

abstract class ChatState extends Equatable {
  const ChatState();
    @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {

}

class ChatLoading extends ChatState {}
class ChatEmpty extends ChatState {}


class ChatLoaded extends ChatState {
  final List<Message> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatSLoaded extends ChatState {
  final List<Map<String ,dynamic>> chats;

  const ChatSLoaded(this.chats);

  @override
  List<Object> get props => [chats];
}


class ChatNewMsg extends ChatState {
  final Message msg;

  const ChatNewMsg(this.msg);

  @override
  List<Object> get props => [msg];
}


class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
