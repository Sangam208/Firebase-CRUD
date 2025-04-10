import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/login.dart';

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
  bool _isHovered = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      debugPrint("User created: ${userCredential.user}");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Signup Successful!',
            style: Theme.of(context).textTheme.bodyMedium,
          )),
        );
      }

      // Redirect to login screen after a short delay
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Signup failed. Please try again.";

      if (e.code == 'email-already-in-use') {
        errorMessage = "User already exists";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Network error, please try again later.";
      } else {
        debugPrint('Error Code: ${e.code}');
        debugPrint('Error Message: ${e.message}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          )),
        );
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            "Signup failed. Please try again.",
            style: Theme.of(context).textTheme.bodyMedium,
          )),
        );
      }
    }
  }

  OutlineInputBorder customBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromRGBO(226, 251, 116, 0.694)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 400 : screenWidth;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Card(
              color: Theme.of(context).colorScheme.primary,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.8, // Adjust height dynamically
                ),

                width: containerWidth,
                padding: const EdgeInsets.all(14.0), // Uniform padding
                child: SingleChildScrollView(
                  child: Column(
                    // Change from fixed height to flexible height
                    mainAxisSize: MainAxisSize
                        .min, // Allows it to shrink or expand based on content
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: _signupkey,
                        child: Column(
                          children: [
                            // Full Name
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).primaryColor,
                                hintText: 'Full Name',
                                border: customBorder(),
                                enabledBorder: customBorder(),
                                focusedBorder: customBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).primaryColor,
                                hintText: 'Email',
                                border: customBorder(),
                                enabledBorder: customBorder(),
                                focusedBorder: customBorder(),
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
                            SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).primaryColor,
                                hintText: 'Password',
                                border: customBorder(),
                                enabledBorder: customBorder(),
                                focusedBorder: customBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(_isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
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
                            SizedBox(height: 16),

                            // Confirm Password
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).primaryColor,
                                hintText: 'Confirm Password',
                                border: customBorder(),
                                enabledBorder: customBorder(),
                                focusedBorder: customBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                  icon: Icon(_isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
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

                            // Sign Up Button
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_signupkey.currentState?.validate() ??
                                          false) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await createUserWithEmailAndPassword();
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 13),
                                minimumSize: Size(double.infinity, 50),
                                backgroundColor:
                                    const Color.fromARGB(255, 46, 151, 49),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'Sign Up',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                            ),

                            SizedBox(height: 10),

                            // Log In Navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (
                                      context,
                                    ) {
                                      return Login();
                                    }));
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets
                                        .zero, // Remove default padding
                                    minimumSize: Size
                                        .zero, // Remove minimum size constraints
                                    tapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, // Shrink tap target size
                                    foregroundColor: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    overlayColor: Colors.transparent,
                                  ),
                                  child: MouseRegion(
                                    onEnter: (_) {
                                      setState(() {
                                        _isHovered = true;
                                      });
                                    },
                                    onExit: (_) {
                                      setState(() {
                                        _isHovered = false;
                                      });
                                    },
                                    child: Text(
                                      'Log In',
                                      style: _isHovered
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: Colors.blueAccent,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      Colors.blueAccent)
                                          : Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    10), // Add some space at the bottom for better balance
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
