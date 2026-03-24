import 'package:flutter/material.dart';

PreferredSizeWidget cnAppBar({
  required BuildContext context,
  required VoidCallback? onLogout,
  bool showLogo = false,
  List<Widget> extraActions = const [],
}) {
  final canPop = Navigator.of(context).canPop();

  Widget? leading;
  double? leadingWidth;
  if (canPop) {
    leadingWidth = 56;
    leading = IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back',
    );
  } else if (showLogo) {
    leadingWidth = 72;
    leading = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Image.asset(
        'assets/cn_lions_logo.png',
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
    );
  }

  return AppBar(
    centerTitle: true,
    title: const Text('CN Pride Point'),
    leadingWidth: leadingWidth,
    leading: leading,
    actions: [
      ...extraActions,
      if (onLogout != null)
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        ),
    ],
  );
}
