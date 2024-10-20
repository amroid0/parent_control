import 'package:flutter/material.dart';

class UserTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const UserTypeButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          side: BorderSide(
              color: isSelected ? Colors.orange : Colors.grey[300]!, width: 2),
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
