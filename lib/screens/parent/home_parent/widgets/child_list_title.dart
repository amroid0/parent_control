import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:parent_control/core/utils/app_fonts.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../models/child.dart';
import '../../child_profile/child_profile_screen.dart';

class ChildTile extends StatelessWidget {
  final Child child;

  const ChildTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 16.0), // Padding for better separation
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(25.0.r),
            child: Image.asset(Assets.imagesChild, width: 50.w, height: 50.h),
          ),
          title: Text(
            child.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(child.email),
          trailing: const Icon(Icons.arrow_forward_ios),
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
        ),
      ),
    );
  }
}
