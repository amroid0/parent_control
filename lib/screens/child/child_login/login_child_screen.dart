import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'child_login_cubit.dart';

class LoginChildScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login as Child'),
      ),
      body: BlocProvider(
        create: (context) => ChildLoginCubit(),
        child: BlocConsumer<ChildLoginCubit, ChildLoginState>(
          listener: (context, state) {
            if (state is ChildLoginSuccess) {
              Navigator.pushNamed(context, '/childMain',arguments: state.childId);
            } else if (state is ChildLoginFailure) {
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
                    controller: _tokenController,
                    decoration: InputDecoration(labelText: 'Token'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChildLoginCubit>().loginChild(
                        _emailController.text,
                        _tokenController.text,
                      );
                    },
                    child: state is ChildLoginLoading
                        ? CircularProgressIndicator()
                        : Text('Login'),
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