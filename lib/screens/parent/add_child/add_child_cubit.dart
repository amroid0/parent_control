import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

abstract class AddChildState {}

class AddChildInitial extends AddChildState {}

class AddChildLoading extends AddChildState {}

class AddChildSuccess extends AddChildState {
  final String token;

  AddChildSuccess(this.token);
}

class AddChildFailure extends AddChildState {
  final String error;

  AddChildFailure(this.error);
}

class AddChildCubit extends Cubit<AddChildState> {
  AddChildCubit() : super(AddChildInitial());

  Future<void> addChild(String name, String email) async {
    emit(AddChildLoading());
    try {
      String token = await generateUniqueFiveDigitToken();
      String parentId = FirebaseAuth.instance.currentUser!.uid;

      DocumentReference childRef = await FirebaseFirestore.instance.collection('children').add({
        'name': name,
        'email': email,
        'token': token,
      });

      // Link child to parent
      await FirebaseFirestore.instance.collection('parents').doc(parentId).update({
        'childIds': FieldValue.arrayUnion([childRef.id]),
      });

      emit(AddChildSuccess(token));
    } catch (e) {
      emit(AddChildFailure(e.toString()));
    }
  }

  Future<String> generateUniqueFiveDigitToken() async {
    Random random = Random();
    String token;
    bool isUnique = false;

    do {
      int tokenNumber = 10000 + random.nextInt(90000); // Generates a number between 10000 and 99999
      token = tokenNumber.toString();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('token', isEqualTo: token)
          .get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true;
      }
    } while (!isUnique);

    return token;
  }
}