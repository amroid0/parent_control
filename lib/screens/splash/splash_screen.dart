import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:parent_control/core/utils/app_images.dart';
import '../child/home_child/home_child_screen.dart';
import '../parent/home_parent/home_parent_screen.dart';
import '../user type/user_type_selection_screen.dart';
import 'splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..checkLoginStatus(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashParentLoggedIn) {
            Navigator.pushReplacementNamed(context, ParentHomeScreen.routeName);
          } else if (state is SplashChildLoggedIn) {
            Navigator.pushReplacementNamed(context, ChildHomeScreen.routeName);
          } else if (state is SplashNotLoggedIn) {
            Navigator.pushReplacementNamed(
                context, UserTypeSelectionScreen.routeName);
          }
        },
        child: Scaffold(
          body: Center(
            child: Image.asset(
              Assets.imagesLogo,
              height: 250.h,
            ),
          ),
        ),
      ),
    );
  }
}
