import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_luxe_house/admin/admin_dashboard.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? drawer;
  final String userName = 'Admin';
  final List<Widget>? actions;

  BaseScreen({required this.title, required this.body, this.drawer, this.actions,});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blueGrey[900],
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.blueGrey[900],
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 5.0,
        title: Text(
          'LUXEHOUSE ADMIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: drawer != null
            ? Builder(
                builder: (context) => IconButton(
                  icon: FaIcon(FontAwesomeIcons.bars, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.userCircle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Hello, $userName',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(width: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.signOutAlt,
                          color: Colors.white),
                      onPressed: () {
                        _logout(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      drawer: drawer ?? AdminDrawer(),
      body: Column(
        children: [
          Expanded(
            child: body,
          ),
          _buildFooterSection(context),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, String routeName) {
    return IconButton(
      icon: FaIcon(icon),
      onPressed: () {
        Navigator.pushNamed(context, routeName);
      },
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LUXEHOUSE2023',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildHoverableFooterLink('ADMIN DASHBOARD', () {
                    Navigator.pushNamed(context, '/admin');
                  }),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHoverableFooterLink(String title, VoidCallback onTap) {
    return HoverableLink(
      title: title,
      onTap: onTap,
    );
  }
}

class HoverableLink extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  HoverableLink({required this.title, required this.onTap});

  @override
  _HoverableLinkState createState() => _HoverableLinkState();
}

class _HoverableLinkState extends State<HoverableLink> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.title,
          style: TextStyle(
            color: isHovered ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
