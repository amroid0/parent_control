import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widget/custom_register_button.dart';
import '../widgets/custom_text_filed.dart';
import 'parent_register_cubit.dart';
import 'package:quickalert/quickalert.dart';

class RegisterParentScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Parent Account'),
      ),
      body: BlocProvider(
        create: (context) => ParentRegistrationCubit(),
        child: BlocConsumer<ParentRegistrationCubit, ParentRegistrationState>(
          listener: (context, state) {
            if (state is ParentRegistrationSuccess) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                text: 'Verification email sent. Please check your email!',
              );
            } else if (state is ParentRegistrationFailure) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                text: state.error,
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
                            'assets/logo.png', 
                            height: 150,
                          ),
                          const SizedBox(height: 40),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Name',
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      RegisterButton(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        state: state,
                        context: context,
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
}
