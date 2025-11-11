import 'package:flutter/widgets.dart';
import 'package:social_media/features/auth/presentation/views/login_view.dart';
import 'package:social_media/features/auth/presentation/views/register_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
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
