import 'package:flutter/material.dart';
import 'package:parent_control/screens/parent/home_parent/widgets/child_list_title.dart';
import '../../../core/utils/app_images.dart';
import '../../../models/child.dart';

class ChildrenList extends StatelessWidget {
  final List<Child> children;

  const ChildrenList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              Child child = children[index];
              return ChildTile(child: child);
            },
          ),
        ),
      ],
    );
  }
}
