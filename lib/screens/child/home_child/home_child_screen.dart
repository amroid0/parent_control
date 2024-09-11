import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/app.dart';
import 'home_child_cubit.dart';

class ChildHomeScreen extends StatelessWidget {
  final String childId;

  ChildHomeScreen({required this.childId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChildHomeCubit(childId)..getAppUsageData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Child Home'),
        ),
        body: BlocBuilder<ChildHomeCubit, ChildHomeState>(
          builder: (context, state) {
            if (state is ChildHomeLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ChildHomeLoaded) {
              return ListView.builder(
                itemCount: state.apps.length,
                itemBuilder: (context, index) {
                  App app = state.apps[index];
                  return ListTile(
                    title: Text(app.appName),
                    subtitle: Text('Usage: ${app.usage} minutes / Limit: ${app.usageLimit} minutes'),
                    trailing: app.isLocked
                        ? Icon(Icons.lock)
                        : Icon(Icons.lock_open),
                  );
                },
              );
            } else if (state is ChildHomeError) {
              return Center(child: Text(state.error));
            } else {
              return Center(child: Text('Something went wrong'));
            }
          },
        ),

      ),
    );
  }
}