import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_luxe_house/screens/base_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ShippingScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String customerId;

  const ShippingScreen({required this.orderData, required this.customerId});

  @override
  _ShippingScreenState createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> toShipOrders = [];
  List<Map<String, dynamic>> toReceiveOrders = [];
  List<Map<String, dynamic>> completedOrders = [];
  List<Map<String, dynamic>> claimedOrders = [];
  List<Uint8List> _selectedImages = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            'orderId': order['_id'],
            'trackingNumber': order['trackingNumber'],
            'products': order['products'],
            'addedAt': order['addedAt'],
            'shippingInfo': order['shippingInfo'],
            'status': order['status'],
          };
        }).toList();
        
        toShipOrders = allOrders
            .where((order) => order['status'] == 'pending')
            .toList();
        toReceiveOrders = allOrders
            .where((order) => order['status'] == 'shipping')
            .toList();
        completedOrders = allOrders
            .where((order) =>
                order['status'] == 'completed' || 
                order['status'] == 'received')
            .toList();
        claimedOrders = allOrders
            .where((order) => order['status'] == 'claimed')  
            .toList();
      });
    } else {
      throw Exception('Failed to load orders');
    }
  } catch (e) {
    print('Error fetching orders: $e');
  }
}

  Future<void> markOrderReceived(String orderId) async {
    var url = Uri.parse('http://localhost:3000/orders/$orderId/received');
    try {
      final response = await http.patch(
        url,
        body: json.encode({'status': 'received'}),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          var receivedOrder =
          toShipOrders.firstWhere((order) => order['orderId'] == orderId);
          toShipOrders.remove(receivedOrder);
          receivedOrder['status'] = 'completed';
          completedOrders.add(receivedOrder);
        });
        print('Order $orderId marked as received');
        _tabController.animateTo(1);
      } else {
        throw Exception('Failed to mark order as received: ${response.body}');
      }
    } catch (e) {
      print('Error marking order as received: $e');
    }
  }

 Future<void> claimProduct(Map<String, dynamic> order) async {
  final currencyFormat = NumberFormat('#,###.00', 'en_US');
  TextEditingController noteController = TextEditingController();
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
            'รายละเอียดการเคลมสินค้า',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextInfo('Order ID', order['orderId'] ?? 'N/A'),
              _buildTextInfo('Tracking Number', order['trackingNumber'] ?? 'N/A'),
              if (order['products'] != null && order['products'].isNotEmpty) ...[
                for (var product in order['products']) ...[
                  _buildTextInfo('Brand', product['brand'] ?? 'Unknown'),
                  _buildTextInfo('Serial Number', product['serialNumber'] ?? 'N/A'),
                  _buildTextInfo('Quantity', product['quantity']?.toString() ?? '0'),
                  _buildTextInfo('Price', '${currencyFormat.format(product['price'] ?? 0.00)} ฿'),
                  Divider(color: Colors.grey[300]),
                ],
              ] else ...[
                Text('ไม่มีผลิตภัณฑ์ในคำสั่งซื้อนี้', style: TextStyle(color: Colors.grey[700])),
              ],
              SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'หมายเหตุการเคลมสินค้า',
                  labelStyle: TextStyle(color: Colors.indigo[900]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.indigo[900]!,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildImageUpload(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteController.text.isEmpty || _selectedImages.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('กรุณาใส่หมายเหตุและเลือกรูปภาพ')),
                );
                return;
              }
              String claimId = DateTime.now().millisecondsSinceEpoch.toString();
              var claimResponse = await http.post(
                Uri.parse('http://localhost:3000/claims'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'claimId': claimId,
                  'orderId': order['orderId'],
                  'product': order['products'],
                  'note': noteController.text,
                  'images': _selectedImages.map((image) => base64Encode(image)).toList(),
                }),
              );

              if (claimResponse.statusCode == 200) {
                var updateResponse = await http.patch(
                  Uri.parse('http://localhost:3000/orders/${order['orderId']}/claim'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'status': 'claimed'}),
                );

                if (updateResponse.statusCode == 200) {
                  setState(() {
                    completedOrders.remove(order);  
                    order['status'] = 'claimed'; 
                    claimedOrders.add(order);   
                  });
                  Navigator.of(context).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('การเคลมสินค้าสำเร็จ')),
                  );
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('การอัปเดตสถานะไม่สำเร็จ')),
                  );
                }
              } else {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('การเคลมสินค้าไม่สำเร็จ')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[900], 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('ส่งการเคลม', style: TextStyle(color: Colors.white)),
          )
        ],
      );
    },
  );
}

Future<void> _pickImage() async {
  final pickedFiles = await ImagePicker().pickMultiImage();
  if (pickedFiles != null) {
    List<Uint8List> images = [];
    for (var file in pickedFiles) {
      Uint8List imageBytes = await file.readAsBytes();
      images.add(imageBytes);
    }
    setState(() {
      _selectedImages = images;
    });
    print('Images selected: ${_selectedImages.length}'); 
  } else {
    print('No image selected.');
  }
}

Widget _buildImageUpload() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        'Upload Images *',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () async {
          final ImagePicker _picker = ImagePicker();
          final pickedFiles = await _picker.pickMultiImage();

          if (pickedFiles != null) {
            List<Uint8List> images = await Future.wait(
              pickedFiles.map((file) => file.readAsBytes()),
            );

            setState(() {
              _selectedImages = images; 
            });
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey.shade400,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text('Select Images'),
      ),
      SizedBox(height: 10),
      _selectedImages.isNotEmpty
          ? Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _showFullImageDialog(context, _selectedImages[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : Text('Only 1 image can be uploaded'),
    ],
  );
}


  void _showFullImageDialog(BuildContext context, Uint8List image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.all(10),
            child: Image.memory(image, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  return BaseScreen(
    title: 'Orders',
    body: Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.indigo[900], 
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: 'ที่ต้องได้รับ'),
              Tab(text: 'สำเร็จแล้ว'),
              Tab(text: 'เคลมสินค้า'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildOrderSection(toShipOrders, showReceivedButton: true, showClaimButton: false),
                buildOrderSection(completedOrders, showReceivedButton: false, showClaimButton: true),
                buildOrderSection(claimedOrders, showReceivedButton: false, showClaimButton: false),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildOrderSection(List<Map<String, dynamic>> orders,
    {required bool showReceivedButton, required bool showClaimButton}) {
  return ListView.builder(
    itemCount: orders.length,
    itemBuilder: (context, index) {
      final order = orders[index];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.indigo[900]!.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Number: ${order['trackingNumber']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(height: 12),
                for (var product in order['products'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product['images'] != null &&
                            product['images'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                product['images'][0],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return FaIcon(
                                    FontAwesomeIcons.image,
                                    color: Colors.grey,
                                    size: 80,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: FaIcon(
                              FontAwesomeIcons.image,
                              color: Colors.grey[400],
                              size: 80,
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Brand: ${product['brand']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.indigo[900],
                                ),
                              ),
                              Text(
                                'Serial Number: ${product['serialNumber']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Quantity: ${product['quantity']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Price: ${NumberFormat('#,###').format(product['price'])} ฿',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Divider(color: Colors.grey[300], thickness: 1.5),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${order['addedAt']}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          if (showReceivedButton)
                            ElevatedButton(
                              onPressed: () {
                                markOrderReceived(order['orderId']);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.indigo[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.checkCircle,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Received',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          if (showClaimButton) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                claimProduct(order);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.exclamationTriangle,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Claim',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget _buildTextField(TextEditingController controller, String label) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.indigo[900]), 
      filled: true,
      fillColor: Colors.white, 
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[400]!), 
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.indigo[900]!), 
      ),
    ),
  );
}

Widget _buildTextInfo(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.indigo[900], 
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600], 
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}}
