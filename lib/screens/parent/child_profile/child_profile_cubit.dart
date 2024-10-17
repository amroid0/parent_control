import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app.dart';

abstract class ChildTokenState {}

class ChildTokenInitial extends ChildTokenState {}

class ChildTokenLoading extends ChildTokenState {}

class ChildTokenLoaded extends ChildTokenState {
  final List<App> apps;

  ChildTokenLoaded(this.apps);
}

class ChildTokenError extends ChildTokenState {
  final String error;

  ChildTokenError(this.error);
}

class ChildTokenCubit extends Cubit<ChildTokenState> {
  final String token;
  late StreamSubscription<DocumentSnapshot> _firestoreSubscription;

  ChildTokenCubit(this.token) : super(ChildTokenInitial()) {
    _setupFirestoreListener();
  }

  Future<void> fetchApps() async {
    emit(ChildTokenLoading());
    try {
      QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('token', isEqualTo: token)
          .get();

      if (childrenSnapshot.docs.isNotEmpty) {
        String childId = childrenSnapshot.docs.first.id;

        DocumentSnapshot settingsSnapshot = await FirebaseFirestore.instance
            .collection('children')
            .doc(childId)
            .collection('settings')
            .doc('apps')
            .get();

        if (settingsSnapshot.exists) {
          _processAppData(settingsSnapshot.data() as Map<String, dynamic>);
        } else {
          emit(ChildTokenError('No apps found'));
        }
      } else {
        emit(ChildTokenError('Child not found'));
      }
    } catch (e) {
      emit(ChildTokenError(e.toString()));
    }
  }

  Future<void> updateAppLock(String packageName, bool isLocked) async {
    try {
      QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('token', isEqualTo: token)
          .get();

      if (childrenSnapshot.docs.isNotEmpty) {
        String childId = childrenSnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('children')
            .doc(childId)
            .collection('settings')
            .doc('apps')
            .update({
          FieldPath([packageName, 'locked']): isLocked,
        });
      } else {
        emit(ChildTokenError('Child not found'));
      }
    } catch (e) {
      emit(ChildTokenError(e.toString()));
    }
  }

  Future<void> updateAppUsageLimit(String packageName, int usageLimit) async {
    try {
      QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('token', isEqualTo: token)
          .get();

      if (childrenSnapshot.docs.isNotEmpty) {
        String childId = childrenSnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('children')
            .doc(childId)
            .collection('settings')
            .doc('apps')
            .update({
          FieldPath([packageName, 'usageLimit']): usageLimit,
          FieldPath([packageName, 'currentTimeInMilli']): DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        emit(ChildTokenError('Child not found'));
      }
    } catch (e) {
      emit(ChildTokenError(e.toString()));
    }
  }

  void _setupFirestoreListener() {
    FirebaseFirestore.instance
        .collection('children')
        .where('token', isEqualTo: token)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        String childId = snapshot.docs.first.id;

        _firestoreSubscription = FirebaseFirestore.instance
            .collection('children')
            .doc(childId)
            .collection('settings')
            .doc('apps')
            .snapshots()
            .listen((settingsSnapshot) {
          if (settingsSnapshot.exists) {
            _processAppData(settingsSnapshot.data() as Map<String, dynamic>);
          } else {
            emit(ChildTokenError('No apps found'));
          }
        }, onError: (error) {
          emit(ChildTokenError(error.toString()));
        });
      } else {
        emit(ChildTokenError('Child not found'));
      }
    }, onError: (error) {
      emit(ChildTokenError(error.toString()));
    });
  }

  void _processAppData(Map<String, dynamic> appData) {
    List<App> apps = appData.entries.map((entry) {
      return App(
        packageName: entry.key ?? "",
        appName: entry.value['appName'] ?? "",
        isLocked: entry.value['locked'] ?? false,
        usage: entry.value['usage'] ?? 0,
        usageLimit: entry.value['usageLimit'] ?? 0,
        currentTimeInMilli: entry.value['currentTimeInMilli'] ?? 0,
        iconUrl: entry.value['iconUrl'] ?? "",
      );
    }).toList();

    // Sort apps by usage (descending) and then by locked status (locked first)
    apps.sort((a, b) {
      if (a.isLocked && !b.isLocked) {
        return -1;
      } else if (!a.isLocked && b.isLocked) {
        return 1;
      } else {
        return b.usage.compareTo(a.usage);
      }
    });

    emit(ChildTokenLoaded(apps));
  }

  @override
  Future<void> close() {
    _firestoreSubscription.cancel();
    return super.close();
  }
}