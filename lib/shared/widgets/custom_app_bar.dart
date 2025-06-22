import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  final bool showBackButton;
  final bool? cameFromChartScreen;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.trailingIcon,
    this.onTrailingPressed,
    this.showBackButton = true,
    this.cameFromChartScreen,
  });

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;

    return AppBar(
      title: Text(
        title,
        style: appBarTheme.titleTextStyle?.copyWith(
          color: appBarTheme.foregroundColor,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: appBarTheme.foregroundColor,
              ),
              onPressed: onBackPressed ??
                  () {
                    if (cameFromChartScreen == true) {
                      // استخدام GoRouter لتنظيف الـ stack والذهاب للـ Home
                      context.go('/home'); // الذهاب مباشرة للـ Home
                    } else if (GoRouter.of(context).canPop()) {
                      context.pop(); // عمل pop عادي إذا كان في شي في الـ stack
                    } else {
                      context.go(
                          '/home'); // الذهاب للـ Home إذا مفيش شي في الـ stack
                    }
                  },
            )
          : null,
      actions: [
        if (trailingIcon != null && onTrailingPressed != null)
          IconButton(
            icon: Icon(
              trailingIcon,
              color: appBarTheme.foregroundColor,
            ),
            onPressed: onTrailingPressed,
          ),
      ],
      backgroundColor: appBarTheme.backgroundColor,
      elevation: appBarTheme.elevation,
      iconTheme: appBarTheme.iconTheme,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
