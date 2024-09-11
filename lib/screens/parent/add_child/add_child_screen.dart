import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_child_cubit.dart';

class AddChildScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Child'),
      ),
      body: BlocProvider(
        create: (context) => AddChildCubit(),
        child: BlocConsumer<AddChildCubit, AddChildState>(
          listener: (context, state) {
            if (state is AddChildSuccess) {
              showRoundedDialog(context, state.token);
            } else if (state is AddChildFailure) {
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
                    decoration: InputDecoration(labelText: 'Child Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Child Email'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AddChildCubit>().addChild(
                        _nameController.text,
                        _emailController.text,
                      );
                    },
                    child: state is AddChildLoading
                        ? CircularProgressIndicator()
                        : Text('Add Child'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showRoundedDialog(BuildContext context, String token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('Child Added'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Child added with token:'),
              SizedBox(height: 10),
              Text(
                token,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}