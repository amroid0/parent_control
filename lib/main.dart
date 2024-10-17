import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:parent_control/screens/child/home_child/home_child_screen.dart';
import 'package:parent_control/screens/splash/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'default_firebase_options.dart';
import 'screens/child/child_login/login_child_screen.dart';
import 'screens/parent/add_child/add_child_screen.dart';
import 'screens/parent/home_parent/home_parent_screen.dart';
import 'screens/parent/parent_login/login_parent_screen.dart';
import 'screens/parent/register/register_parent_screen.dart';
import 'screens/user_type_selection_screen.dart';

void main() async {
  FlutterForegroundTask.initCommunicationPort();
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Safe',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => UserTypeSelectionScreen(),
        '/registerParent': (context) => RegisterParentScreen(),
        '/loginParent': (context) => LoginParentScreen(),
        '/loginChild': (context) => LoginChildScreen(),
        '/addChild': (context) => AddChildScreen(),
        '/parentHome': (context) => ParentHomeScreen(),
        '/childMain': (context) => ChildHomeScreen(childId: ModalRoute.of(context)!.settings.arguments as String),
        // Add other routes here
      },
    );
  }
}