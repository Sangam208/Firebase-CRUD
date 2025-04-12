import 'package:flutter/material.dart';
import 'package:practice_app/services/db_services.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _signupkey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorstyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: const Color.fromARGB(255, 230, 81, 70),
    );
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            // Text(
                            //   'Sign Up',
                            //   style: Theme.of(context).textTheme.titleLarge,
                            // ),
                            const SizedBox(height: 10),
                            Form(
                              key: _signupkey,
                              child: Column(
                                children: [
                                  //Username
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                      errorStyle: errorstyle,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Username cannot be empty!';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  //Email
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'eg: someone@gmail.com',
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                      errorStyle: errorstyle,
                                    ),
                                    validator: (value) {
                                      String pattern =
                                          r'^[a-z]+[0-9]*(_?[0-9]+)*(\.[a-z]+[0-9]*(_?[0-9]+)*)*@[a-z0-9-]+\.[a-z]{2,}$';

                                      RegExp regex = RegExp(pattern);
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!regex.hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  //Password
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                      errorStyle: errorstyle,
                                      errorMaxLines: 3,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                      ),
                                      suffixIconColor: Colors.black54,
                                    ),
                                    validator: (value) {
                                      String pattern =
                                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\-\=\[\]\{\};:\",<>./?\\|`~])';
                                      RegExp regex = RegExp(pattern);
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (_passwordController.text.length < 8) {
                                        return 'Password must be at least 8 characters long';
                                      }
                                      if (!regex.hasMatch(value)) {
                                        return 'Password must include uppercase, lowercase, numbers, and special characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 10),

                                  //Confirm Password
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                      errorStyle: errorstyle,

                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                      ),
                                      suffixIconColor: Colors.black54,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  //Signup button
                                  ElevatedButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () async {
                                              FocusScope.of(context).unfocus();
                                              if (_signupkey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                String
                                                result = await DbServices()
                                                    .createUserWithEmailAndPassword(
                                                      _emailController.text
                                                          .trim(),
                                                      _passwordController.text
                                                          .trim(),
                                                      _nameController.text
                                                          .trim(),
                                                    );
                                                setState(() {
                                                  _isLoading = false;
                                                });

                                                if (result ==
                                                    "Sign up successful!") {
                                                  Navigator.pushReplacementNamed(
                                                    context,
                                                    "/login",
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(result),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                      minimumSize: Size(double.infinity, 50),
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        46,
                                        151,
                                        49,
                                      ),
                                    ),
                                    child:
                                        _isLoading
                                            ? CircularProgressIndicator(
                                              color: Colors.white60,
                                            )
                                            : Text(
                                              'Sign Up',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Create an account
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          padding:
                                              EdgeInsets
                                                  .zero, // Remove default padding
                                          minimumSize:
                                              Size.zero, // Remove minimum size constraints
                                          tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap, // Shrink tap target size
                                          foregroundColor:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.color,
                                          overlayColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          'Log In',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            fontSize: 16,
                                            color: const Color.fromARGB(
                                              255,
                                              47,
                                              143,
                                              233,
                                            ),
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                const Color.fromARGB(
                                                  255,
                                                  47,
                                                  143,
                                                  233,
                                                ),
                                            decorationThickness: 1,
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
                    ),
                  ),
                  Positioned(
                    top: 20,
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
