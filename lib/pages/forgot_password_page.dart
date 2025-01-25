import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password rest link sent. Check your email.'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffE5F3FD),
        appBar: AppBar(
            title: const Text('Reset Password'),
            backgroundColor: Color(0xffD1E5F4),
            centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Enter your email and we will send you a password reset link.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              MyTextField(
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 20),
              MaterialButton(
                  onPressed: passwordReset,
                  color: Color(0xff2A629A),
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ))
            ],
          ),
        ));
  }
}
