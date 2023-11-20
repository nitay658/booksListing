//import 'package:books_app/firebase_options.dart';
import 'package:books_app/navigat_app_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register/Log-in')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: 'Please enter your email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: 'Please enter your password'),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password)
                      .then((value) => print(value))
                      .catchError((error, stackTrace) => {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Register Failed'),
                                  content: Text(error.toString()),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog.
                                      },
                                    ),
                                  ],
                                );
                              },
                            )
                          });
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password)
                      .then((result) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigatAppPage()),
                    );
                  }).onError((error, stackTrace) => showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Sign-In Failed'),
                            content: const Text(
                                'The email or password you entered is incorrect.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog.
                                },
                              ),
                            ],
                          );
                        },
                      ));
                },
                child: const Text('Login'),
              )
            ],
          ),
        ],
      ),
    );
  }
}