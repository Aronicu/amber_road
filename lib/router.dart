import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/pages/author_center/manage_chapter_page.dart';
import 'package:amber_road/pages/author_center/author_center.dart';
import 'package:amber_road/pages/book_details.dart';
import 'package:amber_road/pages/chapter_detail_page.dart';
import 'package:amber_road/pages/edit_profile.dart';
import 'package:amber_road/pages/library.dart';
import 'package:amber_road/pages/author_center/manage_work_page.dart';
import 'package:amber_road/pages/profile.dart';
import 'package:amber_road/pages/store.dart';
import 'package:amber_road/pages/updates.dart';
import 'package:amber_road/providers/google_signin_provider.dart';
import 'package:amber_road/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppNavigation {
  AppNavigation._();

  static String initialRoute = '/store';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: initialRoute,
    navigatorKey: _rootNavigatorKey,
    
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell,);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/store',
              name: 'store',
              builder: (context, state) {
                return StorePage(
                  key: state.pageKey
                );
              }
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              name: 'library',
              builder: (context, state) {
                return LibraryPage(
                  key: state.pageKey
                );
              }
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/updates',
              name: 'updates',
              builder: (context, state) {
                return UpdatePage(
                  key: state.pageKey
                );
              }
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) {
                return ProfilePage(
                  key: state.pageKey
                );
              }
            ),
          ]),
        ]
      ),
      
      GoRoute(path: "/book/:id", name: "bookDetails", builder: (context, state) {
        final bookId = state.pathParameters['id']!;

        // Get the referring route from extra data if available
        final fromRoute = state.extra != null && state.extra is String 
            ? state.extra as String 
            : '/store';

        return BookDetailsPage(bookId: bookId, fromRoute: fromRoute,);
      }),

      //book/${widget.bookId}/${chapter.id}
      GoRoute(path: "/book/:id/:cid", name: "viewChapter", builder: (context, state) {
        final bookId = state.pathParameters['id']!;
        final chapterId = state.pathParameters['cid']!;

        // Get additional parameters from extra
        final extra = state.extra is Map<String, dynamic> 
            ? state.extra as Map<String, dynamic>
            : {};
        
        final fromRoute = extra['fromRoute'] ?? '/store';
        final bookFormat = extra['bookFormat'] ?? BookFormat.webtoon;

        return ChapterDetailPage(bookId: bookId, chapterId: chapterId, bookFormat: bookFormat, fromRoute: fromRoute);
      }),

      GoRoute(path: "/editProfile", name: "editProfile", builder: (context, state) {
        final fromRoute = state.extra != null && state.extra is String 
          ? state.extra as String 
          : '/store';

        return EditProfilePage(fromRoute: fromRoute);
      },),
      GoRoute(path: "/authorCenter", name: "authorCenter", builder: (context, state) {
        final fromRoute = state.extra != null && state.extra is String 
          ? state.extra as String 
          : '/store';
        return AuthorCenterPage(fromRoute: fromRoute,);
      },),
      GoRoute(path: "/manageBook/:id", name: "manageBook", builder: (context, state) {
        final bookId = state.pathParameters['id']!;
        final fromRoute = state.extra != null && state.extra is String 
          ? state.extra as String 
          : '/store';
        return BookManagementPage(bookId: bookId, fromRoute: fromRoute,);
      },),
      GoRoute(path: "/addChapter/:id", name: "addChapter", builder: (context, state) {
        final bookId = state.pathParameters['id']!;
        final fromRoute = state.extra != null && state.extra is String 
          ? state.extra as String 
          : '/store';

        return ManageChapterPage(bookId: bookId, fromRoute: fromRoute,);
      },),
      GoRoute(path: "/editChapter/:bid/:cnum", name: "editChapter", builder: (context, state) {
        final bookId = state.pathParameters['bid']!;
        final chapterNum = int.parse(state.pathParameters['cnum']!);
        final fromRoute = state.extra != null && state.extra is String 
          ? state.extra as String 
          : '/store';

        return ManageChapterPage(bookId: bookId, chapterNum: chapterNum, fromRoute: fromRoute,);
      },)
  ]);
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
    return ChangeNotifierProvider(
      create: (context) => GoogleSigninProvider(),
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: _buildNavigations(),
      ),
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
