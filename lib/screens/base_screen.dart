import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_luxe_house/payment/cartoverlay.dart';
import 'package:my_luxe_house/user/profile.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? drawer;
  final List<Widget>? actions;

  BaseScreen({required this.title, required this.body, this.drawer, this.actions});

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
          'LUXEHOUSE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          NavItem(title: 'Home', routeName: '/'),
          NavItem(title: 'Collection', routeName: '/collection'),
          NavItem(title: 'Sell-Trade', routeName: '/sell-trade'),
          /*NavItem(title: 'Register', routeName: '/register'),
          Text(
              '|',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          NavItem(title: 'Login', routeName: '/userlogin'),*/
          _buildIconButton(context, FontAwesomeIcons.robot, '/chatbot'),
          IconButton(
            icon: StatefulIcon(icon: FontAwesomeIcons.shoppingCart),
            onPressed: () {
              CartOverlay.show(context);
            },
          ),
            IconButton(
            icon: StatefulIcon(icon: FontAwesomeIcons.user),
            onPressed: () {
              ProfileOverlay.show(context);
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: drawer,
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

  Widget _buildIconButton(
      BuildContext context, IconData icon, String routeName) {
    return IconButton(
      icon: StatefulIcon(icon: icon),
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
                  Navigator.pushNamed(context, '/login');
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

class StatefulIcon extends StatefulWidget {
  final IconData icon;

  StatefulIcon({required this.icon});

  @override
  _StatefulIconState createState() => _StatefulIconState();
}

class _StatefulIconState extends State<StatefulIcon> {
  Color _iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _updateIconColor(Colors.yellow),
      onExit: (_) => _updateIconColor(Colors.white),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          widget.icon,
          color: _iconColor,
          size: 20.0,
        ),
      ),
    );
  }

  void _updateIconColor(Color color) {
    setState(() {
      _iconColor = color;
    });
  }
}

class NavItem extends StatefulWidget {
  final String title;
  final String routeName;

  NavItem({required this.title, required this.routeName});

  @override
  _NavItemState createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, widget.routeName);
      },
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Text(
              widget.title,
              style: TextStyle(
                color: _isHovering ? Colors.yellow : Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 18,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool hovering) {
    setState(() {
      _isHovering = hovering;
    });
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
