import 'package:flutter/material.dart';

class EcoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const EcoAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
    );
  }
}
