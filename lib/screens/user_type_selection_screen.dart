import 'package:flutter/material.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  @override
  _UserTypeSelectionScreenState createState() => _UserTypeSelectionScreenState();
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
      Navigator.pushReplacementNamed(context, '/loginParent');
    } else if (_selectedUserType == 'Child') {
      Navigator.pushReplacementNamed(context, '/loginChild');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [


            _buildUserTypeButton(
              'Parent',
              Icons.person,
              _selectedUserType == 'Parent',
                  () => _selectUserType('Parent'),
            ),
            SizedBox(height: 20),
            _buildUserTypeButton(
              'Child',
              Icons.child_care,
              _selectedUserType == 'Child',
                  () => _selectUserType('Child'),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _selectedUserType.isEmpty ? null : _navigateToNextScreen,
                  child: Text('Let\'s Go',style: TextStyle(fontSize: 16,color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeButton(String label, IconData icon, bool isSelected, VoidCallback onPressed) {
    return Container(
      width: 250,
      height: 100,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: isSelected ? Colors.white : Colors.orange),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.orange,
            fontSize: 18,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isSelected ? Colors.orange : Colors.grey[300]!, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isSelected ? Colors.orange : Colors.transparent,
        ),
      ),
    );
  }
}