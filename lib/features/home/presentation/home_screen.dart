import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/weather/data/weather_alert_service.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/features/child_profile/presentation/childprofile_screen.dart';
import 'package:littlesteps/features/symptom_checker_api/symptoms_screen.dart';
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showChildSelector(
      BuildContext context, List<ChildProfile> children, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr.selectChild,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: children.length + 1,
                  itemBuilder: (context, index) {
                    if (index == children.length) {
                      return ListTile(
                        leading:
                            Icon(Icons.settings, color: colorScheme.primary),
                        title: Text(
                          tr.manageChildren,
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ChildProfileScreen()),
                          );
                        },
                      );
                    }
                    final child = children[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (child.photoUrl != null &&
                                child.photoUrl!.isNotEmpty)
                            ? NetworkImage(child.photoUrl!)
                            : null,
                        child: (child.photoUrl == null ||
                                child.photoUrl!.isEmpty)
                            ? Icon(Icons.child_care, color: colorScheme.primary)
                            : null,
                      ),
                      title: Text(child.name),
                      onTap: () {
                        ref
                            .read(selectedChildProvider.notifier)
                            .update((old) => child);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = AppLocalizations.of(context)!;

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
                  final selectedChild = ref.watch(selectedChildProvider);
                  return Column(
                    children: [
                      // Fixed section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildHeaderCard(
                                  selectedChild, children, context, ref),
                            ),
                            const SizedBox(height: 24),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildSwipeableMissionCard(context),
                            ),
                          ],
                        ),
                      ),
                      // Scrollable section
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 70),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: QuickActionsGrid(
                                onManageChildren: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChildProfileScreen()),
                                ),
                              ),
                            ),
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
    final tr = AppLocalizations.of(context)!;

    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.transparent,
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey[850]!, Colors.grey[700]!]
                : [
                    colorScheme.surface,
                    colorScheme.primary.withOpacity(0.1),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icons/baby.png',
                    width: 48,
                    height: 48,
                  ),
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
                                color: Colors.amber,
                                fontSize: 32,
                                shadows: [
                                  Shadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: 'ittleSteps',
                              style: AppTypography.headingStyle.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedChild != null
                            ? '${tr.hello}, ${selectedChild.name}'
                            : children.isNotEmpty
                                ? '${tr.hello}, ${children.first.name}'
                                : '${tr.hello}, ${tr.guest}',
                        style: AppTypography.bodyStyle.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (children.isNotEmpty)
              GestureDetector(
                onTap: () => _showChildSelector(context, children, ref),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: colorScheme.primary.withOpacity(0.5), width: 1),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.2),
                        colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedChild?.name ?? children.first.name,
                        style: AppTypography.bodyStyle.copyWith(
                          color: colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _fadeAnimation.value,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: colorScheme.primary,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  tr.noChildrenRegistered,
                  style: AppTypography.bodyStyle.copyWith(
                    color: colorScheme.error,
                    fontSize: 16,
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
    final tr = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> missionData = [
      {
        'title': tr.monitorGrowth,
        'description': tr.trackGrowthDescription,
        'iconPath': 'assets/icons/chart.png',
        'color': isDark ? Colors.orange[400]! : Colors.orange,
      },
      {
        'title': tr.ensureHealth,
        'description': tr.ensureHealthDescription,
        'iconPath': 'assets/icons/syringe.png',
        'color': isDark ? Colors.green[400]! : Colors.green,
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: missionData.length,
            itemBuilder: (context, index) {
              final data = missionData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Transform.scale(
                  scale: _pageController.hasClients &&
                          (_pageController.page?.round() ?? 0) == index
                      ? 1.0
                      : 0.95,
                  child: _buildMissionCard(
                    context: context,
                    title: data['title'] as String,
                    description: data['description'] as String,
                    iconPath: data['iconPath'] as String,
                    color: data['color'] as Color,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _pageController,
          count: missionData.length,
          effect: ExpandingDotsEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: colorScheme.primary,
            dotColor: colorScheme.onSurface.withOpacity(0.3),
            expansionFactor: 4,
            spacing: 8,
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
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.grey[600]! : Colors.transparent,
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: colorScheme.outline.withOpacity(0.5), width: 1),
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey[800]!, Colors.grey[700]!]
                : [
                    colorScheme.surface,
                    color.withOpacity(0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.7),
                    color.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _fadeAnimation.value,
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.subheadingStyle.copyWith(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.bodyStyle.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> navItems = [
      {
        'icon': Icons.home_rounded,
        'activeIcon': Icons.home_outlined,
        'label': tr.home,
        'route': '/',
        'requiresChild': false,
        'semanticLabel': tr.home,
      },
      {
        'icon': Icons.sick_rounded,
        'activeIcon': Icons.sick_outlined,
        'label': tr.symptoms,
        'route': '/symptoms',
        'requiresChild': true,
        'semanticLabel': tr.symptoms,
      },
      {
        'icon': Icons.notifications_rounded,
        'activeIcon': Icons.notifications_none,
        'label': tr.notifications,
        'route': '/notifications',
        'requiresChild': true,
        'semanticLabel': tr.notifications,
      },
      {
        'icon': Icons.person_rounded,
        'activeIcon': Icons.person_outline,
        'label': tr.profile,
        'route': '/profile',
        'requiresChild': false,
        'semanticLabel': tr.profile,
      },
    ];

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        final item = navItems[index];
        final selectedChild = ref.read(selectedChildProvider);

        if (item['requiresChild'] && selectedChild == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tr.selectChildFirst,
                style: AppTypography.bodyStyle.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
              elevation: 8,
              showCloseIcon: true,
              closeIconColor: colorScheme.onErrorContainer,
            ),
          );
          return;
        }

        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SymptomsScreen(child: selectedChild!),
              ),
            );
            break;
          case 2:
            context.push('/notifications?childId=${selectedChild!.id}');
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark
          ? colorScheme.surface.withOpacity(0.9)
          : colorScheme.background.withOpacity(0.95),
      elevation: 8,
      selectedItemColor: const Color(0xFF4A90E2),
      unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.7),
      showUnselectedLabels: true,
      selectedLabelStyle: AppTypography.captionStyle.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      unselectedLabelStyle: AppTypography.captionStyle.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
      items: List.generate(navItems.length, (index) {
        final isSelected = _selectedIndex == index;
        final item = navItems[index];
        return BottomNavigationBarItem(
          icon: Icon(
            isSelected ? item['activeIcon'] : item['icon'],
            size: 24,
          ),
          label: item['label'],
          tooltip: item['semanticLabel'],
        );
      }),
    );
  }
}