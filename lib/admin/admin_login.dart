import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminLoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'LUXEHOUSE ADMIN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false, 
    ),
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        Opacity(
          opacity: 0.2,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/BGBG.JPG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 500,
            child: Card(
              color: Colors.white,
              elevation: 8, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), 
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color.fromARGB(255, 0, 51, 102), 
                      child: Icon(
                        FontAwesomeIcons.user,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome Admin Luxehouse!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Admin ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.user), 
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.lock), 
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/userlogin');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey),
                              ),
                              backgroundColor: Colors.white, 
                              foregroundColor: Colors.black, 
                            ),
                            child: Text('USER Go to Login page'),
                          ),
                        ),
                        SizedBox(width: 25), 
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _login(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey),
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black, 
                            ),
                            child: Text('Login'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  void _login(BuildContext context) {
    String username = _usernameController.text;
    String password = _passwordController.text;
    if (username == 'admin' && password == 'admin123') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.grey,
        ),
      );
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Username or Password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
