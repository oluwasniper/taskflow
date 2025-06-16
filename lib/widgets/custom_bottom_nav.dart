import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Constants for better maintainability
  static const double _navHeight = 70.0;
  static const double _horizontalPadding = 24.0;
  static const double _blurRadius = 10.0;
  static const double _shadowOffset = -2.0;
  static const double _shadowOpacity = 0.05;

  // Navigation items with icons and labels
  static const List<NavItem> _navItems = [
    NavItem(FontAwesomeIcons.house, 'Home'),
    NavItem(FontAwesomeIcons.list, 'List'),
    NavItem(FontAwesomeIcons.timeline, 'Timeline'),
    NavItem(FontAwesomeIcons.box, 'Box'),
    NavItem(FontAwesomeIcons.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: _navHeight,
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(_shadowOpacity),
            blurRadius: _blurRadius,
            offset: const Offset(0, _shadowOffset),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          _navItems.length,
          (index) => _NavIcon(
            navItem: _navItems[index],
            index: index,
            selectedIndex: selectedIndex,
            onTap: () => onItemTapped(index),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  const NavItem(this.icon, this.label);
}

class _NavIcon extends StatelessWidget {
  final NavItem navItem;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _NavIcon({
    required this.navItem,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  static const double _iconSize = 24.0;
  static const double _tapTargetSize = 48.0;
  static const double _inactiveOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = index == selectedIndex;

    final iconColor = isSelected
        ? theme.primaryColor
        : (theme.iconTheme.color ?? Colors.grey).withOpacity(_inactiveOpacity);

    return Semantics(
      label: navItem.label,
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_tapTargetSize / 2),
        child: Container(
          width: _tapTargetSize,
          height: _tapTargetSize,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(navItem.icon, size: _iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
