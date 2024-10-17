import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parent_control/screens/parent/register/parent_register_cubit.dart';

class RegisterButton extends StatelessWidget {
  final BuildContext context;
  final ParentRegistrationState state;
  final String name;
  final String email;
  final String password;

  const RegisterButton({
    super.key,
    required this.context,
    required this.state,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<ParentRegistrationCubit>().registerParent(
                name,
                email,
                password,
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: state is ParentRegistrationLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : const Text(
                'Register',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
