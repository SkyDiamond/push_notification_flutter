import 'package:flutter/material.dart';

class NotificationDetailsPage extends StatelessWidget {
  final String payload;

  const NotificationDetailsPage({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
      ),
      body: Center(
        child: Text(payload),
      ),
    );
  }
}
