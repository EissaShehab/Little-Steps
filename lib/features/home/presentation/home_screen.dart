import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/child_profile/providers/child_provider.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/features/child_profile/presentation/childprofile_screen.dart';
import 'package:littlesteps/features/symptoms/symptoms_screen.dart';
import 'package:littlesteps/features/notifications/presentation/notifications_screen.dart';
import 'package:littlesteps/features/profile/profile_screen.dart';
import 'package:littlesteps/providers/providers.dart' as child_provider;
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/quick_actions_grid.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:logger/logger.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final logger = Logger();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        showPattern: false,
        child: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              final childProfilesAsync =
                  ref.watch(child_provider.childProfilesProvider);
              return childProfilesAsync.when(
                data: (children) {
                  logger.d(
                      "Children loaded: ${children.map((c) => c.name).toList()}");
                  final selectedChild = ref.watch(selectedChildProvider);
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderCard(
                                  selectedChild, children, context, ref),
                              const SizedBox(height: 24),
                              _buildSwipeableMissionCard(context),
                              const SizedBox(height: 24),
                              QuickActionsGrid(
                                onManageChildren: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChildProfileScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
                error: (e, stack) => Center(
                  child: Text(
                    'Error loading children: $e',
                    style: AppTypography.bodyStyle.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeaderCard(ChildProfile? selectedChild,
      List<ChildProfile> children, BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.transparent,
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/baby.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'L',
                              style: AppTypography.headingStyle.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                            TextSpan(
                              text: 'ittleSteps',
                              style: AppTypography.headingStyle.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedChild != null
                            ? 'Hello, ${selectedChild.name}'
                            : children.isNotEmpty
                                ? 'Hello, ${children.first.name}'
                                : 'Hello, Guest',
                        style: AppTypography.bodyStyle.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (children.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.outline.withOpacity(0.5), width: 1),
                  color: colorScheme.primary.withOpacity(0.1),
                ),
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ChildProfile>(
                        value: selectedChild ?? children.first,
                        items: children.map((child) {
                          return DropdownMenuItem<ChildProfile>(
                            value: child,
                            key: ValueKey(child.id),
                            child: Text(
                              child.name,
                              style: AppTypography.bodyStyle.copyWith(
                                color: colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (child) {
                          if (child != null) {
                            ref
                                .read(selectedChildProvider.notifier)
                                .update((old) => child);
                            logger.i(
                                "✅ Switched to child ${child.name} with ID ${child.id}");
                          }
                        },
                        dropdownColor: colorScheme.surface,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: colorScheme.primary,
                        ),
                        style: AppTypography.bodyStyle,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 4,
                        isDense: true,
                        iconSize: 24,
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '⚠️ No children registered. Please add a child.',
                  style: AppTypography.bodyStyle.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeableMissionCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> missionData = [
      {
        'title': 'Monitor Growth',
        'description':
            'Track your child’s growth milestones with precision and care.',
        'iconPath': 'assets/icons/chart.png',
        'color': isDark
            ? Colors.orange[300]!
            : Colors.orange, // Adjust for visibility
      },
      {
        'title': 'Ensure Health',
        'description':
            'Keep your child healthy with vaccinations and health tips.',
        'iconPath': 'assets/icons/syringe.png',
        'color': isDark ? Colors.green[300]! : Colors.green,
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: missionData.length,
            itemBuilder: (context, index) {
              final data = missionData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildMissionCard(
                  context: context,
                  title: data['title'] as String,
                  description: data['description'] as String,
                  iconPath: data['iconPath'] as String,
                  color: data['color'] as Color,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _pageController,
          count: missionData.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: colorScheme.primary,
            dotColor: colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard({
    required BuildContext context,
    required String title,
    required String description,
    required String iconPath,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.transparent,
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: colorScheme.outline.withOpacity(0.5), width: 1),
          color: isDark ? Colors.grey[800] : colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.5),
              ),
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.subheadingStyle.copyWith(
                      color: color,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodyStyle.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SymptomsScreen()));
            break;
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
            break;
        }
      },
      selectedItemColor: colorScheme.onPrimary,
      unselectedItemColor:
          isDark ? Colors.grey[300]! : colorScheme.onSurfaceVariant,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.primary,
      elevation: 8,
      selectedLabelStyle:
          AppTypography.captionStyle.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTypography.captionStyle,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sick),
          label: 'Symptoms',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
