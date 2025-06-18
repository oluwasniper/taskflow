import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool hasFloatingButton;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.hasFloatingButton = true,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late List<AnimationController> _itemControllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;
  late Animation<double> _rotationAnimation;

  bool _isExpanded = false;

  static const double _floatingButtonSize = 70.0;
  static const double _horizontalPadding = 40.0;
  static const double _verticalPadding = 60.0;
  static const double _containerHeight = 105.0;
  static const double _floatingButtonRadius = 35.0;
  static const double _iconSize = 30.0;
  static const double _itemSize = 50.0;

  final List<NavItem> _navItems = const [
    NavItem(FontAwesomeIcons.house, 'Home'),
    NavItem(FontAwesomeIcons.list, 'List'),
    NavItem(FontAwesomeIcons.timeline, 'Timeline'),
    NavItem(FontAwesomeIcons.box, 'Box'),
    NavItem(FontAwesomeIcons.user, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.75).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _itemControllers = List.generate(4, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 300 + (index * 50)),
        vsync: this,
      );
    });

    _slideAnimations = [
      Tween<Offset>(begin: Offset.zero, end: const Offset(-1.8, -1.2)).animate(
        CurvedAnimation(parent: _itemControllers[0], curve: Curves.elasticOut),
      ),
      Tween<Offset>(begin: Offset.zero, end: const Offset(-2.2, -0.2)).animate(
        CurvedAnimation(parent: _itemControllers[1], curve: Curves.elasticOut),
      ),
      Tween<Offset>(begin: Offset.zero, end: const Offset(2.2, -0.2)).animate(
        CurvedAnimation(parent: _itemControllers[2], curve: Curves.elasticOut),
      ),
      Tween<Offset>(begin: Offset.zero, end: const Offset(1.8, -1.2)).animate(
        CurvedAnimation(parent: _itemControllers[3], curve: Curves.elasticOut),
      ),
    ];

    _scaleAnimations = _itemControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _rotationController.forward();
      for (int i = 0; i < _itemControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) _itemControllers[i].forward();
        });
      }
    } else {
      _rotationController.reverse();
      for (int i = _itemControllers.length - 1; i >= 0; i--) {
        Future.delayed(
          Duration(milliseconds: (_itemControllers.length - 1 - i) * 50),
          () {
            if (mounted) _itemControllers[i].reverse();
          },
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (_isExpanded) {
      _toggleExpansion();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onItemTapped(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        widget.backgroundColor ?? const Color(0xff333333);
    final effectiveSelectedColor =
        widget.selectedColor ?? const Color(0xffFDB623);
    final effectiveUnselectedColor = widget.unselectedColor ?? Colors.white70;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          child: SizedBox(
            height: _containerHeight + 100,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (_isExpanded)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggleExpansion,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: Colors.black.withAlpha(77),
                      ),
                    ),
                  ),
                ..._buildAnimatedItems(
                  effectiveBackgroundColor,
                  effectiveSelectedColor,
                  effectiveUnselectedColor,
                ),
                Positioned(
                  bottom: 35,
                  child: _buildMainFloatingButton(
                    effectiveBackgroundColor,
                    effectiveSelectedColor,
                    effectiveUnselectedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedItems(
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    List<Widget> items = [];
    List<int> itemIndices = [0, 1, 3, 4];

    for (int i = 0; i < itemIndices.length; i++) {
      int itemIndex = itemIndices[i];
      items.add(
        AnimatedBuilder(
          animation: _slideAnimations[i],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _slideAnimations[i].value.dx * _itemSize,
                _slideAnimations[i].value.dy * _itemSize - 35,
              ),
              child: Transform.scale(
                scale: _scaleAnimations[i].value,
                child: _buildFloatingNavItem(
                  itemIndex,
                  backgroundColor,
                  selectedColor,
                  unselectedColor,
                ),
              ),
            );
          },
        ),
      );
    }

    return items;
  }

  Widget _buildMainFloatingButton(
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final isSelected = widget.selectedIndex == 2;
    final floatingItem = _navItems[2];

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            shadowColor: Colors.black.withAlpha(77),
            borderRadius: BorderRadius.circular(_floatingButtonRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(_floatingButtonRadius),
              onTap: () {
                if (_isExpanded) {
                  _toggleExpansion();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    widget.onItemTapped(2);
                  });
                } else {
                  _toggleExpansion();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: _floatingButtonSize,
                width: _floatingButtonSize,
                decoration: BoxDecoration(
                  color: _isExpanded
                      ? selectedColor
                      : (isSelected ? selectedColor : backgroundColor),
                  borderRadius: BorderRadius.circular(_floatingButtonRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: AnimatedScale(
                  scale: _isExpanded ? 1.1 : (isSelected ? 1.05 : 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    _isExpanded ? FontAwesomeIcons.xmark : floatingItem.icon,
                    color: (_isExpanded || isSelected)
                        ? Colors.black87
                        : unselectedColor,
                    size: _iconSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingNavItem(
    int index,
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final item = _navItems[index];
    final isSelected = widget.selectedIndex == index;

    return Transform.translate(
      offset: Offset.zero,
      child: Transform.scale(
        scale: 1,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            elevation: 6,
            shadowColor: Colors.black.withAlpha(51),
            borderRadius: BorderRadius.circular(_itemSize / 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(_itemSize / 2),
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: _itemSize,
                width: _itemSize,
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : backgroundColor,
                  borderRadius: BorderRadius.circular(_itemSize / 2),
                  border: Border.all(
                    color: isSelected
                        ? selectedColor
                        : unselectedColor.withAlpha(77),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(38),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        item.icon,
                        color: isSelected ? Colors.black87 : unselectedColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Colors.black87 : unselectedColor,
                        fontSize: 8,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
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

extension on CustomBottomNav {
  static CustomBottomNav floating({
    required int selectedIndex,
    required Function(int) onItemTapped,
    Color backgroundColor = const Color(0xff333333),
    Color selectedColor = const Color(0xffFDB623),
    Color unselectedColor = Colors.white70,
  }) => CustomBottomNav(
    selectedIndex: selectedIndex,
    onItemTapped: onItemTapped,
    hasFloatingButton: true,
    backgroundColor: backgroundColor,
    selectedColor: selectedColor,
    unselectedColor: unselectedColor,
  );

  static CustomBottomNav standard({
    required int selectedIndex,
    required Function(int) onItemTapped,
    Color? backgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
  }) => CustomBottomNav(
    selectedIndex: selectedIndex,
    onItemTapped: onItemTapped,
    hasFloatingButton: false,
    backgroundColor: backgroundColor,
    selectedColor: selectedColor,
    unselectedColor: unselectedColor,
  );

  static CustomBottomNav minimal({
    required int selectedIndex,
    required Function(int) onItemTapped,
  }) => CustomBottomNav(
    selectedIndex: selectedIndex,
    onItemTapped: onItemTapped,
    hasFloatingButton: false,
    backgroundColor: Colors.transparent,
  );
}
