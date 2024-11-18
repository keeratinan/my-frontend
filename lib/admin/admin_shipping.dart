import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_luxe_house/admin/admin_dashboard.dart';
import 'package:my_luxe_house/admin/base_screen2.dart';

class AdminShipping extends StatefulWidget {
  final Map<String, dynamic> orderData; 
  AdminShipping({required this.orderData});

  @override
  _ShippingScreenState createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<AdminShipping> {
  List<dynamic> allOrders = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    var url = Uri.parse('http://localhost:3000/orders'); 
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> fetchedOrders = json.decode(response.body);
        setState(() {
          allOrders = fetchedOrders.map((order) {
            return {
              'orderId': order['orderId'] ?? '',
              'products': (order['products'] as List).map((product) {
                return {
                  'brand': product['brand'] ?? 'N/A',
                  'serialNumber': product['serialNumber'] ?? 'N/A',
                  'quantity': product['quantity'] ?? 0,
                };
              }).toList(),
              'addedAt': order['addedAt'] ?? '',
              'shippingInfo': order['shippingInfo'] ?? {},
              'status': order['status'] ?? '',
              'trackingNumber': order['trackingNumber'] ?? 'No Tracking Number',
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

 @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Shipping Screen',
      drawer: AdminDrawer(),
      body: Container(
        color: Colors.white, 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildOrderList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Shipping Orders',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,  color:  const Color.fromARGB(255, 0, 51, 102), ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.black),
              labelText: 'Search Orders (Order ID)',
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

  Widget _buildOrderList() {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListView(
        children: allOrders
            .where((order) =>
                order['orderId'].toString().contains(searchQuery))
            .map((order) {
          return _buildOrderTile(order);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          'Order ID: ${order['orderId'] ?? 'N/A'}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: const Color.fromARGB(255, 0, 51, 102), ),
        ),
        trailing: Icon(FontAwesomeIcons.chevronDown, size: 20, color: Colors.black),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductsSection(order),
                const SizedBox(height: 16),
                _buildOrderDetails(order),
                const SizedBox(height: 24),
                _buildTrackingSection(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildProductsSection(Map<String, dynamic> order) {
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
      ...order['products'].map<Widget>((product) {
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
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.box, color: Colors.indigo[900], size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ],
  );
}

Widget _buildOrderDetails(Map<String, dynamic> order) {
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
          Row(
            children: [
              FaIcon(FontAwesomeIcons.calendar, color: Colors.indigo[900], size: 24),
              const SizedBox(width: 8),
              Text(
                'Added At: ${order['addedAt'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.truck, color: Colors.indigo[900], size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shipping Info: ${order['shippingInfo']?.toString() ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(thickness: 1, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.infoCircle, color: Colors.indigo[900], size: 24),
              const SizedBox(width: 8),
              Text(
                'Status: ${order['status'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildTrackingSection(Map<String, dynamic> order) {
  bool hasTracking = order['trackingNumber'] != null && order['trackingNumber'].isNotEmpty;

  return Card(
    color: Colors.white,
    margin: const EdgeInsets.only(top: 16.0),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.truck, color: Colors.indigo[900], size: 24),
              const SizedBox(width: 8),
              Text(
                'Tracking Information:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasTracking)
            Row(
              children: [
                FaIcon(FontAwesomeIcons.barcode, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Tracking Number: ${order['trackingNumber']}',
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
            )
          else
            Row(
              children: [
                FaIcon(FontAwesomeIcons.exclamationTriangle, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  'No Tracking Number Available',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (!hasTracking)
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(
                'Tracking number will be generated automatically upon shipment.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    ),
  );
}}
