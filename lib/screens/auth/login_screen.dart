import 'package:flutter/material.dart';
import 'package:spotify/cliper/cliper.dart';
import 'package:spotify/screens/auth/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    Widget buildEmail() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null; // <-- you should also return null when validation passes
          },
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.lock_outline_rounded),
            hintText: 'Enter your email address',
          ),
        ),
      );
    }

    Widget buildPassword() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          controller: passwordController, // <-- corrected here
          obscureText: true, // <-- usually you'd want this for password fields
          decoration: InputDecoration(
            labelText: 'Password',
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(Icons.lock_outline_rounded),
            hintText: 'Enter your password',
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 300),
                    painter: RPSCustomPainter(),
                  ),
                  Positioned(
                    top: 16,
                    right: -5,
                    child: CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 300),
                      painter: RPSCustomPainter(),
                    ),
                  ),
                  Positioned(
                    top: 200,
                    right: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login to your account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Please sign in to continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 25),
                    buildEmail(),
                    const SizedBox(height: 20),
                    buildPassword(),
                    const SizedBox(height: 20),
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xffFCA148),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [Color(0xfff7b858), Color(0xfffca148)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          SizedBox(width: 20),
                          Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30), // reduced space
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign up ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xffFCA148),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ), // extra bottom padding if needed
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
