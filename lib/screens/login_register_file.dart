import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_flutter/auth/authenticate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().signUpWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Text(isLogin ? 'Login' : 'Register');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 300,
        child: TextField(
          controller: controller,
          obscureText: title == 'password',
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: title,
          ),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage ?? '',
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (isLogin) {
          signInWithEmailAndPassword();
        } else {
          // check if password and confirm password are the same
          if (_passwordController.text ==
              _confirmPasswordController.text.replaceAll(' ', '')) {
            createUserWithEmailAndPassword();
          } else {
            setState(() {
              errorMessage = 'Password and Confirm Password are not the same';
            });
          }
        }
      },
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _toggleLogin() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          errorMessage = '';
        });
      },
      child: Text(isLogin ? 'Create an account' : 'Have an account? Login'),
    );
  }

  Widget _appTitle() {
    // if login show title, else show register
    return isLogin
        ? const Text.rich(
            TextSpan(
              text: 'Welcome to ',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'Events List',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.blue),
                ),
              ],
            ),
          )
        : const Text.rich(TextSpan(
            text: 'Register',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )));
  }

  // confirm password
  Widget _confirmPassword() {
    return isLogin
        ? const SizedBox()
        : Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _appTitle(),
              const SizedBox(height: 20),
              _errorMessage(),
              const SizedBox(height: 20),
              _entryField('email', _emailController),
              const SizedBox(height: 20),
              _entryField('password', _passwordController),
              const SizedBox(height: 20),
              _confirmPassword(),
              const SizedBox(height: 20),
              _submitButton(),
              const SizedBox(height: 20),
              _toggleLogin(),
            ],
          ),
        ),
      ),
    );
  }
}
