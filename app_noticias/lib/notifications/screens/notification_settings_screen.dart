import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../models/news_topics.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: newsTopics.map((cat) {
              final topic = cat['topic']!;
              final isSubscribed = state.topics.contains(topic);

              return SwitchListTile(
                title: Text(cat['name']!),
                subtitle: Text(topic),
                value: isSubscribed,
                onChanged: (value) {
                  if (value) {
                    context.read<NotificationBloc>().add(SubscribeTopic(topic));
                  } else {
                    context.read<NotificationBloc>().add(
                      UnsubscribeTopic(topic),
                    );
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
