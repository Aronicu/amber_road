import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/pages/library.dart';
import 'package:amber_road/pages/profile.dart';
import 'package:amber_road/pages/store.dart';
import 'package:amber_road/pages/updates.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  AppNavigation._();

  static String initialRoute = '/store';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorStore = GlobalKey<NavigatorState>();
  static final _rootNavigatorLibrary = GlobalKey<NavigatorState>();
  static final _rootNavigatorUpdates = GlobalKey<NavigatorState>();
  static final _rootNavigatorProfile = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: initialRoute,

    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      // Main Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell,);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _rootNavigatorStore,
            routes: [
              GoRoute(
                path: '/store',
                name: 'store',
                builder: (context, state) {
                  return StorePage(
                    key: state.pageKey
                  );
                }
              ),
            ]
          ),

          StatefulShellBranch(
            navigatorKey: _rootNavigatorLibrary,
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                builder: (context, state) {
                  return LibraryPage(
                    key: state.pageKey
                  );
                }
              ),
            ]
          ),

          StatefulShellBranch(
            navigatorKey: _rootNavigatorUpdates,
            routes: [
              GoRoute(
                path: '/updates',
                name: 'updates',
                builder: (context, state) {
                  return UpdatePage(
                    key: state.pageKey
                  );
                }
              ),
            ]
          ),

          StatefulShellBranch(
            navigatorKey: _rootNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) {
                  return ProfilePage(
                    key: state.pageKey
                  );
                }
              ),
            ]
          ),
        ]
      )
    ]
  );
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<StatefulWidget> createState() => _MainWrapperState();

}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  void _selectNavigation(int index) {
    widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _buildNavigations(),
    );
  }

  BottomNavigationBar _buildNavigations() {
    return BottomNavigationBar(
        elevation: 10,
        selectedItemColor: colSpecial,
        unselectedItemColor: colPrimary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Store"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Library"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: "Updates"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile"
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _selectNavigation(index);
        },
      );
  }
}
