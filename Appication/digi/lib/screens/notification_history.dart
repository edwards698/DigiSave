import 'package:flutter/material.dart';

class NotificationHistoryScreen extends StatelessWidget {
  final List<Map<String, String>> notifications;

  const NotificationHistoryScreen({Key? key, required this.notifications})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notification['title'] ?? ''),
                  subtitle: Text(notification['body'] ?? ''),
                );
              },
            ),
    );
  }
}
