import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:usersapp/Screens/dashboard.dart';
import 'package:usersapp/Screens/forgotpasswordscreen.dart';
import 'package:usersapp/Screens/mapscreen.dart';
import 'package:usersapp/global.dart';
import 'package:usersapp/Screens/mainscreen.dart';
import 'package:usersapp/Screens/registerscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  void _submit() async {
    // Validate all fields
    if (_formKey.currentState!.validate()) {
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        );

        Fluttertoast.showToast(msg: "Successfully Logged In");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } catch (e) {
        Fluttertoast.showToast(msg: "Error Occurred: $e");
      }
    } else {
      Fluttertoast.showToast(msg: "All fields are not valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: ListView(
            padding: EdgeInsets.all(8),
            children: [
              Image.asset(
                darkTheme ? "assets/city1.jpg" : "assets/city3.jpg",
              ),
              SizedBox(height: 20),
              Text(
                "Register",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      darkTheme ? Colors.amber.shade300 : Colors.blue.shade200,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          TextFormField(
                            controller: emailTextEditingController,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme
                                  ? Colors.black45
                                  : Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              prefixIcon: Icon(Icons.email,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.grey),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return "Email field can't be empty";
                              }
                              if (!EmailValidator.validate(text)) {
                                return "Please enter a valid Email";
                              }
                              if (text.length < 2) {
                                return "Please enter a valid Email";
                              }
                              if (text.length > 99) {
                                return "Email can't be more than 100";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: passwordTextEditingController,
                            keyboardType: TextInputType.text,
                            obscureText: !_passwordVisible,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme
                                  ? Colors.black45
                                  : Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              prefixIcon: Icon(Icons.password,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: darkTheme ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    // Toggle the state of password visibility
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return "Password field can't be empty";
                              }

                              if (text.length < 2) {
                                return "Please enter a valid Password";
                              }
                              if (text.length > 49) {
                                return "Password can't be more than 49";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme
                                  ? Colors.amber.shade300
                                  : Colors.blue,
                              foregroundColor:
                                  darkTheme ? Colors.black87 : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(52),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              _submit();
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()));
                            },
                            child: Text(
                              "Forgot password",
                              style: TextStyle(
                                color: darkTheme
                                    ? Colors.amber.shade300
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No account?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterScreen()));
                                },
                                child: Text(
                                  "SignUp",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: darkTheme
                                        ? Colors.amber.shade300
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
