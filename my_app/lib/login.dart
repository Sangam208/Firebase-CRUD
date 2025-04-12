import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/home.dart';
import 'package:my_app/signup.dart';

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
  bool _isHovered = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Logged in...',
                  style: Theme.of(context).textTheme.bodyMedium)),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Invalid credentials';

      if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many failed attempts. Try again later.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium)),
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
                width: containerWidth,
                padding: const EdgeInsets.all(14.0), // Uniform padding
                child: Column(
                  // Change from fixed height to flexible height
                  mainAxisSize: MainAxisSize
                      .min, // Allows it to shrink or expand based on content
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Log In',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _loginkey,
                      child: Column(
                        children: [
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
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
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
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
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
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await loginWithEmailAndPassword();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 13),
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor:
                                  const Color.fromARGB(255, 15, 117, 145),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Log In',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                          ),

                          SizedBox(height: 10),

                          // Log In Navigation
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(builder: (
                                context,
                              ) {
                                return Signup();
                              }));
                            },
                            style: TextButton.styleFrom(
                              padding:
                                  EdgeInsets.zero, // Remove default padding
                              minimumSize:
                                  Size.zero, // Remove minimum size constraints
                              tapTargetSize: MaterialTapTargetSize
                                  .shrinkWrap, // Shrink tap target size
                              foregroundColor:
                                  Theme.of(context).textTheme.bodySmall?.color,
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
                                'Create a new account',
                                style: _isHovered
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: const Color.fromARGB(
                                                255, 206, 115, 85),
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                const Color.fromARGB(
                                                    255, 206, 115, 85))
                                    : Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
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
    );
  }
}
