import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/app.dart';
import 'child_profile_cubit.dart';

class ChildTokenScreen extends StatelessWidget {
  final String token;

  final String name;

  ChildTokenScreen({required this.token,required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: BlocProvider(
        create: (context) => ChildTokenCubit(token)..fetchApps(),
        child: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  // General section to show the token
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],

                    ),
                    child: Column(
                      children: [
                        Text(
                          'Child Token:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          token,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<ChildTokenCubit, ChildTokenState>(
                      builder: (context, state) {
                        if (state is ChildTokenLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is ChildTokenLoaded) {
                          return ListView.builder(
                            itemCount: state.apps.length,
                            itemBuilder: (context, index) {
                              App app = state.apps[index];
                              return ListTile(
                                title: Text(app.appName),
                                subtitle: Text('Usage: ${app.usage} minutes / Limit: ${app.usageLimit} minutes'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.lock),
                                      onPressed: () {
                                        _showLockDialog(context, app);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditDialog(context, app);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (state is ChildTokenError) {
                          return Center(child: Text(state.error));
                        } else {
                          return Center(child: Text('Something went wrong'));
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLockDialog(BuildContext screenContext, App app) {
    showDialog(
      context: screenContext,
      builder: (context) {
        return AlertDialog(
          title: Text('Lock App'),
          content: Text('Do you want to lock this app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                screenContext.read<ChildTokenCubit>().updateAppLock(app.packageName, true);
                Navigator.of(context).pop();
              },
              child: Text('Lock'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext screenContext, App app) {
    TextEditingController _timeLimitController = TextEditingController(text: app.usageLimit.toString());

    showDialog(
      context: screenContext,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Time Limit'),
          content: TextField(
            controller: _timeLimitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Time Limit (minutes)'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int? newTimeLimit = int.tryParse(_timeLimitController.text);
                if (newTimeLimit != null) {
                  screenContext.read<ChildTokenCubit>().updateAppUsageLimit(app.packageName, newTimeLimit);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}