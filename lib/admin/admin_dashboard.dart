import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_luxe_house/admin/admin_chat.dart';
import 'package:my_luxe_house/admin/admin_chatbot.dart';
import 'package:my_luxe_house/admin/admin_order.dart';
import 'package:my_luxe_house/admin/admin_report.dart';
import 'package:my_luxe_house/admin/admin_selltrade.dart';
import 'package:my_luxe_house/admin/admin_shipping.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_screen2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildListTile(context, 'Admin Edit', FontAwesomeIcons.edit,
              AdminDashboard()),
          _buildListTile(context, 'Chatbot Admin', FontAwesomeIcons.box,
              ChatbotAdminScreen()),
          _buildListTile(context, 'Sell/Trade Management',
              FontAwesomeIcons.book, AdminSellTradeScreen()),
         /* _buildListTile(
          context, 'Order', FontAwesomeIcons.message,
               AdminOrderDay (),), */
          _buildListTile(context, 'Order Management ',
              FontAwesomeIcons.shoppingCart, OrderScreen()),
          _buildListTile(context, 'Claim Management ', FontAwesomeIcons.fileAlt,
              ClaimScreen()),
          _buildListTile(context, 'Report Management ',
              FontAwesomeIcons.chartBar, ReportScreen()),
        ],
      ),
    );
  }

  ListTile _buildListTile(
      BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------admin--------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

class AdminDashboard extends StatefulWidget {

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List products = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts([String query = '']) async {
    String url = 'http://localhost:3000/products';
    if (query.isNotEmpty) {
      url += '?search=$query';
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> _addProduct() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController brandController = TextEditingController();
        TextEditingController serialController = TextEditingController();
        TextEditingController sizeController = TextEditingController();
        TextEditingController colorController = TextEditingController();
        TextEditingController materialController = TextEditingController();
        TextEditingController featuresController = TextEditingController();
        TextEditingController conditionController = TextEditingController();
        TextEditingController stockController = TextEditingController();
        TextEditingController imagesController = TextEditingController();
        TextEditingController warrantyController = TextEditingController();
        TextEditingController priceController = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Center(
            child: Text(
              'เพิ่มสินค้า',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: brandController,
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: serialController,
                  decoration: InputDecoration(
                    labelText: 'Serial Number',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: sizeController,
                  decoration: InputDecoration(
                    labelText: 'Size',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: colorController,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: materialController,
                  decoration: InputDecoration(
                    labelText: 'Material',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: featuresController,
                  decoration: InputDecoration(
                    labelText: 'Features',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: conditionController,
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 107, 107, 107),
                      ),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9()-]')),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: imagesController,
                  decoration: InputDecoration(
                    labelText: 'Images',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: warrantyController,
                  decoration: InputDecoration(
                    labelText: 'Warranty',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (brandController.text.isEmpty ||
                    serialController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    stockController.text.isEmpty ||
                    sizeController.text.isEmpty ||
                    colorController.text.isEmpty ||
                    materialController.text.isEmpty ||
                    featuresController.text.isEmpty ||
                    conditionController.text.isEmpty ||
                    imagesController.text.isEmpty ||
                    warrantyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
                  );
                  return;
                }

                final response = await http.post(
                  Uri.parse('http://localhost:3000/products'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'Brand': brandController.text,
                    'Serial_number': serialController.text,
                    'Size': sizeController.text,
                    'Color': colorController.text,
                    'Material': materialController.text,
                    'Features': featuresController.text,
                    'Condition': conditionController.text,
                    'Stock_status': stockController.text,
                    'Images': imagesController.text,
                    'Warranty': warrantyController.text,
                    'Price': priceController.text,
                  }),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();
                  fetchProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เพิ่มสินค้าสำเร็จ')),
                  );
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เพิ่มสินค้าไม่สำเร็จ')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'เพิ่มสินค้า',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProduct(Map product) async {
    TextEditingController brandController =
        TextEditingController(text: product['Brand'] ?? '');
    TextEditingController serialController =
        TextEditingController(text: product['Serial_number'] ?? '');
    TextEditingController sizeController =
        TextEditingController(text: product['Size'] ?? '');
    TextEditingController colorController =
        TextEditingController(text: product['Color'] ?? '');
    TextEditingController materialController =
        TextEditingController(text: product['Material'] ?? '');
    TextEditingController featuresController =
        TextEditingController(text: product['Features'] ?? '');
    TextEditingController conditionController =
        TextEditingController(text: product['Condition'] ?? '');
    TextEditingController stockController =
        TextEditingController(text: product['Stock_status'] ?? '');
    TextEditingController imagesController =
        TextEditingController(text: product['Images'] ?? '');
    TextEditingController warrantyController =
        TextEditingController(text: product['Warranty'] ?? '');
    TextEditingController priceController =
        TextEditingController(text: product['Price'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Center(
            child: Text(
              'แก้ไขสินค้า',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: brandController,
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: serialController,
                  decoration: InputDecoration(
                    labelText: 'Serial Number',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: sizeController,
                  decoration: InputDecoration(
                    labelText: 'Size',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: colorController,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: materialController,
                  decoration: InputDecoration(
                    labelText: 'Material',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: featuresController,
                  decoration: InputDecoration(
                    labelText: 'Features',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: conditionController,
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 107, 107, 107),
                      ),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9()-]')),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: imagesController,
                  decoration: InputDecoration(
                    labelText: 'Images',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: warrantyController,
                  decoration: InputDecoration(
                    labelText: 'Warranty',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                print('Product ID: ${product['_id']}');
                final response = await http.put(
                  Uri.parse('http://localhost:3000/products/${product['_id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'Brand': brandController.text,
                    'Serial_number': serialController.text,
                    'Size': sizeController.text,
                    'Color': colorController.text,
                    'Material': materialController.text,
                    'Features': featuresController.text,
                    'Condition': conditionController.text,
                    'Stock_status': stockController.text,
                    'Images': imagesController.text,
                    'Warranty': warrantyController.text,
                    'Price': priceController.text,
                  }),
                );
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  fetchProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('แก้ไขสินค้าสำเร็จ')),
                  );
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('แก้ไขสินค้าไม่สำเร็จ')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'อัพเดทสินค้า',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Center(
            child: Text(
              'ยืนยันการลบสินค้า',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          content: Text(
            'คุณต้องการลบสินค้านี้จริงหรือไม่?',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'ลบ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/products/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบสินค้าสำเร็จ')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบสินค้าไม่สำเร็จ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Admin Dashboard',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Admin Edit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 51, 102),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(FontAwesomeIcons.search),
                        labelText: 'ค้นหาสินค้า (Brand หรือ Serial Number)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        fetchProducts(searchQuery);
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _addProduct,
                    child: Text('เพิ่มสินค้า'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Brand')),
                          DataColumn(label: Text('Serial_number')),
                          DataColumn(label: Text('Stock_status')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Annotation')),
                        ],
                        rows: products.map((product) {
                          return DataRow(cells: [
                            DataCell(Text(product['_id']?.toString() ?? 'N/A')),
                            DataCell(Text(product['Brand'] ?? 'N/A')),
                            DataCell(Text(product['Serial_number'] ?? 'N/A')),
                            DataCell(Text(product['Stock_status'] ?? 'N/A')),
                            DataCell(Text(product['Price'] ?? 'N/A')),
                            DataCell(
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _editProduct(product);
                                    },
                                    child: Text('แก้ไข'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _deleteProduct(product['_id']);
                                    },
                                    child: Text('ลบ'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[400],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: AdminDrawer(),
    );
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------admin--------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

class ClaimScreen extends StatefulWidget {
  @override
  _ClaimScreenState createState() => _ClaimScreenState();
}

class _ClaimScreenState extends State<ClaimScreen> {
  List<dynamic> claims = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchClaims();
  }

  Future<void> fetchClaims() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/claims'));

      if (response.statusCode == 200) {
        setState(() {
          claims = json.decode(response.body);
        });
        print(claims);
      } else {
        throw Exception('Failed to load claims');
      }
    } catch (e) {
      print('Error fetching claims: $e');
    }
  }

  Future<void> _handleClaimAction(String claimId, String action) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/claims/$claimId/$action'),
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchClaims(); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Claim $action successfully!')),
      );
    } else {
      throw Exception('Failed to $action claim');
    }
  } catch (e) {
    print('Error processing claim: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to process claim')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Claim Management',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildClaimList(),
            ),
          ],
        ),
      ),
      drawer: AdminDrawer(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Claims',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 51, 102),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.black),
              labelText: 'ค้นหา (Claim ID)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClaimList() {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.builder(
        itemCount: claims.length,
        itemBuilder: (context, index) {
          return _buildClaimTile(claims[index]);
        },
      ),
    );
  }

  Widget _buildClaimTile(Map<String, dynamic> claim) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          'Claim ID: ${claim['claimId'] ?? 'N/A'}',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 51, 102)),
        ),
        trailing: Icon(
          FontAwesomeIcons.chevronDown,
          size: 20,
          color: Colors.black,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductsSection(claim),
                const SizedBox(height: 16),
                _buildClaimDetails(claim),
                const SizedBox(height: 24),
                _buildImagesSection(claim),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(Map<String, dynamic> claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products:',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          child: ListView(
            children: claim['product'].map<Widget>((product) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      product['images'] != 'N/A'
                          ? Image.network(
                              product['images'][0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : FaIcon(
                              FontAwesomeIcons.bagShopping,
                              color: Colors.indigo[900],
                              size: 30,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        'Brand: ${product['brand'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[900],
                        ),
                      ),
                      Text(
                        'Serial: ${product['serialNumber'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                      Text(
                        'Quantity: ${product['quantity'] ?? 0}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                      Text(
                        'Price: ${product['price'] ?? 0}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                    ]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

 Widget _buildClaimDetails(Map<String, dynamic> claim) {
  return Card(
    margin: const EdgeInsets.only(top: 16.0),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.stickyNote,
                  color: Colors.grey[600], size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Note: ${claim['note'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.infoCircle,
                  color: Colors.grey[600], size: 24),
              SizedBox(width: 8),
              Text(
                'Status: ${claim['status'] ?? 'pending'}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _handleClaimAction(claim['claimId'], 'accepted');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('ยอมรับการเคลม'),
              ),
              ElevatedButton(
                onPressed: () {
                  _handleClaimAction(claim['claimId'], 'rejected');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('ปฏิเสธการเคลม'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildImagesSection(Map<String, dynamic> claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images:',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: (claim['images'] as List).length,
            itemBuilder: (context, index) {
              String image = claim['images'][index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Image.memory(
                                base64Decode(image),
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(image),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
