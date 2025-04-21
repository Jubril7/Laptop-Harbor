import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop_harbor/features/user_auth/firebase_auth_impl/firebase_auth_service.dart';
import 'package:laptop_harbor/features/user_auth/presentation/pages/home_page.dart';
import 'package:laptop_harbor/features/user_auth/presentation/pages/login_page.dart';
import 'package:laptop_harbor/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});



  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {

  // final bool _isSigning = false;

final FirebaseAuthService _auth = FirebaseAuthService();


  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Laptop Harbour",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
            const Text(
              "Register",
              style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            FormContainerWidget(
              controller: _usernameController,
              hintText: "Username",
              isPasswordField: false,
            ),
            const SizedBox(
              height: 10.0,
            ),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
              isPasswordField: false,
            ),
            const SizedBox(
              height: 10.0,
            ),
            FormContainerWidget(
              controller: _passwordController,
              hintText: "Password",
              isPasswordField: true,
            ),
            const SizedBox(
              height: 30.0,
            ),
            GestureDetector(
              onTap:  _signUp,
              child: Container(
                width: double.infinity,
                height: 45.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.red,
                ),
                child: const Center(
                    child:  Text(
                  "Register",
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )),
              ),
            ),
            const SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an Account?"
                ),
                const SizedBox(width: 5.0,),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                    ),
                  
                  ),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }

void _signUp() async {
  String username = _usernameController.text.trim();
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (username.isEmpty || email.isEmpty || password.isEmpty) {
    _showErrorDialog("Please fill in all fields.");
    return;
  }

  try {
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      print("Sign up success");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
        (route) => false,
      );
    }
  } on FirebaseAuthException catch (e) {
    _showErrorDialog(e.message ?? "Registration failed.");
  } catch (e) {
    _showErrorDialog("An unknown error occurred.");
  }
}
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


}
