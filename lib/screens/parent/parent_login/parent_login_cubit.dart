import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ParentLoginState {}

class ParentLoginInitial extends ParentLoginState {}

class ParentLoginLoading extends ParentLoginState {}

class ParentLoginSuccess extends ParentLoginState {}

class ParentLoginFailure extends ParentLoginState {
  final String error;

  ParentLoginFailure(this.error);
}

class ParentLoginCubit extends Cubit<ParentLoginState> {
  ParentLoginCubit() : super(ParentLoginInitial());

  Future<void> loginParent(String email, String password) async {
    emit(ParentLoginLoading());
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user!.emailVerified) {
        emit(ParentLoginSuccess());
      } else {
        emit(ParentLoginFailure('Please verify your email before logging in.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(ParentLoginFailure(e.message ?? 'Login failed'));
    }
  }
}