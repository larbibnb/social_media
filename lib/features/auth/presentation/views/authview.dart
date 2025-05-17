import 'package:flutter/widgets.dart';
import 'package:social_media/features/auth/presentation/views/login_view.dart';
import 'package:social_media/features/auth/presentation/views/register_view.dart';

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  bool showLoginScreen = true;
  void toggleScreens() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return LoginView(onTap: toggleScreens);
    } else {
      return RegisterView(onTap: toggleScreens);
    }
  }
}
