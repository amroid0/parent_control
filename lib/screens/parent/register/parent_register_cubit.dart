import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ParentRegistrationState {}

class ParentRegistrationInitial extends ParentRegistrationState {}

class ParentRegistrationLoading extends ParentRegistrationState {}

class ParentRegistrationSuccess extends ParentRegistrationState {}

class ParentRegistrationFailure extends ParentRegistrationState {
  final String error;

  ParentRegistrationFailure(this.error);
}

class ParentRegistrationCubit extends Cubit<ParentRegistrationState> {
  ParentRegistrationCubit() : super(ParentRegistrationInitial());

  Future<void> registerParent(String name, String email, String password) async {
    emit(ParentRegistrationLoading());
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String parentId = userCredential.user!.uid;

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Store parent information in Firestore
      await FirebaseFirestore.instance.collection('parents').doc(parentId).set({
        'name': name,
        'email': email,
        'childIds': [],
      });

      emit(ParentRegistrationSuccess());
    } on FirebaseAuthException catch (e) {
      emit(ParentRegistrationFailure(e.message ?? 'Registration failed'));
    }
  }
}