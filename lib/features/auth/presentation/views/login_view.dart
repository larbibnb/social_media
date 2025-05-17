import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/components/custom_button.dart';
import 'package:social_media/features/auth/presentation/components/custom_text_field.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';

class LoginView extends StatefulWidget {
  final void Function() onTap;
  const LoginView({super.key, required this.onTap});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  void login() {
    if (formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final authCubit = context.read<AuthCubit>();
      authCubit.login(email: email, pw: password);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 18.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 50),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 25),
                CustomTextFormField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                SizedBox(height: 10),
                CustomTextFormField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 25),
                CustomButton(text: 'Login', onTap: login),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Register now!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
