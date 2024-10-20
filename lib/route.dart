import 'package:flutter/material.dart';
import 'screens/child/geofencing-feature-child/view/check_geo_child.dart';
import 'screens/child/home_child/home_child_screen.dart';
import 'screens/parent/add_child/add_child_screen.dart';
import 'screens/parent/child_profile/child_profile_screen.dart';
import 'screens/parent/home_parent/home_parent_screen.dart';
import 'screens/parent/parent_login/login_parent_screen.dart';
import 'screens/parent/register/register_parent_screen.dart';
import 'screens/parent/widgets/error_route.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/child/child_login/login_child_screen.dart';
import 'screens/user type/user_type_selection_screen.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => SplashScreen(),
      );
    case ParentHomeScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const ParentHomeScreen(),
      );
    case ChildHomeScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => ChildHomeScreen(
          childId: settings.arguments as String,
        ),
      );
    case CheckGeoChild.routeName:
      return MaterialPageRoute(
        builder: (context) => const CheckGeoChild(),
      );
    case AddChildScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => AddChildScreen(),
      );
    case RegisterParentScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => RegisterParentScreen(),
      );
    case LoginParentScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => LoginParentScreen(),
      );
    case LoginChildScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => LoginChildScreen(),
      );
    case UserTypeSelectionScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => UserTypeSelectionScreen(),
      );
    case ChildTokenScreen.routeName:
      final args = settings.arguments as Map<String, String>;
      return MaterialPageRoute(
        builder: (context) => ChildTokenScreen(
          token: args['token']!,
          name: args['name']!,
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => const ErrorScreen(),
      );
  }
}
