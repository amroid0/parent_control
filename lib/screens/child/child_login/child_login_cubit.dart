import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        emit(ChildLoginSuccess(childId));
      } else {
        emit(ChildLoginFailure('Invalid email or token'));
      }
    } catch (e) {
      emit(ChildLoginFailure(e.toString()));
    }
  }
}