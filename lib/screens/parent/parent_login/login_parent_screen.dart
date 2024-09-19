import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'parent_login_cubit.dart';

class LoginParentScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login as Parent'),
      ),
      body: BlocProvider(
        create: (context) => ParentLoginCubit(),
        child: BlocConsumer<ParentLoginCubit, ParentLoginState>(
          listener: (context, state) {
            if (state is ParentLoginSuccess) {
              Navigator.pushReplacementNamed(context, '/parentHome');
            } else if (state is ParentLoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Image.asset(
                          'assets/logo.png', // Replace with your logo path
                          height: 150,
                        ),
                        SizedBox(height: 40),
                        _buildTextField(_emailController, 'Email'),
                        SizedBox(height: 20),
                        _buildTextField(_passwordController, 'Password', obscureText: true),
                        SizedBox(height: 40),
                        _buildLoginButton(context, state),
                        SizedBox(height: 10),
                        _buildRegisterLink(context),
                      ],
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
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

  Widget _buildLoginButton(BuildContext context, ParentLoginState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<ParentLoginCubit>().loginParent(
            _emailController.text,
            _passwordController.text,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: state is ParentLoginLoading
            ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : Text(
          'Login',
          style: TextStyle(fontSize: 18,color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/registerParent');
      },
      child: Text(
        'Sign Up',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
        ),
      ),
    );
  }
}