import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home_parent/home_parent_screen.dart';
import '../../../core/utils/app_images.dart';
import 'parent_login_cubit.dart';
import 'widget/register_link.dart';
import '../widgets/custom_text_filed.dart';
import 'package:quickalert/quickalert.dart';

import 'widget/custom_login_button.dart';

class LoginParentScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const String routeName = '/loginParent';
  LoginParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login as Parent'),
      ),
      body: BlocProvider(
        create: (context) => ParentLoginCubit(),
        child: BlocConsumer<ParentLoginCubit, ParentLoginState>(
          listener: (context, state) {
            if (state is ParentLoginSuccess) {
              Navigator.pushReplacementNamed(
                  context, ParentHomeScreen.routeName);
            } else if (state is ParentLoginFailure) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Error',
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
                            Assets.imagesLogo,
                            height: 150,
                          ),
                          const SizedBox(height: 40),
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
                          const SizedBox(height: 40),
                          LoginButton(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            state: state,
                          ),
                          const SizedBox(height: 10),
                          const RegisterLink(),
                        ],
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
