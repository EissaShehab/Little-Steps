import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:littlesteps/features/health_tips/providers/health_tips_provider.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

final logger = Logger();

class HealthTipsScreen extends ConsumerStatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  ConsumerState<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends ConsumerState<HealthTipsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  static const int _pageSize = 20;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync:
          this, // 'this' is now a valid TickerProvider due to SingleTickerProviderStateMixin
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTips();
    }
  }

  Future<void> _loadMoreTips() async {
    if (!mounted) return;
    setState(() => _currentPage++);
    logger.i("🔍 Loading more health tips, page $_currentPage");
  }

  Null Function() _debounce(Function action, Duration duration) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, () => action());
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(healthTipsFilterProvider);
    final tipsStream = FirebaseFirestore.instance
        .collection('health_tips')
        .orderBy('createdAt', descending: true)
        .startAfter([_currentPage * _pageSize])
        .limit(_pageSize)
        .snapshots();

    return Scaffold(
      appBar: CustomAppBar(
        title: "Health Tips",
      ),
      body: GradientBackground(
        showPattern: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: _SearchField(
                controller: _searchController,
                onChanged: (value) => _debounce(
                  () => ref
                      .read(healthTipsFilterProvider.notifier)
                      .setSearchQuery(value),
                  const Duration(milliseconds: 300),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) => true,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  controller: ScrollController(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    "All",
                    "Nutrition",
                    "Vaccination",
                    "Sleep",
                    "Physical Activity",
                    "Oral Health"
                  ].map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: AppTypography.captionStyle.copyWith(
                            color: filter.selectedCategory == category
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : colorScheme.onSurface),
                          ),
                        ),
                        selected: filter.selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            ref
                                .read(healthTipsFilterProvider.notifier)
                                .setCategory(category);
                          }
                        },
                        selectedColor:
                            Colors.greenAccent, // Health tips accent color
                        backgroundColor:
                            isDark ? Colors.grey[800] : colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.greenAccent.withOpacity(0.5),
                        ),
                        elevation: 2,
                        pressElevation: 4,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: _buildTipsList(tipsStream, filter, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsList(Stream<QuerySnapshot> tipsStream,
      HealthTipsFilter filter, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: tipsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 2.5,
              semanticsLabel: 'Loading health tips',
            ),
          );
        }
        if (snapshot.hasError) {
          logger.e("❌ Error loading health tips: ${snapshot.error}");
          return Center(
            child: Text(
              'Error loading health tips. Please try again.',
              style: AppTypography.bodyStyle.copyWith(
                color: isDark ? Colors.redAccent : colorScheme.error,
              ),
              semanticsLabel: 'Health tips error message',
            ),
          );
        }
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _processTips(snapshot.data!.docs, filter),
          builder: (context, tipSnapshot) {
            if (!tipSnapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 2.5,
                  semanticsLabel: 'Processing health tips',
                ),
              );
            }
            final tips = tipSnapshot.data!;
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: tips.length,
              itemBuilder: (context, index) {
                var tip = tips[index];
                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildTipCard(tip, context),
                  ),
                );
              },
              addAutomaticKeepAlives: true,
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _processTips(
      List<QueryDocumentSnapshot> docs, HealthTipsFilter filter) async {
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    await Isolate.spawn(_filterTipsIsolate, [docs, filter, sendPort]);
    return await receivePort.first as List<Map<String, dynamic>>;
  }

  static void _filterTipsIsolate(List<dynamic> args) {
    final List<QueryDocumentSnapshot> docs = args[0];
    final HealthTipsFilter filter = args[1];
    final SendPort sendPort = args[2];

    final tips = docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        "id": doc.id,
        "title": data["title"] ?? '',
        "content": data["content"] ?? '',
        "category": data["category"] ?? 'Uncategorized',
        "source": data["source"] ?? 'Unknown',
        "age_range": data["age_range"] ?? 'All Ages',
      };
    }).toList();

    final filteredTips = tips.where((tip) {
      final matchesCategory = filter.selectedCategory == "All" ||
          tip["category"].toString().toLowerCase() ==
              filter.selectedCategory.toLowerCase();
      final matchesSearch = filter.searchQuery.isEmpty ||
          tip["title"]
              .toString()
              .toLowerCase()
              .contains(filter.searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    Isolate.exit(sendPort, filteredTips);
  }

  Widget _buildTipCard(Map<String, dynamic> tip, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.transparent,
          width: 1,
        ),
      ),
      color: isDark ? Colors.grey[800] : colorScheme.surface,
      child: ExpansionTile(
        leading: Icon(
          _getCategoryIcon(tip["category"].toString()),
          color: Colors.greenAccent, // Health tips accent color
        ),
        title: Semantics(
          label: 'Health tip title: ${tip["title"]}',
          child: Text(
            tip["title"],
            style: AppTypography.subheadingStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : colorScheme.onSurface,
            ),
          ),
        ),
        subtitle: Semantics(
          label: 'Category: ${tip["category"]}',
          child: Text(
            tip["category"],
            style: AppTypography.bodyStyle.copyWith(
              color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Content: ${tip["content"]}',
                  child: Text(
                    tip["content"],
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: 'Source: ${tip["source"]}',
                  child: Text(
                    "Source: ${tip["source"]}",
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _SearchField({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Search health tips...",
        hintStyle: AppTypography.bodyStyle.copyWith(
          color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : colorScheme.surface,
      ),
      style: AppTypography.bodyStyle.copyWith(
        color: isDark ? Colors.white : colorScheme.onSurface,
      ),
      onChanged: onChanged,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "nutrition":
        return Icons.restaurant;
      case "vaccination":
        return Icons.medical_services;
      case "sleep":
        return Icons.bedtime;
      case "physical activity":
        return Icons.directions_run;
      case "oral health":
        return Icons.health_and_safety;
      default:
        return Icons.info;
    }
  }
}
