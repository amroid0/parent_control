import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ChildLoginState {}

class ChildLoginInitial extends ChildLoginState {}

class ChildLoginLoading extends ChildLoginState {}

class ChildLoginSuccess extends ChildLoginState {
  final String childId;

  ChildLoginSuccess(this.childId);
}

class ChildLoginFailure extends ChildLoginState {
  final String error;

  ChildLoginFailure(this.error);
}

class ChildLoginCubit extends Cubit<ChildLoginState> {
  ChildLoginCubit() : super(ChildLoginInitial());

  Future<void> loginChild(String email, String token) async {
    emit(ChildLoginLoading());
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('email', isEqualTo: email)
          .where('token', isEqualTo: token)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String childId = snapshot.docs.first.id;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('childId', childId);
        emit(ChildLoginSuccess(childId));
      } else {
        emit(ChildLoginFailure('Invalid email or token'));
      }
    } catch (e) {
      emit(ChildLoginFailure(e.toString()));
    }
  }

  Future<void> checkLoggedInChild() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? childId = prefs.getString('childId');
    if (childId != null) {
      emit(ChildLoginSuccess(childId));
    } else {
      emit(ChildLoginInitial());
    }
  }
}