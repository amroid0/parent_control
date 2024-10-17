import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/app.dart';
import 'child_profile_cubit.dart';

class ChildTokenScreen extends StatelessWidget {
  final String token;
  final String name;

  ChildTokenScreen({required this.token, required this.name});

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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          token,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Title above the app list
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'App List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<ChildTokenCubit, ChildTokenState>(
                      builder: (context, state) {
                        if (state is ChildTokenLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is ChildTokenLoaded) {
                          return ListView.separated(
                            itemCount: state.apps.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[200],
                              thickness: 1,
                            ),
                            itemBuilder: (context, index) {
                              App app = state.apps[index];
                              return ListTile(
                                title: Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: app.iconUrl ?? "",
                                      height: 30,
                                      width: 30,
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.android,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        app.appName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildUsageLimitText(
                                        'Usage', '${app.usage} minutes'),
                                    _buildUsageLimitText(
                                        'Limit', '${app.usageLimit} minutes'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        app.isLocked
                                            ? Icons.lock
                                            : Icons.lock_open,
                                        color: app.isLocked
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      onPressed: () {
                                        _showLockDialog(context, app);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.timelapse_rounded,
                                        color: Colors.blue,
                                      ),
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

  Widget _buildUsageLimitText(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void _showLockDialog(BuildContext screenContext, App app) {
    showDialog(
      context: screenContext,
      builder: (context) {
        return AlertDialog(
          title: Text(app.isLocked ? 'Unlock App' : 'Lock App'),
          content: Text(app.isLocked
              ? 'Do you want to unlock this app?'
              : 'Do you want to lock this app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                screenContext
                    .read<ChildTokenCubit>()
                    .updateAppLock(app.packageName, !app.isLocked);
                Navigator.of(context).pop();
              },
              child: Text(app.isLocked ? 'Unlock' : 'Lock'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext screenContext, App app) {
    TextEditingController _timeLimitController =
        TextEditingController(text: app.usageLimit.toString());

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
                  screenContext
                      .read<ChildTokenCubit>()
                      .updateAppUsageLimit(app.packageName, newTimeLimit);
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
