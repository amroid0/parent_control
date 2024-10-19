import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'children_list.dart';
import '../../widgets/loading.dart';
import '../home_parent_cubit.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addChild');
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocProvider(
        create: (context) => ParentHomeCubit()..fetchChildren(parentId),
        child: BlocBuilder<ParentHomeCubit, ParentHomeState>(
          builder: (context, state) {
            if (state is ParentHomeLoading) {
              return const Center(child: LoadingWidget());
            } else if (state is ParentHomeLoaded) {
              return ChildrenList(children: state.children);
            } else if (state is ParentHomeError) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }
}
