import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: "Amber Road",
    routerConfig: AppNavigation.router,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colSpecial,
        brightness: Brightness.dark,
      )
    ),
  );
  
}

// class _MainAppState extends State<MainApp> {
//   int _currentIndex = 0;
  
  

//   BottomNavigationBar _buildNavigations() {
//     return BottomNavigationBar(
//         elevation: 10,
//         selectedItemColor: colSpecial,
//         unselectedItemColor: colPrimary,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.store),
//             label: "Store"
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.book),
//             label: "Library"
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.update),
//             label: "Updates"
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Profile"
//           ),
//         ],
//         currentIndex: _currentIndex,
//         onTap: (idx) {
//           setState(() {
//             _currentIndex = idx;
//           });
//         },
//       );
//   }

//   AppBar _buildAppBar() {
//     return AppBar(
//         title: Text("Amber Road", style: TextStyle(color: colPrimary),),
//         shape: Border(
//           bottom: BorderSide(
//             color: colSpecial,
//             width: 2,
//           )
//         ),
//       );
//   }
// }
