import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:html' as html; 
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:html' as html;
import 'package:flutter/rendering.dart'; 
import 'dart:html' as html if (dart.library.html) 'dart:html';


Future<void> requestPermission() async {
  await Permission.storage.request();
}

class ReceiptDialog extends StatelessWidget {
  final Map<String, dynamic> orderData;

  ReceiptDialog({required this.orderData});
  
void drawText(Canvas canvas, TextStyle textStyle, String text, Offset offset, BuildContext context) {
  final textSpan = TextSpan(text: text, style: textStyle);

  final textDirection = Directionality.of(context);

  final textPainter = TextPainter(
    text: textSpan,
    textDirection: textDirection, 
  );
  
  textPainter.layout();
  textPainter.paint(canvas, offset);
}


Future<void> downloadReceipt(BuildContext context, Map<String, dynamic> orderData) async {
  try {
    final receiptImage = await createReceiptImage(context, orderData);
    final byteData = await receiptImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final pngBytes = byteData.buffer.asUint8List();
      final blob = html.Blob([pngBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'receipt.png')
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt downloaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create receipt image.')),
      );
    }
  } catch (e) {
    print('Error occurred: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to download receipt: $e')),
    );
  }
}

Future<ui.Image> createReceiptImage(BuildContext context, Map<String, dynamic> orderData) async {
  final recorder = ui.PictureRecorder();
  const double canvasWidth = 500;
  const double canvasHeight = 500; 
  double yOffset = 20.0; 
  final textStyle = TextStyle(color: Colors.black, fontSize: 16); // เพิ่มขนาดฟอนต์หลัก
  final lineHeight = 32.0; // เพิ่มความสูงระหว่างบรรทัด
  final titleStyle = textStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold); // เพิ่มขนาดฟอนต์ของหัวข้อหลัก
  final headerStyle = textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20); // เพิ่มขนาดฟอนต์ของหัวข้อย่อย
  
  final NumberFormat currencyFormat = NumberFormat("#,##0", "th_TH");

  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth, canvasHeight));
  canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth, canvasHeight), Paint()..color = Colors.white);

  drawText(canvas, titleStyle, 'ใบสั่งซื้อสินค้า', Offset((canvasWidth - 300) / 2, yOffset), context);
  yOffset += 40; 

  double tableWidth = canvasWidth - 40; 

  void drawSection(String title, List<String> rows) {
    drawText(canvas, headerStyle, title, Offset(20, yOffset), context);
    yOffset += lineHeight;

    for (var row in rows) {
      drawText(canvas, textStyle, row, Offset(20, yOffset), context);
      yOffset += lineHeight; 
    }

    canvas.drawLine(Offset(15, yOffset), Offset(15 + tableWidth, yOffset), Paint()..color = Colors.grey[400]!);
    yOffset += 10; 
  }

  List<String> products = [];
  if (orderData['products'] != null && orderData['products'].isNotEmpty) {
    for (var product in orderData['products']) {
      String formattedPrice = currencyFormat.format(product['price'] ?? 0);
      products.add('Brand: ${product['brand'] ?? 'N/A'}, Price: ฿$formattedPrice, Quantity: ${product['quantity'] ?? 'N/A'}');
    }
  } else {
    products.add('No products available');
  }
  drawSection('Products:', products);

  List<String> shippingInfo = [
    'Name: ${orderData['shippingInfo']['name'] ?? 'N/A'}',
    'Email: ${orderData['shippingInfo']['email'] ?? 'N/A'}',
    'Phone: ${orderData['shippingInfo']['phone'] ?? 'N/A'}',
    'Address: ${orderData['shippingInfo']['address'] ?? 'N/A'}',
    'Province: ${orderData['shippingInfo']['province'] ?? 'N/A'}',
    'District: ${orderData['shippingInfo']['district'] ?? 'N/A'}',
    'Tambon: ${orderData['shippingInfo']['tambon'] ?? 'N/A'}',
    'Postal Code: ${orderData['shippingInfo']['postalCodemain'] ?? 'N/A'}', 
  ];
  drawSection('Shipping Info:', shippingInfo);

  drawText(
    canvas, 
    textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold), 
    'Luxehouse', 
    Offset((canvasWidth - 100) / 2, canvasHeight - 60),
    context
  );

  final picture = recorder.endRecording();
  return await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
}


Future<ui.Image> decodeBase64Image(String base64String) async {
  final Uint8List bytes = base64.decode(base64String);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

  Widget _buildProductCard() {
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: 'th_TH',
      name: '฿',
    );

  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          ...orderData['products'].map<Widget>((product) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Brand: ${product['brand'] ?? 'N/A'}'),
                        Text('Serial: ${product['serialNumber'] ?? 'N/A'}'),
                        Text('Price: ${NumberFormat.simpleCurrency(locale: 'th_TH', name: '฿').format(product['price'])}'),
                        Text('Quantity: ${product['quantity'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}

Widget _buildShippingInfoCard(Map<String, dynamic> orderData) {
  if (orderData == null || orderData.isEmpty) {
    return Text("No shipping information available.");
  }

  String trackingNumber = orderData['trackingNumber'] ?? 'N/A';
  String addedAt = orderData['addedAt'] != null 
      ? DateFormat('dd MMMM yyyy HH:mm:ss', 'th_TH').format(DateTime.parse(orderData['addedAt']))
      : 'N/A';

  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shipping Info', style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          Text('Name: ${orderData['shippingInfo']?['name'] ?? 'N/A'}'),
          Text('Email: ${orderData['shippingInfo']?['email'] ?? 'N/A'}'),
          Text('Phone: ${orderData['shippingInfo']?['phone'] ?? 'N/A'}'),
          Text('Address: ${orderData['shippingInfo']?['address'] ?? 'N/A'}'),
          Text('Province: ${orderData['shippingInfo']?['province'] ?? 'N/A'}'),
          Text('District: ${orderData['shippingInfo']?['district'] ?? 'N/A'}'),
          Text('Tambon: ${orderData['shippingInfo']?['tambon'] ?? 'N/A'}'),
          Text('Postal Code: ${orderData['shippingInfo']?['postalCodemain'] ?? 'N/A'}'),
        ],
      ),
    ),
  );
}


  Widget _buildSlipCard(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slip Image:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        child: Image.memory(
                          base64Decode(orderData['slip']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(orderData['slip']),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildActionButtons(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false), 
        child: Text(
          'Cancel',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ),
      SizedBox(width: 10),
      ElevatedButton(
        onPressed: () => downloadReceipt(context, orderData),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[700],
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        ),
        child: Text(
          'Download',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(true); 
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 0, 51, 102),
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
        ),
        child: Text(
          'Confirm',
          style: TextStyle(
            fontSize: 18, 
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),),
      child: ClipRRect( 
      borderRadius: BorderRadius.circular(20), 
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, 
        color: const Color.fromARGB(255, 238, 242, 249),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Order Receipt',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                _buildProductCard(),
                SizedBox(height: 12),
                _buildShippingInfoCard(orderData),
                SizedBox(height: 12),
                if (orderData['slip'] != null) _buildSlipCard(context),
                SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }
}
