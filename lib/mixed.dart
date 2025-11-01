import 'package:flutter/material.dart';

import 'main.dart';

class Mixed extends StatefulWidget {
  final Map results;

  const Mixed({super.key, required this.results
  });

  @override
  State<Mixed> createState() => _MixedState();
}

class _MixedState extends State<Mixed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
                  (route) => false,  // Remove all
            );
          }
      ),
    );
  }
}
