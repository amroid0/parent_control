import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/app.dart';
import 'home_child_cubit.dart';
import 'location_cubit.dart';

class ChildHomeScreen extends StatelessWidget {
  final String childId;
  const ChildHomeScreen({super.key, required this.childId});
  static const routeName = '/childHome';
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ChildHomeCubit(childId)
            ..startForegroundService()
            ..fetchApps(),
        ),
        BlocProvider(
          create: (context) => LocationCubit(childId)..startForegroundService(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Child Home'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location_outlined),
              onPressed: () {
                ChildHomeCubit(childId).startForegroundService();
              },
            ),
          ],
        ),
        body: BlocBuilder<ChildHomeCubit, ChildHomeState>(
          builder: (context, state) {
            if (state is ChildHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChildHomeLoaded) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  // Title above the app list
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'App List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
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
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.android,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  app.appName,
                                  style: const TextStyle(
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
                          trailing: Icon(
                            app.isLocked ? Icons.lock : Icons.lock_open,
                            color: app.isLocked ? Colors.red : Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is ChildHomeError) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text('Something went wrong'));
            }
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
}
