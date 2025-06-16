import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:taskflow/core/routes/app_router.gr.dart';

import 'package:taskflow/widgets/custom_bottom_nav.dart';

@RoutePage()
class MainWrapperScreen extends StatelessWidget {
  const MainWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        TaskRoute(),
        TimelineRoute(),
        HabitRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          extendBody: true,
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: tabsRouter.activeIndex,
            onItemTapped: (index) {
              tabsRouter.setActiveIndex(index);
            },
          ),
        );
      },
    );
  }
}
