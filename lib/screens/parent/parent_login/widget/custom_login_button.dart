import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../parent_login_cubit.dart';
import '../../widgets/loading.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ParentLoginState state;

  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<ParentLoginCubit>().loginParent(
                emailController.text,
                passwordController.text,
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: state is ParentLoginLoading
            ? const LoadingWidget()
            : const Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
