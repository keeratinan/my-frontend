import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_luxe_house/screens/base_screen.dart';
import 'package:my_luxe_house/shipping/shipping.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class BankTransferScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  BankTransferScreen({required this.products, required String customerId});

  @override
  _BankTransferScreenState createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  Uint8List? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    } else {
      print('No image selected.');
    }
  }

Future<void> submitOrder() async {
  var url = Uri.parse('http://localhost:3000/orders');
  var customerId = '64bfa6c72e7a914a5c3b543c'; 

  if (widget.products.isEmpty || _selectedImage == null) {
    print('Error: Missing products or payment image');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please add products and upload a payment image')),
    );
    return;
  }

  try {
    var orderData = {
      'customer_id': customerId,
      'products': widget.products.map((product) {
        return {
          'productId': product['_id'],
          'quantity': product['quantity'] ?? 1,
          'brand': product['brand'],
          'serialNumber': product['serial_number'],
          'price': product['price'],
          'images': product['images']
        };
      }).toList(),
      'payment_method': 'Bank Transfer',
      'payment_image': base64Encode(_selectedImage!), 
      'addedAt': DateTime.now().toIso8601String(),
    };

     print('Order Data: $orderData');

    var response = await http.post(url,
        body: json.encode(orderData),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      print("Order submitted successfully");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment completed successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShippingScreen(customerId: customerId, orderData: {},),
        ),
      );
    } else {
      print('Failed to submit order. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to submit order');
    }
  } catch (e) {
    print('Error occurred while sending order data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit order: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Bank Transfer',
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 600,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Bank Transfer',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/SCB.png',
                                width: 70,
                                height: 70,
                              ),
                              SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Account Number  ',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontFamily: 'Georgia',
                                        ),
                                      ),
                                      Text(
                                        '322-260906-0',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black87,
                                          fontFamily: 'Georgia',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Account Name  ',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontFamily: 'Georgia',
                                        ),
                                      ),
                                      Text(
                                        'กีรตินันท์ พุทธายะ',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black87,
                                          fontFamily: 'Georgia',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Please check the account number and name carefully, and attach the payment slip.',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'กรุณาตรวจสอบเลขที่บัญชีและชื่อให้ถูกต้อง และแนบหลักฐานการชำระเงิน',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      _buildImageUpload(),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                            ),
                            child: Text(
                              'Back',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedImage == null) {
                                _showImageRequiredDialog(context);
                              } else {
                                submitOrder();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }

  void _showImageRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Image Required'),
          content: Text('Please upload an image before submitting.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Upload Image *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey),
          ),
          child: Text(
            'Choose File',
            style: TextStyle(color: Colors.black),
          ),
        ),
        SizedBox(height: 16),
        _selectedImage != null
            ? GestureDetector(
                onTap: () {
                  _showFullImageDialog(context);
                },
                child: Image.memory(
                  _selectedImage!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              )
            : Text('No image selected.'),
      ],
    );
  }

  void _showFullImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.all(10),
            child: Image.memory(
              _selectedImage!,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
