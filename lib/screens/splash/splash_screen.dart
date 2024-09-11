import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..checkLoginStatus(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashLoggedIn) {
            Navigator.of(context).pushReplacementNamed('/parentHome');
          } else if (state is SplashNotLoggedIn) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        },
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}