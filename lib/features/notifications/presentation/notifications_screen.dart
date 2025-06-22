import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class NotificationsScreen extends ConsumerStatefulWidget {
  final String childId;

  const NotificationsScreen({super.key, required this.childId});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  final Map<String, bool> _expandedMap = {};
  late TabController _tabController;

  int allCount = 0;
  int vaccinationCount = 0;
  int weatherCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _updateCounts(List<QueryDocumentSnapshot> notifs) {
    allCount = notifs.length;
    vaccinationCount = notifs
        .where(
            (d) => (d.data() as Map<String, dynamic>)['type'] == 'vaccination')
        .length;
    weatherCount = notifs
        .where((d) => (d.data() as Map<String, dynamic>)['type'] == 'weather')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(title: tr.notifications),
        body: Center(child: Text(tr.error)),
      );
    }

    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('childId', isEqualTo: widget.childId)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: CustomAppBar(title: tr.notifications),
      body: GradientBackground(
        showPattern: false,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: "All ($allCount)"),
                Tab(text: "Vaccinations ($vaccinationCount)"),
                Tab(text: "Weather ($weatherCount)"),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: notificationsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("${tr.error}: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text(tr.noNotifications));
                  }

                  final selectedTab = _tabController.index;
                  final rawNotifs = snapshot.data!.docs;

                  _updateCounts(rawNotifs);

                  final filteredNotifs = rawNotifs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'] ?? 'unknown';
                    if (selectedTab == 1) return type == 'vaccination';
                    if (selectedTab == 2) return type == 'weather';
                    return true;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredNotifs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredNotifs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final id = doc.id;
                      final timestamp =
                          (data['timestamp'] as Timestamp?)?.toDate();
                      final formattedDate = timestamp != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp)
                          : 'No date';
                      final isExpanded = _expandedMap[id] ?? false;
                      final isNew = data['delivered'] == false;

                      return Dismissible(
                        key: Key(id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          try {
                            await doc.reference.delete();
                          } catch (e) {
                            logger.e("❌ Error deleting notification: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${tr.error}: $e")),
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.grey.shade800,
                          child: ExpansionTile(
                            key: PageStorageKey(id),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: const Icon(Icons.notifications,
                                  color: Colors.blue),
                            ),
                            trailing: isNew
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "NEW",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  )
                                : const Icon(Icons.notifications_active,
                                    color: Colors.green),
                            title: Text(
                              data['title'] ?? 'Notification',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "- $formattedDate\n${data['childName'] ?? ''}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            childrenPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (expanded) async {
                              setState(() {
                                _expandedMap[id] = expanded;
                              });

                              if (expanded && isNew) {
                                try {
                                  await doc.reference.update({
                                    'delivered': true,
                                    'deliveredAt':
                                        DateTime.now().toIso8601String(),
                                  });
                                  logger.i(
                                      "✅ Marked notification $id as delivered");
                                } catch (e) {
                                  logger.e(
                                      "❌ Failed to update delivered state: $e");
                                }
                              }
                            },
                            children: [
                              Text(
                                isExpanded ? "Less Details" : "More Details",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data['message'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
