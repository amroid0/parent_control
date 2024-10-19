import 'package:flutter/material.dart';

class RegisterLink extends StatelessWidget {
  const RegisterLink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/registerParent');
      },
      child: const Text(
        'Sign Up',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
        ),
      ),
    );
  }
}
