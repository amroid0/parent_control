import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'parent_register_cubit.dart';

class RegisterParentScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as Parent'),
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
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
                      context.read<ParentRegistrationCubit>().registerParent(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
                    child: state is ParentRegistrationLoading
                        ? CircularProgressIndicator()
                        : Text('Register'),
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