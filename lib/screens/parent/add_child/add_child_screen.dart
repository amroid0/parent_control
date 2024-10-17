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
        title: const Text('Add Child'),
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
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.child_care,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        SizedBox(height: 40),
                        _buildTextField(_nameController, 'Child Name'),
                        const SizedBox(height: 20),
                        _buildTextField(_emailController, 'Child Email'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildAddChildButton(context, state),
                  ],
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

  Widget _buildAddChildButton(BuildContext context, AddChildState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<AddChildCubit>().addChild(
                _nameController.text,
                _emailController.text,
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: state is AddChildLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : Text(
                'Add Child',
                style: TextStyle(fontSize: 18, color: Colors.white),
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
          title: const Text('Child Added'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Child added with token:'),
              const SizedBox(height: 10),
              Text(
                token,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
