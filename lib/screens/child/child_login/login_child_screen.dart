import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_images.dart';
import '../home_child/home_child_screen.dart';
import 'child_login_cubit.dart';

class LoginChildScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  static const String routeName = '/loginChild';

  LoginChildScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login as Child'),
      ),
      body: BlocProvider(
        create: (context) => ChildLoginCubit(),
        child: BlocConsumer<ChildLoginCubit, ChildLoginState>(
          listener: (context, state) {
            if (state is ChildLoginSuccess) {
              Navigator.pushReplacementNamed(context, ChildHomeScreen.routeName,
                  arguments: state.childId);
            } else if (state is ChildLoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Image.asset(
                            Assets.imagesLogo,
                            height: 150,
                          ),
                          const SizedBox(height: 40),
                          _buildTextField(_emailController, 'Email'),
                          const SizedBox(height: 20),
                          _buildTextField(_tokenController, 'Token'),
                          const SizedBox(height: 40),
                          _buildLoginButton(context, state),
                        ],
                      ),
                      const Column(
                        children: [],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          obscureText: obscureText,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, ChildLoginState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<ChildLoginCubit>().loginChild(
                _emailController.text,
                _tokenController.text,
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: state is ChildLoginLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : const Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
