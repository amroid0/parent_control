import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../child/child_login/login_child_screen.dart';
import '../parent/parent_login/login_parent_screen.dart';
import 'Type_button.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  static const String routeName = '/userTypeSelection';

  const UserTypeSelectionScreen({super.key});

  @override
  _UserTypeSelectionScreenState createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String _selectedUserType = '';

  void _selectUserType(String userType) {
    setState(() {
      _selectedUserType = userType;
    });
  }

  void _navigateToNextScreen() {
    if (_selectedUserType == 'Parent') {
      Navigator.pushReplacementNamed(context, LoginParentScreen.routeName);
    } else if (_selectedUserType == 'Child') {
      Navigator.pushReplacementNamed(context, LoginChildScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserTypeButton(
              label: 'Parent',
              icon: Icons.person,
              isSelected: _selectedUserType == 'Parent',
              onPressed: () => _selectUserType('Parent'),
            ),
            SizedBox(height: 20.h),
            UserTypeButton(
              label: 'Child',
              icon: Icons.child_care,
              isSelected: _selectedUserType == 'Child',
              onPressed: () => _selectUserType('Child'),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed:
                      _selectedUserType.isEmpty ? null : _navigateToNextScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    'Let\'s Go',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
