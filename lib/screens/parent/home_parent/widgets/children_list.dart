import 'package:flutter/material.dart';
import '../../../../core/utils/app_images.dart';

import '../../../../models/child.dart';
import '../../child_profile/child_profile_screen.dart';

class ChildrenList extends StatelessWidget {
  final List<Child> children;

  const ChildrenList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Children:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              Child child = children[index];
              return ListTile(
                leading: Image.asset(Assets.imagesChild, width: 50, height: 50),
                title: Text(child.name),
                subtitle: Text(child.email),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ChildTokenScreen.routeName,
                    arguments: {
                      'token': child.token,
                      'name': child.name,
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
