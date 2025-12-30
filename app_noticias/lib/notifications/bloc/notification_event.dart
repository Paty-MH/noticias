import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserTopics extends NotificationEvent {}

class SubscribeTopic extends NotificationEvent {
  final String topic;

  const SubscribeTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

class UnsubscribeTopic extends NotificationEvent {
  final String topic;

  const UnsubscribeTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}
