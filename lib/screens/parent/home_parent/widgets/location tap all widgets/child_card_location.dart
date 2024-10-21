import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parent_control/screens/parent/home_parent/widgets/child_list_title.dart';

import '../../../../../core/utils/app_images.dart';

class ChildCard extends StatelessWidget {
  final String childId;
  final String childName;
  final GeoPoint location;
  final Completer<GoogleMapController> mapController;
  final bool isSelected;

  const ChildCard({
    super.key,
    required this.childId,
    required this.childName,
    required this.location,
    required this.mapController,
    this.isSelected = false,
  });

  Future<void> _onTap() async {
    final controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        17.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Card(
        color: isSelected ? Colors.white : Colors.orange[100],
        elevation: isSelected ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Container(
          padding: EdgeInsets.all(8.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.imagesChild,
                width: 30.w,
                height: 30.h,
              ),
              Text(
                childName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
              ElevatedButton.icon(
                  onPressed: () {},
                  label: Text('Safe Zone'),
                  icon: Icon(Icons.location_on))
            ],
          ),
        ),
      ),
    );
  }
}
