import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.trailingIcon,
    this.onTrailingPressed,
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: appBarTheme.foregroundColor,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
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