import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final List<String> topics;
  final bool loading;

  const NotificationState({this.topics = const [], this.loading = false});

  NotificationState copyWith({List<String>? topics, bool? loading}) {
    return NotificationState(
      topics: topics ?? this.topics,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [topics, loading];
}
