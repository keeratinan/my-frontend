import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_luxe_house/admin/admin_dashboard.dart';
import 'package:my_luxe_house/admin/admin_shipping.dart';
import 'dart:convert';
import 'package:my_luxe_house/admin/base_screen2.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<dynamic> allOrders = [];
  List<dynamic> filteredOrders = [];
  String searchQuery = '';
  String trackingNumber = '';
  DateTime? selectedDate;
  String filterOption = 'Show All';

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
        print('Fetched Orders: $fetchedOrders');

        setState(() {
          allOrders = fetchedOrders.map((order) {
            return {
              'orderId': order['orderId'] ?? '',
              'products': (order['products'] as List).map((product) {
                return {
                  'images': product['images'] ?? 'N/A',
                  'brand': product['brand'] ?? 'N/A',
                  'serialNumber': product['serialNumber'] ?? 'N/A',
                  'quantity': product['quantity'] ?? 0,
                  'price': product['price'] ?? 0,
                };
              }).toList(),
              'addedAt': order['addedAt'] ?? '',
              'shippingInfo': order['shippingInfo'] ?? {},
              'status': order['status'] ?? '',
              'trackingNumber': order['trackingNumber'] ?? 'Not Available',
              'slip': order['slip'] ?? '',
            };
          }).toList();
          filteredOrders = allOrders;
        });
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  void _filterOrders() {
    if (filterOption == 'Show All') {
      filteredOrders = allOrders;
    } else if (filterOption == 'Show Selected Date') {
      if (selectedDate != null) {
        String formattedDate =
            "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
        filteredOrders = allOrders
            .where((order) => order['addedAt'].startsWith(formattedDate))
            .toList();
      } else {
        filteredOrders = allOrders;
      }
    }
  }

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.grey,
            onPrimary: Colors.white, 
            onSurface: Colors.amber, 
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? Container(),
        ),
      );
    },
  );

  if (picked != null && picked != selectedDate) {
    setState(() {
      selectedDate = picked;
      filterOption = 'Show Selected Date';
      _filterOrders();
    });
  }
}

  Future<void> updateOrderStatus(String orderId, String status) async {
    var url = Uri.parse('http://localhost:3000/orders/$orderId');
    try {
      final response = await http.put(
        url,
        body: json.encode({'status': status}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Order status updated successfully');
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Order',
      drawer: AdminDrawer(),
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildDateFilter(),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildOrderList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Orders',
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
              labelText: 'ค้นหาคำสั่งซื้อ (Order ID)',
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

Widget _buildDateFilter() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        width: 250,
        child: DropdownButtonFormField<String>(
          value: filterOption,
          items: <String>['Show All', 'Show Selected Date']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              filterOption = newValue!;
              _filterOrders();
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ),
          dropdownColor: Colors.white,
          icon: Icon(
            FontAwesomeIcons.chevronDown,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
      SizedBox(width: 20),
      ElevatedButton.icon(
        onPressed: () => _selectDate(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: Icon(
          FontAwesomeIcons.calendarAlt, 
          color: Colors.white,
        ),
        label: Text(
          'เลือกวัน',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  );
}

  Widget _buildOrderList() {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView(
        children: filteredOrders
            .where((order) => order['orderId'].toString().contains(searchQuery))
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          'Order ID: ${order['orderId'] ?? 'N/A'}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 0, 51, 102),
          ),
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
                _buildProductsSection(order),
                const SizedBox(height: 16),
                _buildOrderDetails(order),
                const SizedBox(height: 24),
                _buildTrackingSection(order),
                const SizedBox(height: 16),
                _buildSlipImage(order),
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
              borderRadius: BorderRadius.circular(12),
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
                SizedBox(width: 16),
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
                      Text(
                        'price: ${product['price'] ?? 0}',
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
                FaIcon(FontAwesomeIcons.calendarAlt,
                    color: Colors.indigo[900], size: 24),
                SizedBox(width: 8),
                Text(
                  'Added At: ${order['addedAt'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.truckMoving,
                    color: Colors.indigo[900], size: 24),
                SizedBox(width: 8),
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
                FaIcon(FontAwesomeIcons.infoCircle,
                    color: Colors.indigo[900], size: 24),
                SizedBox(width: 8),
                Text(
                  'Status: ${order['status'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingSection(Map<String, dynamic> order) {
    bool hasTracking =
        order['trackingNumber'] != null && order['trackingNumber'].isNotEmpty;

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
                FaIcon(FontAwesomeIcons.truck,
                    color: Colors.indigo[900], size: 24),
                SizedBox(width: 8),
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
                  FaIcon(FontAwesomeIcons.barcode,
                      color: Colors.green, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Tracking Number: ${order['trackingNumber']}',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ],
              )
            else
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.exclamationTriangle,
                      color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'No Tracking Number',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ],
              ),
            const SizedBox(height: 20),
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
  }

  Widget _buildSlipImage(Map<String, dynamic> order) {
    if (order['slip'] == null || order['slip'].isEmpty) {
      return Text(
        'No slip image provided.',
        style: TextStyle(fontSize: 16, color: Colors.red),
      );
    }
    try {
      Uint8List slipImage = base64Decode(order['slip']);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Slip Image:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _showFullImageDialog(context, slipImage);
            },
            child: Center(
              child: Image.memory(
                slipImage,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Text('Error loading slip image');
                },
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Text(
        'Error decoding slip image: $e',
        style: TextStyle(fontSize: 16, color: Colors.red),
      );
    }
  }

  void _showFullImageDialog(BuildContext context, Uint8List image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.memory(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Error loading slip image'));
                      },
                    ),
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
          ),
        );
      },
    );
  }
}
