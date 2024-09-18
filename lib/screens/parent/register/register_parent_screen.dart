import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'parent_register_cubit.dart';

class RegisterParentScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Parent Account'),
      ),
      body: BlocProvider(
        create: (context) => ParentRegistrationCubit(),
        child: BlocConsumer<ParentRegistrationCubit, ParentRegistrationState>(
          listener: (context, state) {
            if (state is ParentRegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Verification email sent. Please check your email.')),
              );
            } else if (state is ParentRegistrationFailure) {
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
                        _buildTextField(_nameController, 'Name'),
                        SizedBox(height: 20),
                        _buildTextField(_emailController, 'Email'),
                        SizedBox(height: 20),
                        _buildTextField(_passwordController, 'Password', obscureText: true),
                      ],
                    ),
                    SizedBox(height: 40),
                    _buildRegisterButton(context, state),
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

  Widget _buildRegisterButton(BuildContext context, ParentRegistrationState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<ParentRegistrationCubit>().registerParent(
            _nameController.text,
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
        child: state is ParentRegistrationLoading
            ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : Text(
          'Register',
          style: TextStyle(fontSize: 18,color: Colors.white),
        ),
      ),
    );
  }
}