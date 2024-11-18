import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'base_screen.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PriceInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###'); 

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final int selectionIndex = newValue.selection.end;
    final int originalLength = newValue.text.length;
    String newText = _formatter.format(int.parse(newValue.text.replaceAll(',', '')));
    final int newLength = newText.length;
    final int newSelectionIndex = selectionIndex + (newLength - originalLength);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}

class SellTradeScreen extends StatefulWidget {
  @override
  _SellTradeScreenState createState() => _SellTradeScreenState();
}

class _SellTradeScreenState extends State<SellTradeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? brandModel = 'All';
  String? year = '2000';
  String? sellOrTrade = 'Sell';
  List<XFile>? _selectedImages;

  final List<String> brands = [
    'Tommy Hilfiger',
    'Marc Jacobs',
    'Michael Kors',
    'Guess',
    'Emporio Armani',
    'Fossil',
    'Coach',
    'Seiko',
    'Vivienne Westwood',
    'Burberry',
    'Versace',
    'Gucci',
    'Tag Heuer',
    'Omega',
  ];

final List<String> years = List<String>.generate(2024 - 1900, (i) => (1900 + i).toString());

Future<void> _pickImage() async {
  final pickedFiles = await ImagePicker().pickMultiImage();

  if (pickedFiles != null) {
    List<Uint8List> images = [];
    for (var file in pickedFiles) {
      Uint8List imageBytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      img.Image resizedImage = img.copyResize(originalImage!, width: 800);
      Uint8List resizedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage));
      images.add(resizedImageBytes);
    }
    setState(() {
      _selectedImages = images.cast<XFile>();
    });
  } else {
    print('No image selected.');
  }
}

Future<void> _submitDataToAPI(String customerId, String name, String email, String phone, String brand, String year, String type, List<XFile>? images) async {
  final url = Uri.parse('http://localhost:3000/trade');  
  try {
    List<String> base64Images = [];
    if (images != null) {
      for (XFile image in images) {
        base64Images.add(base64Encode(await image.readAsBytes()));
      }
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerId': customerId,
        'name': name,
        'email': email,
        'phone': phone,
        'brand': brand,
        'year': year,
        'type': type,
        'addedAt': DateTime.now().toIso8601String(),
        'images': base64Images,
      }),
    );
    if (response.statusCode == 200) {
      _showSuccessDialog(); 
    } else {
      throw Exception('Failed to send data');
    }
  } catch (e) {
    print('Error: $e');
    _showErrorDialog(e.toString());
  }
}


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();

void _submitForm() {
  if (_selectedImages == null || _selectedImages!.isEmpty) {
    _showImageRequiredDialog();
  } else if (_formKey.currentState?.validate() ?? false) {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String customerId = '64bfa6c72e7a914a5c3b543c';
    _submitDataToAPI(customerId, name, email, phone, brandModel!, year!, sellOrTrade!, _selectedImages);
  }
}

TextFormField _buildTextField({
  required String labelText,
  required String validatorText,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  bool isPriceField = false, 
  bool isPhoneField = false, 
  bool isLimitedTextField = false,
  bool isEmailField = false,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 16),
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade100,
    ),
    keyboardType: isEmailField ? TextInputType.emailAddress : (isPhoneField ? TextInputType.phone : (isPriceField ? TextInputType.number : keyboardType)), 
    inputFormatters: isPhoneField
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ]
        : (isPriceField
            ? [
                FilteringTextInputFormatter.digitsOnly,
                PriceInputFormatter(),
              ]
            : (isLimitedTextField
                ? [
                    LengthLimitingTextInputFormatter(30),
                  ]
                : [])),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return validatorText;
      }
      if (isEmailField) {
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
      }
      return null;
    },
  );
}

  void _showImageRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Image Required'),
          content: Text('Please upload at least one image before submitting.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Success'),
        content: Text('Your submission has been sent successfully.'),
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


void _showErrorDialog(String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Error'),
        content: Text('Error occurred: $errorMessage'),
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

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Sell/Trade',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Container(
                      width: 500,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'SELL/TRADE',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              labelText: 'Name',
                              validatorText: 'Please enter your name',
                              controller: _nameController,
                              isLimitedTextField: true,
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    labelText: 'Email',
                                    validatorText: 'Please enter your email',
                                    controller: _emailController, 
                                    isEmailField: true,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField(
                                    labelText: 'Phone',
                                    validatorText: 'Please enter your phone number',
                                    controller: _phoneController,
                                    isPhoneField: true, 
                                  )
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              'WATCH INFO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownButton(
                                    labelText: 'Brand & Model',
                                    value: brandModel,
                                    items: brands,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        brandModel = newValue;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _buildDropdownButton(
                                    labelText: 'Year',
                                    value: year,
                                    items: years,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        year = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildImageUpload(),
                            SizedBox(height: 10),
                            _buildTextField(
                              labelText: 'Expected Price',
                              keyboardType: TextInputType.number,
                              validatorText: 'Please enter the expected price',
                              controller: TextEditingController(),
                              isPriceField: true, 
                            ),
                            SizedBox(height: 10),
                            _buildTextField(
                              labelText: 'Condition',
                              validatorText: 'Please describe the condition',
                              controller: _conditionController,
                              isLimitedTextField: true, 
                            ),
                            SizedBox(height: 10),
                            _buildRadioButtons(),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/'); 
                                    },
                                    child: Text('Back Home', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                  onPressed: _submitForm,
                                  child: Text('Submit', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    backgroundColor: Colors.white,
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
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String labelText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      value: items.contains(value) ? value : null,  
      icon: Icon(FontAwesomeIcons.chevronDown, size: 20, color: Colors.grey),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
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
          _selectedImages = await _picker.pickMultiImage(); 
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.grey.shade400, disabledForegroundColor: Colors.grey.withOpacity(0.38), disabledBackgroundColor: Colors.grey.withOpacity(0.12),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text('Select Images'),
      ),
      SizedBox(height: 10),
      _selectedImages != null
          ? Text('${_selectedImages!.length} images selected')
          : Text('No images selected'),
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
            child: Image.memory(
              image,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioButtons() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Sell', style: TextStyle(fontSize: 16)),
            value: 'Sell',
            groupValue: sellOrTrade,
            onChanged: (String? value) {
              setState(() {
                sellOrTrade = value;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Trade', style: TextStyle(fontSize: 16)),
            value: 'Trade',
            groupValue: sellOrTrade,
            onChanged: (String? value) {
              setState(() {
                sellOrTrade = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
