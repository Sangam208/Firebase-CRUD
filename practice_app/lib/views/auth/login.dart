import 'package:flutter/material.dart';
import 'package:practice_app/services/db_services.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _loginkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorstyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 14,
      color: const Color.fromARGB(255, 230, 81, 70),
    );
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Card(
                      color: const Color.fromARGB(255, 58, 227, 143),
                      margin: EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            // Text(
                            //   'Log In',
                            //   style: Theme.of(context).textTheme.titleLarge,
                            // ),
                            const SizedBox(height: 10),
                            Form(
                              key: _loginkey,
                              child: Column(
                                children: [
                                  //Email
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                      errorStyle: errorstyle,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
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
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  //Login button
                                  ElevatedButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () async {
                                              FocusScope.of(context).unfocus();
                                              if (_loginkey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                String
                                                result = await DbServices()
                                                    .loginWithEmailAndPassword(
                                                      _emailController.text
                                                          .trim(),
                                                      _passwordController.text
                                                          .trim(),
                                                    );
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(result),
                                                  ),
                                                );
                                                if (result ==
                                                    "Log in successful!") {
                                                  Navigator.pushReplacementNamed(
                                                    context,
                                                    "/mainpage",
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
                                        49,
                                        144,
                                        204,
                                      ),
                                    ),
                                    child:
                                        _isLoading
                                            ? CircularProgressIndicator(
                                              color: Colors.white60,
                                            )
                                            : Text(
                                              'Log In',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Create an account
                                  Text(
                                    'Don\'t have an account? ',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/signup");
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
                                      'Create a new account',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        fontSize: 16,
                                        color: const Color.fromARGB(
                                          255,
                                          15,
                                          133,
                                          45,
                                        ),
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color.fromARGB(
                                          255,
                                          15,
                                          133,
                                          45,
                                        ),
                                        decorationThickness: 1,
                                      ),
                                    ),
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
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 58, 227, 143),
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
