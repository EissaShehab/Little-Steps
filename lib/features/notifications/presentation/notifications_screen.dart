import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:littlesteps/features/notifications/providers/notifications_provider.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Notifications",
      ),
      body: GradientBackground(
        child: notifications.when(
          data: (data) {
            if (data.isEmpty) {
              return Center(
                child: Text(
                  "No notifications yet.",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final notification = data[index];
                final timestamp = notification['timestamp'] as Timestamp;
                final date = timestamp.toDate();
                final formattedDate = DateFormat('MMM d, yyyy – h:mm a').format(date);

                return Dismissible(
                  key: ValueKey(notification['id']),
                  onDismissed: (_) async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('notifications')
                        .doc(notification['id'])
                        .delete();
                  },
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      notification['message'],
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    trailing: Text(
                      formattedDate,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              "Error: $e",
              style: const TextStyle(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}