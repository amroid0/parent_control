import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/child.dart';

abstract class ParentHomeState {}

class ParentHomeInitial extends ParentHomeState {}

class ParentHomeLoading extends ParentHomeState {}

class ParentHomeLoaded extends ParentHomeState {
  final List<Child> children;

  ParentHomeLoaded(this.children);
}

class ParentHomeError extends ParentHomeState {
  final String error;

  ParentHomeError(this.error);
}

class ParentHomeCubit extends Cubit<ParentHomeState> {
  ParentHomeCubit() : super(ParentHomeInitial());

  StreamSubscription<DocumentSnapshot>? _parentSubscription;

  void fetchChildren(String parentId) {
    emit(ParentHomeLoading());
    try {
      _parentSubscription?.cancel();
      _parentSubscription = FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .snapshots()
          .listen((parentSnapshot) {
        if (parentSnapshot.exists) {
          List<String> childIds = List<String>.from(parentSnapshot['childIds']);

          if (childIds.isEmpty) {
            emit(ParentHomeLoaded([]));
            return;
          }

          List<Child> children = [];

          void onChildFetched(DocumentSnapshot childSnapshot) {
            if (childSnapshot.exists) {
              children.add(Child(
                id: childSnapshot.id,
                name: childSnapshot['name'],
                email: childSnapshot['email'],
                token: childSnapshot['token'],
              ));
            }

            if (children.length == childIds.length) {
              emit(ParentHomeLoaded(children));
            }
          }

          for (String childId in childIds) {
            FirebaseFirestore.instance
                .collection('children')
                .doc(childId)
                .get()
                .then(onChildFetched)
                .catchError((error) {
              emit(ParentHomeError(error.toString()));
            });
          }
        }
      }, onError: (error) {
        emit(ParentHomeError(error.toString()));
      });
    } catch (e) {
      emit(ParentHomeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _parentSubscription?.cancel();
    return super.close();
  }
}
