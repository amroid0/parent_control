import 'package:flutter/material.dart';

class SearchBarChild extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const SearchBarChild({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for a child...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: const Icon(Icons.search),
        ),
        onChanged: onSearch,  // تحديث عند البحث
      ),
    );
  }
}
