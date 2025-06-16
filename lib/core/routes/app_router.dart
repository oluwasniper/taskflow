import 'package:auto_route/auto_route.dart';
import 'package:taskflow/core/routes/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    // Main wrapper route that contains the bottom navigation
    AutoRoute(
      page: MainWrapperRoute.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(page: HomeRoute.page, path: 'home'),
        AutoRoute(page: TaskRoute.page, path: 'tasks'),
        AutoRoute(page: TimelineRoute.page, path: 'timeline'),
        AutoRoute(page: HabitRoute.page, path: 'projects'),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
      ],
    ),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    // optionally add root guards here
  ];
}
