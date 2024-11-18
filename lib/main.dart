import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:my_luxe_house/admin/admin_login.dart';
import 'package:my_luxe_house/payment/cartoverlay.dart';
import 'package:my_luxe_house/payment/checkoutfrombuynow.dart';
import 'package:my_luxe_house/payment/receiptPage.dart';
import 'package:my_luxe_house/user/login.dart';
import 'package:my_luxe_house/user/profile.dart';
import 'package:my_luxe_house/shipping/shipping.dart';
import 'package:my_luxe_house/screens/chatbot.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'products/collection.dart';
import 'screens/sell_trade.dart';
import 'about/contact.dart';
import 'admin/admin_dashboard.dart';
import 'payment/cartscreen.dart';

void main() {
  

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(), 
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  
  get collection => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luxe House',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Georgia',
      ),
      initialRoute: '/userlogin',
      routes: {
        '/userlogin' :(context) => UserLoginScreen (),
        '/': (context) => HomeScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/forgot-password2': (context) => ForgotPassword2Screen(),
        '/register': (context) => RegisterScreen(),
        '/collection': (context) => CollectionScreen(),
        '/sell-trade': (context) => SellTradeScreen(),
        '/contact': (context) => AboutAndContactScreen(),
        '/cart': (context) =>  CartOverlay(),
        '/chatbot': (context) => ChatbotScreen(),
        '/profile': (context) => ProfileInfoPage(token: '', client: null,), 
        '/checkout': (context) => CheckoutScreen(product: {}, products: []),
        '/shipping': (context) => ShippingScreen(orderData: {}, customerId: ''),
        '/receipt': (context) => ReceiptDialog(orderData: {},), 
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------admin--------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
        '/login': (context) => AdminLoginScreen(),
        '/admin': (context) => AdminDashboard(),
      },
    );
  }
}
