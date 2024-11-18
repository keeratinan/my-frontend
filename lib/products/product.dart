import 'package:flutter/material.dart';
import 'package:my_luxe_house/payment/cartoverlay.dart';
import 'package:my_luxe_house/payment/cartscreen.dart';
import 'package:my_luxe_house/payment/checkoutfrombuynow.dart';
import 'package:provider/provider.dart';
import '../screens/base_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  String currentCustomerId = '64bfa6c72e7a914a5c3b543c';

  Future<void> addItemToCart(
      BuildContext context, Map<String, dynamic> item) async {
    final url = Uri.parse('http://localhost:3000/carts');

    print("Product ID sent to server: ${item['_id']}");
    print("Customer ID sent to server: $currentCustomerId");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': item['_id'],
          'quantity': 1,
          'customerId': currentCustomerId,
          'price': item['Price'],
          'brand': item['Brand'],
          'serialNumber': item['Serial_number'],
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มสินค้าลงในตะกร้าสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเพิ่มสินค้า: ${response.body}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  double _parsePrice(String? priceString) {
    try {
      if (priceString == null || priceString.isEmpty) {
        return 0.0;
      }

      final cleanedPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '').trim();

      return double.parse(cleanedPrice);
    } catch (e) {
      debugPrint('Error parsing price: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Product Details',
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.network(
                      product['Images'],
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    ),
                  ),
                  Text(
                    '${product['Brand']}, ${product['Serial_number']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    product['Price'] != null ? '${product['Price']} ฿' : '',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey[400]),
                  _buildDetailRow('Size', product['Size'],
                      FontAwesomeIcons.rulerHorizontal),
                  _buildDetailRow(
                      'Color', product['Color'], FontAwesomeIcons.palette),
                  _buildDetailRow(
                      'Material', product['Material'], FontAwesomeIcons.cube),
                  _buildDetailRow(
                      'Features', product['Features'], FontAwesomeIcons.star),
                  _buildDetailRow('Condition', product['Condition'],
                      FontAwesomeIcons.infoCircle),
                  _buildDetailRow('Stock Status', product['Stock_status'],
                      FontAwesomeIcons.store),
                  _buildDetailRow('Warranty', product['Warranty'],
                      FontAwesomeIcons.shieldAlt),
                  Divider(color: Colors.grey[400]),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Colors.black,
                                  tabs: [
                                    Tab(text: 'การรับประกันสินค้า'),
                                    Tab(text: 'เทรดแลกเปลี่ยน'),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  height: 80.0,
                                  child: TabBarView(
                                    children: [
                                      Center(
                                        child: Text(
                                          'มีการรับประกันสินค้าให้นานถึง 6 เดือน ครอบคลุมทั้งตัวเครื่องและถ่านของนาฬิกา เพื่อให้ลูกค้ามั่นใจในคุณภาพของสินค้าที่เลือกซื้อจากเรา นอกจากนี้ เรายังมีบริการหลังการขายที่คอยดูแลและให้คำปรึกษาตลอดระยะเวลาการใช้งาน เพื่อให้คุณได้รับประสบการณ์ที่ดีที่สุดจากการใช้สินค้า',
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          'สามารถแลกเปลี่ยนนาฬิกาไม่ว่าจะเป็นนาฬิกาใหม่หรือมือสองได้ตลอดหากนาฬิกาไม่ได้มีตำหนิ และไม่ได้มีอาการเสีย สามารถกรอกฟอร์ม หน้า sell/trade เพื่อส่งข้อมูลของคุณมาเสนอให้ทางเราพิจารณาได้เลย',
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
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
                      SizedBox(width: 100),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                  width: 220,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      final cartItem = {
                                        '_id': product['_id'],
                                        'title':
                                            '${product['Brand']} ${product['Serial_number']}',
                                        'price': _parsePrice(product['Price']),
                                        'quantity': 1,
                                        'imageUrl': product['Images'],
                                      };

                                      Provider.of<CartModel>(context,
                                              listen: false)
                                          .addItem(cartItem);

                                      addItemToCart(context, product);

                                      CartOverlay.show(context);
                                    },
                                    child: Text('ADD TO CART'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey[600],
                                      side:
                                          BorderSide(color: Colors.grey[600]!),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ),
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 220,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CheckoutScreen(
                                            product: product,
                                            products: [],
                                          ),
                                        ),
                                      );
                                    },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 0, 51, 102), 
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40.0, vertical: 16.0),
                                  ),
                                  child: Text(
                                    'BUY NOW',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String detail, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          FaIcon(icon, color: Colors.amber[700], size: 26),
          SizedBox(width: 30),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            detail,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
