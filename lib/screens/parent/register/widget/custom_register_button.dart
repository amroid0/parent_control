import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../parent_register_cubit.dart';

import '../../widgets/loading.dart';

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
            ? const LoadingWidget()
            : const Text(
                'Register',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
