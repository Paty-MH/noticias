import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification_event.dart';
import 'notification_state.dart';
import '../services/notification_service.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService service;

  NotificationBloc(this.service) : super(const NotificationState()) {
    on<LoadUserTopics>(_onLoadTopics);
    on<SubscribeTopic>(_onSubscribe);
    on<UnsubscribeTopic>(_onUnsubscribe);
  }

  Future<void> _onLoadTopics(
    LoadUserTopics event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final topics = await service.getUserTopics();
    emit(state.copyWith(topics: topics, loading: false));
  }

  Future<void> _onSubscribe(
    SubscribeTopic event,
    Emitter<NotificationState> emit,
  ) async {
    await service.subscribeToTopic(event.topic);
    add(LoadUserTopics());
  }

  Future<void> _onUnsubscribe(
    UnsubscribeTopic event,
    Emitter<NotificationState> emit,
  ) async {
    await service.unsubscribeFromTopic(event.topic);
    add(LoadUserTopics());
  }
}
