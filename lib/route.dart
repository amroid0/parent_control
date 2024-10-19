import 'package:flutter/material.dart';
import 'screens/child/geofencing-feature-child/view/check_geo_child.dart';
import 'screens/child/home_child/home_child_screen.dart';
import 'screens/parent/add_child/add_child_screen.dart';
import 'screens/parent/home_parent/home_parent_screen.dart';
import 'screens/parent/parent_login/login_parent_screen.dart';
import 'screens/parent/register/register_parent_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/child/child_login/login_child_screen.dart';
import 'screens/user_type_selection_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (context) => SplashScreen(),
  '/': (context) => UserTypeSelectionScreen(),
  '/registerParent': (context) => RegisterParentScreen(),
  '/loginParent': (context) => LoginParentScreen(),
  '/loginChild': (context) => LoginChildScreen(),
  '/addChild': (context) => AddChildScreen(),
  '/parentHome': (context) => const ParentHomeScreen(),
  '/childMain': (context) => ChildHomeScreen(
      childId: ModalRoute.of(context)!.settings.arguments as String),
  '/checkGeoChild': (context) => const CheckGeoChild(),
};
