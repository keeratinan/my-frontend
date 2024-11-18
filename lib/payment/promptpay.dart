import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode/barcode.dart';
import 'package:my_luxe_house/screens/base_screen.dart';
import 'package:my_luxe_house/shipping/shipping.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';  

class PromptPayScreen extends StatefulWidget {
  final double totalAmount;
  String promptPayId = '0950670987'; 

  PromptPayScreen({required this.totalAmount});

  @override
  _PromptPayScreenState createState() => _PromptPayScreenState();
}

class _PromptPayScreenState extends State<PromptPayScreen> {
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

 @override
Widget build(BuildContext context) {
  String promptPayData = _generatePromptPayData(widget.promptPayId, widget.totalAmount);
  var formatter = NumberFormat('#,###');
  final qrCode = Barcode.qrCode();
  final qrSvg = qrCode.toSvg(
    promptPayData,
    width: 200,
    height: 200,
  );
  return BaseScreen(
    title: 'PromptPay',
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
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'PromptPay',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 200,
                      child: SvgPicture.string(
                        qrSvg,
                        width: 200,
                        height: 200,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Total Amount: ${formatter.format(widget.totalAmount)} ฿',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildImageUpload(),
                    SizedBox(height: 16),
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
                              _showPaymentSuccessDialog(context);
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

String _generatePromptPayData(String promptPayId, double amount) {
  final String amountFormatted = amount.toStringAsFixed(2).replaceAll('.', ''); 
  return '00020101021129370016A00000067701011101130066${widget.promptPayId}5802TH53037646304$amountFormatted'; 
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

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Payment Successful'),
          content: Text('Payment has been successfully completed.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShippingScreen(customerId: '', orderData: {}),
                  ),
                );
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
}
