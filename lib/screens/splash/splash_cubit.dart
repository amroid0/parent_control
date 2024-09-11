import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoggedIn extends SplashState {}

class SplashNotLoggedIn extends SplashState {}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkLoginStatus() async {
    emit(SplashLoading());
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emit(SplashLoggedIn());
    } else {
      emit(SplashNotLoggedIn());
    }
  }
}