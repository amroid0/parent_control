import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashParentLoggedIn extends SplashState {}
class SplashChildLoggedIn extends SplashState {
final String childId;
SplashChildLoggedIn(this.childId);
}

class SplashNotLoggedIn extends SplashState {}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkLoginStatus() async {
    emit(SplashLoading());
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emit(SplashParentLoggedIn());
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? childId = prefs.getString('childId');
      if (childId != null) {
        emit(SplashChildLoggedIn(childId));
      } else {
        emit(SplashNotLoggedIn());
      }
    }
  }
}