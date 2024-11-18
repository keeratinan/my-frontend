import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_luxe_house/shipping/shipping.dart';

class ReceiptDialog2 extends StatelessWidget {
  final Map<String, dynamic> orderData;

  ReceiptDialog2({Key? key, required this.orderData}) : super(key: key);

  void drawText(Canvas canvas, TextStyle textStyle, String text, Offset offset, BuildContext context) {
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: Directionality.of(context));
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  Future<void> downloadReceipt(BuildContext context) async {
    try {
      final receiptImage = await createReceiptImage(context);
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

 Future<ui.Image> createReceiptImage(BuildContext context) async {
    final recorder = ui.PictureRecorder();
    const double canvasWidth = 600;
    const double canvasHeight = 800;
    double yOffset = 20.0;
    final textStyle = TextStyle(color: Colors.black, fontSize: 14);
    final paint = Paint()..color = Colors.white;
    final borderPaint = Paint()..color = Colors.black;
    final lineHeight = 24.0;
    final titleStyle = textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold);
    final headerStyle = textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16);
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth, canvasHeight));
    canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth, canvasHeight), paint);

    drawText(canvas, titleStyle, 'ใบสั่งซื้อสินค้า', Offset((canvasWidth - 300) / 2, yOffset), context);
    yOffset += 30;

    double tableWidth = canvasWidth - 40;

    void drawTable(String title, List<String> rows) {
      canvas.drawRect(Rect.fromLTWH(15, yOffset, tableWidth, lineHeight * (rows.length + 1)), Paint()..color = Colors.grey[300]!);
      drawText(canvas, headerStyle, title, Offset(20, yOffset + 5), context);
      yOffset += lineHeight;
      for (var row in rows) {
        drawText(canvas, textStyle, row, Offset(20, yOffset + 5), context);
        yOffset += lineHeight;
      }
      canvas.drawLine(Offset(15, yOffset), Offset(15 + tableWidth, yOffset), borderPaint);
      yOffset += 10;
    }

    drawTable('Order ID:', ['${orderData['orderId'] ?? 'N/A'}']);

    List<String> products = [];
    if (orderData['products'] != null && orderData['products'].isNotEmpty) {
      for (var product in orderData['products']) {
        products.add('Brand: ${product['brand'] ?? 'N/A'}, Price: ${product['price']?.toString() ?? 'N/A'}, Quantity: ${product['quantity']?.toString() ?? 'N/A'}');
      }
    } else {
      products.add('No products available');
    }
    drawTable('Products:', products);

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
    drawTable('Shipping Info:', shippingInfo);

    if (orderData['slip'] != null) {
      final slipImage = await decodeBase64Image(orderData['slip'] ?? '');
      final slipWidth = slipImage.width.toDouble();
      final slipHeight = slipImage.height.toDouble();

      final maxWidth = canvasWidth - 60;
      final scaleFactor = maxWidth / slipWidth;
      final scaledSlipHeight = slipHeight * scaleFactor * 0.6;
      final slipOffset = Offset((canvasWidth - maxWidth) / 2, yOffset);

      canvas.drawImageRect(
        slipImage,
        Rect.fromLTWH(0, 0, slipWidth, slipHeight),
        Rect.fromLTWH(slipOffset.dx, slipOffset.dy, maxWidth, scaledSlipHeight),
        Paint(),
      );

      yOffset += scaledSlipHeight + 20; 
    }

    final picture = recorder.endRecording();
    return picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
  }

Future<ui.Image> decodeBase64Image(String base64String) async {
    final Uint8List bytes = base64.decode(base64String);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildOrderCard(BuildContext context, String label, String value) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
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
                   product['images'] != 'N/A' && product['images'].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['images'][0],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, size: 40);
                          },
                        ),
                      )
                    : FaIcon(
                        FontAwesomeIcons.bagShopping,
                        color: Colors.indigo[900],
                        size: 30,
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Brand: ${product['brand']}'),
                          Text('Serial: ${product['serialNumber']}'),
                          Text(
                              'Price: ${currencyFormat.format(product['price'])}'),
                          Text('Quantity: ${product['quantity']}'),
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

  Widget _buildShippingInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping Info',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Divider(),
            Text('Name: ${orderData['shippingInfo']['name']}'),
            Text('Email: ${orderData['shippingInfo']['email']}'),
            Text('Phone: ${orderData['shippingInfo']['phone']}'),
            Text('Address: ${orderData['shippingInfo']['address']}'),
            Text('Province: ${orderData['shippingInfo']['province']}'),
            Text('District: ${orderData['shippingInfo']['district']}'),
            Text('Tambon: ${orderData['shippingInfo']['tambon']}'),
            Text('Postal Code: ${orderData['shippingInfo']['postalCodemain']}'),
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
          child: Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => downloadReceipt(context), 
          style: ElevatedButton.styleFrom(
            backgroundColor:  Colors.amber[700],
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ShippingScreen(
                  orderData: orderData,
                  customerId: '',
                ),
              ),
            );
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
                SizedBox(height: 16),
                _buildOrderCard(context, 'Order ID:', orderData['orderId']),
                SizedBox(height: 12),
                _buildProductCard(),
                SizedBox(height: 12),
                _buildShippingInfoCard(),
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
