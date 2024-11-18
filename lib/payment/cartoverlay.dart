import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_luxe_house/payment/checkoutfromcart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:my_luxe_house/payment/cartscreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>?> fetchCartItemsFromMongoDB() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/carts'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Cart items from MongoDB: $data');
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      print('Failed to load cart items from MongoDB. Status code: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching cart items: $error');
    return null;
  }
}

class CartOverlay extends StatefulWidget {
  @override
  _CartOverlayState createState() => _CartOverlayState();

  static void show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) => Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 500,
              child: CartOverlay(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartOverlayState extends State<CartOverlay> {
  @override
  void initState() {
    super.initState();
    fetchCartItemsFromMongoDB().then((cartItemsFromDb) {
      if (cartItemsFromDb != null) {
        Provider.of<CartModel>(context, listen: false).setItems(cartItemsFromDb);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat('#,###'); 

    return Material(
      color: Colors.black54,
      child: Container(
        width: 600,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CART',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 51, 102), 
                  ),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.times),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: Consumer<CartModel>(
                builder: (context, cart, child) {
                  if (cart.items.isEmpty) {
                    return Center(child: Text('Your cart is empty.'));
                  }
                  return ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.white,
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10.0),
                          leading: item['images'] != null
                              ? Image.network(
                                  item['images'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return FaIcon(
                                        FontAwesomeIcons.exclamationTriangle,
                                        size: 30);
                                  },
                                )
                              : SizedBox(width: 60, height: 60),
                          title: Text(
                            item['brand'] ?? '',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item['serialNumber'] ?? ''}\n${formatter.format(item['price'] ?? 0)} ฿', // จัดรูปแบบราคา
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          trailing: SizedBox(
                            width: 180,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.minus, size: 18),
                                  onPressed: () {
                                    cart.decreaseItemQuantity(index);
                                  },
                                ),
                                Text(
                                  item['quantity']?.toString() ?? '1',
                                  style: TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.plus, size: 18),
                                  onPressed: () {
                                    cart.increaseItemQuantity(index);
                                  },
                                ),
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.trash),
                                  onPressed: () {
                                    cart.removeItem(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'ค่าจัดส่งจะคำนวณเมื่อชำระเงิน',
              style: TextStyle(
                fontSize: 14,
                color: const Color.fromARGB(255, 168, 168, 168),
              ),
            ),
            SizedBox(height: 10),
            Consumer<CartModel>(
              builder: (context, cart, child) {
                return ElevatedButton(
                  onPressed: () {
                    if (cart.items.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutFromCartScreen(
                            products: cart.items, product: {},
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cart is empty')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 51, 102), 
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CHECKOUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${formatter.format(cart.totalPrice)} ฿', 
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
