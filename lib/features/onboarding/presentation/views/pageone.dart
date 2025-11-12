import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

class ProfileCreating extends StatefulWidget {
  final ValueChanged<String> onDisplayNameChanged;
  final ValueChanged<String> onUserNameChanged;
  final ValueChanged<String> onBioChanged;

  const ProfileCreating({
    super.key,
    required this.onDisplayNameChanged,
    required this.onUserNameChanged,
    required this.onBioChanged,
  });
  @override
  State<ProfileCreating> createState() => _ProfileCreatingState();
}

class _ProfileCreatingState extends State<ProfileCreating> {
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
      child: Column(
        children: [
          TextField(
            controller: displayNameController,
            onChanged: widget.onDisplayNameChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Display Name',
              hintText: 'Display Name',
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: userNameController,
            onChanged: widget.onUserNameChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'User Name',
              hintText: 'User Name',
            ),
          ),
          SizedBox(height: 10),
          Text('Where are you from?'),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              showCountryPicker(
                context: context,
                showPhoneCode:
                    true, // optional. Shows phone code before the country name.
                onSelect: (Country country) {
                  log('Select country: ${country.displayName}');
                },
              );
            },
            child: Text('Select Country'),
          ),
          SizedBox(height: 10),
          Text('Bio'),
          SizedBox(height: 10),
          TextField(
            controller: bioController,
            onChanged: widget.onBioChanged,
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
