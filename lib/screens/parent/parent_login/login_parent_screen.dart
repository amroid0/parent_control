import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              Navigator.pushNamed(context, '/parentHome');
            } else if (state is ParentLoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ParentLoginCubit>().loginParent(
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
                    child: state is ParentLoginLoading
                        ? CircularProgressIndicator()
                        : Text('Login'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registerParent');
                    },
                    child: Text('Register as Parent'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}