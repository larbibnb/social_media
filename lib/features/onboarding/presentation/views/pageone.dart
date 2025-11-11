import 'package:flutter/material.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void dispose() {
    displayNameController.dispose();
    userNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            controller: displayNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Display Name',
              hintText: 'Display Name',
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: displayNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'User Name',
              hintText: 'User Name',
            ),
          ),
          SizedBox(height: 10),
          Text('Bio'),
          SizedBox(height: 10),
          TextField(
            controller: displayNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Bio',
              hintText: 'Bio',
            ),
          ),
        ],
      ),
    );
  }
}
