/*(CheckoutScreen_Old)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../screens/base_screen.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> product;

  CheckoutScreen({required this.products, required this.product});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Uint8List? _selectedPromptPayImage;
  Uint8List? _selectedBankTransferImage;
  Uint8List? _selectedSlipImage;

  double productPrice = 1500.00; 
  double deliveryFee = 100.00; 
  late double totalAmount = productPrice + deliveryFee; 
  int quantity = 1;
  Map<String, int> quantities = {};

  List<String> provinces = [];
  List<Map<String, dynamic>> allDistricts = [];
  List<String> filteredDistricts = [];
  List<Map<String, dynamic>> allTambons = [];
  List<String> filteredTambons = [];
  List<Map<String, dynamic>> allPostalCodes = [];
  List<String> filteredPostalCodes = [];

  String? customerId;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedTambon;
  String selectedPostalCodemain = '';
  String? _selectedPaymentMethod = 'Bank Transfer';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImageForPromptPay(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedPromptPayImage = bytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PromptPay Image selected successfully!')),
      );
    }
  }

  Future<void> _pickImageForBankTransfer(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedBankTransferImage = bytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('BankTransfer Image selected successfully!')),
      );
    }
  }

Future<void> _pickSlipImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedSlipImage = bytes; 
      });
      print('Slip image selected: ${pickedFile.name}, bytes length: ${bytes.length}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  } catch (error) {
    print('Error picking image: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error picking image: $error')),
    );
  }
}

  @override
  void initState() {
    super.initState();
    totalAmount = double.tryParse(
          widget.product['Price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        ) ??
        0.0;
    fetchDataFromMongoDB();
  }

  Future<void> fetchDataFromMongoDB() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/locations'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> locations = data['locations'];
        List<dynamic> uniqueDistricts = data['uniqueDistricts'];

        setState(() {
          provinces = locations
              .map((item) => item['ProvinceThai'].toString())
              .toSet()
              .toList();
          allDistricts = uniqueDistricts
              .map((district) => {
                    'ProvinceThai': district['ProvinceThai'].toString(),
                    'DistrictThai': district['DistrictThai'].toString()
                  })
              .toList();

          allTambons = locations
              .map((item) => {
                    'DistrictThai': item['DistrictThai'].toString(),
                    'TambonThai': item['TambonThai'].toString()
                  })
              .toList();

          allPostalCodes = locations
              .map((item) => {
                    'TambonThai': item['TambonThai'].toString(),
                    'PostCodeMain': item['PostCodeMain'].toString()
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void onProvinceSelected(String? value) {
    setState(() {
      selectedProvince = value;

      filteredDistricts = allDistricts
          .where((district) => district['ProvinceThai'] == value)
          .map((district) => district['DistrictThai'].toString())
          .toList();

      selectedDistrict = null;
      filteredTambons.clear();
      filteredPostalCodes.clear();
    });
  }

  void onDistrictSelected(String? value) {
    setState(() {
      selectedDistrict = value;
      filteredTambons = allTambons
          .where((tambon) => tambon['DistrictThai'] == value)
          .map((tambon) => tambon['TambonThai'].toString())
          .toList();

      selectedTambon = null;
      filteredPostalCodes.clear();
    });
  }

  void onTambonSelected(String? value) {
    setState(() {
      selectedTambon = value;
      filteredPostalCodes = allPostalCodes
          .where((postalCode) => postalCode['TambonThai'] == value)
          .map((postalCode) => postalCode['PostCodeMain'].toString())
          .toList();
    });
  }

bool _isLoading = false;
File? slipImage;

Future<void> _submitOrderDataToMongoDB() async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
  });

  final orderId = Uuid().v4();
  final productBrand = widget.product['Brand'] ?? '';
  final productSerialNumber = widget.product['Serial_number'] ?? '';
  final productPriceString = widget.product['Price'] ?? '0';
  final productPrice = double.tryParse(
    productPriceString.replaceAll(RegExp(r'[^0-9.]'), '')
  ) ?? 0;

  if (productBrand.isEmpty ||
      productSerialNumber.isEmpty ||
      productPrice <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product information is incomplete.')),
    );
    setState(() {
      _isLoading = false;
    });
    return;
  }

  if (nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneController.text.isEmpty ||
      addressController.text.isEmpty ||
      selectedPostalCodemain.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shipping information is incomplete.')),
    );
    setState(() {
      _isLoading = false;
    });
    return;
  }

String? slipBase64;
if (_selectedSlipImage != null) {
  slipBase64 = base64Encode(_selectedSlipImage!);
  print('Encoded slip image: $slipBase64'); 
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select a slip image.')),
  );
  setState(() {
    _isLoading = false;
  });
  return;
}

  Map<String, dynamic> orderData = {
    'orderId': orderId,
    'products': [
      {
        'brand': productBrand,
        'serialNumber': productSerialNumber,
        'price': productPrice,
        'quantity': quantity,
        'images': widget.product['Images'],
      }
    ],
    'shippingInfo': {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'province': selectedProvince,
      'district': selectedDistrict,
      'tambon': selectedTambon,
      'postalCodemain': selectedPostalCodemain,
    },
    'slip': slipBase64, 
  };

    print('Order Data with Slip: $orderData');

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(orderData),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      print('Order submitted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/shipping');
    } else {
      print('Failed to submit order: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order: ${response.body}')),
      );
    }
  } catch (error) {
    print('Error submitting order: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting order: $error')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Luxe House',
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(16),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: _buildProductDetails(widget.product),
                  ),
                ),
              ),
              SizedBox(width: 24.0),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShippingInformation(),
                        SizedBox(height: 16.0),
                        _buildSlipImagePreview(context, _selectedSlipImage),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Submitting your order...')),
                                      );
                                      await _submitOrderDataToMongoDB();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Please complete the form.')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isLoading ? Colors.grey : const Color.fromARGB(255, 0, 51, 102), 
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 20.0),
                            ),
                            child: Text(
                              _isLoading ? 'Loading...' : 'Confirm',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(Map<String, dynamic> productData) {
    var formatter = NumberFormat('#,##0');
    double deliveryFee = 100;
    double productPrice = double.tryParse(
          productData['Price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        ) ??
        0;
    String imageUrl = productData['Images'] ?? '';
    if (productData.isEmpty) {
      return Center(
        child: Text('No product details available'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading image');
                    },
                  )
                : Container(
                    width: 140,
                    height: 140,
                    color: Colors.grey,
                    child: Center(
                      child: Text('No Image Available'),
                    ),
                  ),
            SizedBox(width: 24.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['Brand'] ?? 'No Brand',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(
                    productData['Serial_number'] ?? 'No Serial Number',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      Text('Quantity', style: TextStyle(fontSize: 18)),
                      Spacer(),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.minus),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text('$quantity', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.plus),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Product Total Price: ${formatter.format(productPrice * quantity)} ฿',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Delivery Fee: ${formatter.format(deliveryFee)} ฿',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(),
                  SizedBox(height: 24.0),
                  _buildTotalSection(productPrice, deliveryFee),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTotalSection(double productPrice, double deliveryFee) {
    var formatter = NumberFormat('#,##0');
    double totalPrice = (productPrice * quantity) + deliveryFee;
    TextEditingController noteController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.0),
        Text(
          'Total: ${formatter.format(totalPrice)} ฿',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: 16.0),
        Text('Note to Seller'),
        SizedBox(height: 12.0),
        TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Write a note to the seller...',
          ),
        ),
        SizedBox(height: 16.0),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              String note = noteController.text;
              if (note.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note sent: $note')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a note.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 209, 209, 209),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Send Note'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {int maxLength = 30}) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        if (labelText == 'Phone' && value.length != 10) {
          return 'Phone number must be 10 digits';
        }
        if (labelText == 'Email') {
          final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegExp.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        if (value.length > maxLength) {
          return '$labelText cannot exceed $maxLength characters';
        }
        return null;
      },
      keyboardType: labelText == 'Phone'
          ? TextInputType.phone
          : (labelText == 'Email'
              ? TextInputType.emailAddress
              : TextInputType.text),
      inputFormatters:
          labelText == 'Phone' ? [FilteringTextInputFormatter.digitsOnly] : [],
    );
  }

  Widget _buildDropdownField(
      String labelText, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownSearch<String>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.tight,
        menuProps: MenuProps(
          backgroundColor: Colors.white,
        ),
      ),
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
      dropdownButtonProps: DropdownButtonProps(
        icon: FaIcon(FontAwesomeIcons.chevronDown),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildShippingInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Name', nameController, maxLength: 30),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: _buildTextField('Email', emailController, maxLength: 30),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: _buildTextField('Phone', phoneController, maxLength: 10),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: _buildTextField('Address Number', addressController,
                  maxLength: 40),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                  'Province', provinces, onProvinceSelected),
            ),
            SizedBox(width: 16.0),
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                  'District', filteredDistricts, onDistrictSelected),
            ),
            SizedBox(width: 16.0),
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                  'Tambon', filteredTambons, onTambonSelected),
            ),
            SizedBox(width: 16.0),
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                'Postal Code',
                filteredPostalCodes,
                (value) {
                  setState(() {
                    selectedPostalCodemain = value ?? '';
                  });
                  print('Selected Postal Code: $selectedPostalCodemain');
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPaymentMethod,
                items: ['Bank Transfer', 'PromptPay']
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                icon: FaIcon(FontAwesomeIcons.chevronDown),
                dropdownColor: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        if (_selectedPaymentMethod == 'Bank Transfer')
          _buildBankTransferDetails(),
        if (_selectedPaymentMethod == 'PromptPay') _buildPromptPayDetails(),
      ],
    );
  }

  Widget _buildBankTransferDetails() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
        ),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Transfer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/SCB.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Number: 322-260906-0',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Account Name: กีรตินันท์ พุทธายะ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Please check the account number and name carefully.',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptPayDetails() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PromptPay Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4),
                  Text(
                    'Account Name: กีรตินันท์ พุทธายะ',
                      style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      ),
                    ),
                SizedBox(height: 16),
                  Text(
                      'Please check the account number and name carefully.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                SizedBox(height: 16.0),
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/qr_code.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlipImagePreview(BuildContext context, Uint8List? selectedSlipImage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Center(
        child: ElevatedButton(
          onPressed: () => _pickSlipImage(), 
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Text(
            'Choose File',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      const SizedBox(height: 16),
      selectedSlipImage != null
          ? GestureDetector(
              onTap: () {
                _showFullImageDialog(context, selectedSlipImage);
              },
              child: Center(
                child: Image.memory(
                  selectedSlipImage,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : const Text('No slip image selected.'),
    ],
  );
}

  void _showFullImageDialog(BuildContext context, Uint8List image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.memory(image),
        );
      },
    );
  }
} */

/* 

(CheckoutScreen_new) */
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_luxe_house/payment/receiptPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/base_screen.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';


class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> product;

  CheckoutScreen({required this.products, required this.product});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _useSavedShippingInfo = false;
  Uint8List? _selectedPromptPayImage;
  Uint8List? _selectedBankTransferImage;
  Uint8List? _selectedSlipImage;

  double productPrice = 1500.00;
  double deliveryFee = 100.00;
  late double totalAmount = productPrice + deliveryFee;
  int quantity = 1;
  Map<String, int> quantities = {};

  List<String> provinces = [];
  List<Map<String, dynamic>> allDistricts = [];
  List<String> filteredDistricts = [];
  List<Map<String, dynamic>> allTambons = [];
  List<String> filteredTambons = [];
  List<Map<String, dynamic>> allPostalCodes = [];
  List<String> filteredPostalCodes = [];

  String? customerId;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedTambon;
  String selectedPostalCodemain = '';
  String? _selectedPaymentMethod = 'Bank Transfer';

  String? savedName;
  String? savedEmail;
  String? savedPhone;
  String? savedAddress;
  String? savedProvince;
  String? savedDistrict;
  String? savedTambon;
  String? savedPostalCode;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImageForPromptPay(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedPromptPayImage = bytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PromptPay Image selected successfully!')),
      );
    }
  }

  Future<void> _pickImageForBankTransfer(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedBankTransferImage = bytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('BankTransfer Image selected successfully!')),
      );
    }
  }

  Future<void> _pickSlipImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedSlipImage = bytes;
        });
        print(
            'Slip image selected: ${pickedFile.name}, bytes length: ${bytes.length}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (error) {
      print('Error picking image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    totalAmount = double.tryParse(
          widget.product['Price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        ) ??
        0.0;
    fetchDataFromMongoDB();
    fetchUserData();
  }

  Future<void> fetchDataFromMongoDB() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/locations'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> locations = data['locations'];
        List<dynamic> uniqueDistricts = data['uniqueDistricts'];

        setState(() {
          provinces = locations
              .map((item) => item['ProvinceThai'].toString())
              .toSet()
              .toList();
          allDistricts = uniqueDistricts
              .map((district) => {
                    'ProvinceThai': district['ProvinceThai'].toString(),
                    'DistrictThai': district['DistrictThai'].toString()
                  })
              .toList();

          allTambons = locations
              .map((item) => {
                    'DistrictThai': item['DistrictThai'].toString(),
                    'TambonThai': item['TambonThai'].toString()
                  })
              .toList();

          allPostalCodes = locations
              .map((item) => {
                    'TambonThai': item['TambonThai'].toString(),
                    'PostCodeMain': item['PostCodeMain'].toString()
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

void onProvinceSelected(String? value) {
  setState(() {
    selectedProvince = value;

    filteredDistricts = allDistricts
        .where((district) => district['ProvinceThai'] == value)
        .map((district) => district['DistrictThai'].toString())
        .toList();
        
    selectedDistrict = null;
    selectedTambon = null;
    filteredTambons.clear();
    filteredPostalCodes.clear();
  });
}

void onDistrictSelected(String? value) {
  setState(() {
    selectedDistrict = value;

    filteredTambons = allTambons
        .where((tambon) => tambon['DistrictThai'] == value)
        .map((tambon) => tambon['TambonThai'].toString())
        .toList();

    selectedTambon = null;
    filteredPostalCodes.clear();
  });
}

void onTambonSelected(String? value) {
  setState(() {
    selectedTambon = value;

    filteredPostalCodes = allPostalCodes
        .where((postalCode) => postalCode['TambonThai'] == value)
        .map((postalCode) => postalCode['PostCodeMain'].toString())
        .toList();
  });
}

  bool _isLoading = false;
  File? slipImage;
  
Future<void> _submitOrderDataToMongoDB() async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
  });

  if (nameController.text.isEmpty || emailController.text.isEmpty ||
      phoneController.text.isEmpty || addressController.text.isEmpty ||
      selectedProvince == null || selectedDistrict == null ||
      selectedTambon == null || selectedPostalCodemain.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please complete all shipping information.')),
    );
    setState(() {
      _isLoading = false;
    });
    return;
  }

  String? slipBase64;
  if (_selectedSlipImage != null) {
    slipBase64 = base64Encode(_selectedSlipImage!);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a slip image.')),
    );
    setState(() {
      _isLoading = false;
    });
    return;
  }

  Map<String, dynamic> orderData = {
    'orderId': Uuid().v4(),
    'products': [
      {
        'brand': widget.product['Brand'] ?? '',
        'serialNumber': widget.product['Serial_number'] ?? '',
        'price': double.tryParse(widget.product['Price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0,
        'quantity': quantity,
        'images': widget.product['Images'],
      }
    ],
    'shippingInfo': {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'province': selectedProvince,
      'district': selectedDistrict,
      'tambon': selectedTambon,
      'postalCodemain': selectedPostalCodemain,
    },
    'slip': slipBase64,
  };
  
bool confirm = await showDialog(
  context: context,
  builder: (_) => ReceiptDialog(orderData: orderData),
);

if (!confirm) {
  setState(() {
    _isLoading = false;
  });
  return;
}

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/shipping');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order: ${response.body}')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting order: $error')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> fetchUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  if (token != null) {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          savedName = data['username'] ?? '';
          savedEmail = data['email'] ?? '';
          savedPhone = data['phone'] ?? '';
          savedAddress = data['address'] ?? '';
          savedProvince = data['province'] ?? '';
          savedDistrict = data['district'] ?? ''; 
          savedTambon = data['tambon'] ?? ''; 
          savedPostalCode = data['postal_code'] ?? '';

          nameController.text = savedName ?? '';
          emailController.text = savedEmail ?? '';
          phoneController.text = savedPhone ?? '';
          addressController.text = savedAddress ?? '';
          selectedProvince = savedProvince ?? '';
          selectedDistrict = savedDistrict ?? ''; 
          selectedTambon = savedTambon ?? '';
          selectedPostalCodemain = savedPostalCode ?? '';

          onProvinceSelected(selectedProvince);
          onDistrictSelected(selectedDistrict); 
          onTambonSelected(selectedTambon);
        });
      } else {
        print('Failed to load user data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error occurred while fetching user data: $e');
    }
  } else {
    setState(() {
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      addressController.clear();
      selectedProvince = '';
      selectedDistrict = '';
      selectedTambon = '';
      selectedPostalCodemain = '';
    });
    print('Authorization token not found');
  }
}

 @override
Widget build(BuildContext context) {
  return BaseScreen(
    title: 'Luxe House',
    body: Container(
      color: const Color.fromARGB(255, 238, 242, 249),
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                elevation: 4,
                margin: EdgeInsets.all(16),
                color: Colors.white,
                shadowColor: const Color.fromARGB(255, 0, 51, 102),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: _buildProductDetails(widget.product),
                ),
              ),
            ),
            SizedBox(width: 24.0),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShippingInformation(),
                      SizedBox(height: 16.0),
                      _buildSlipImagePreview(context, _selectedSlipImage),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState?.validate() ??
                                      false ||
                                      (nameController.text.isNotEmpty &&
                                          emailController.text.isNotEmpty &&
                                          phoneController.text.isNotEmpty &&
                                          addressController.text.isNotEmpty &&
                                          selectedProvince != null &&
                                          selectedDistrict != null &&
                                          selectedTambon != null &&
                                          selectedPostalCodemain
                                              .isNotEmpty)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Submitting your order...')),
                                    );
                                    await _submitOrderDataToMongoDB();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please complete the required fields.')),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading
                                ? Colors.grey
                                : const Color.fromARGB(255, 0, 51, 102),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 20.0),
                          ),
                          child: Text(
                            _isLoading ? 'Loading...' : 'Confirm',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildProductDetails(Map<String, dynamic> productData) {
    var formatter = NumberFormat('#,##0');
    double deliveryFee = 100;
    double productPrice = double.tryParse(
          productData['Price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        ) ??
        0;
    String imageUrl = productData['Images'] ?? '';
    if (productData.isEmpty) {
      return Center(
        child: Text('No product details available'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading image');
                    },
                  )
                : Container(
                    width: 140,
                    height: 140,
                    color: Colors.grey,
                    child: Center(
                      child: Text('No Image Available'),
                    ),
                  ),
            SizedBox(width: 24.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['Brand'] ?? 'No Brand',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.amber[800]),
                  ),
                  Text(
                    productData['Serial_number'] ?? 'No Serial Number',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      Text('Quantity', style: TextStyle(fontSize: 18)),
                      Spacer(),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.minus),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text('$quantity', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.plus),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Product Total Price: ${formatter.format(productPrice * quantity)} ฿',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Delivery Fee: ${formatter.format(deliveryFee)} ฿',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(),
                  SizedBox(height: 24.0),
                  _buildTotalSection(productPrice, deliveryFee),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTotalSection(double productPrice, double deliveryFee) {
    var formatter = NumberFormat('#,##0');
    double totalPrice = (productPrice * quantity) + deliveryFee;
    TextEditingController noteController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.0),
        Text(
          'Total: ${formatter.format(totalPrice)} ฿',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.amber[800]),
        ),
        SizedBox(height: 16.0),
        Text('Note to Seller'),
        SizedBox(height: 12.0),
        TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Write a note to the seller...',
          ),
        ),
        SizedBox(height: 16.0),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              String note = noteController.text;
              if (note.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note sent: $note')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a note.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 209, 209, 209),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Send Note'),
          ),
        ),
      ],
    );
  }
  
Widget _buildTextField(String labelText, TextEditingController controller,
    {int maxLength = 30}) {
  return TextFormField(
    controller: controller,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
      fillColor: Colors.white, 
      filled: true, 
      counterText: '',
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your $labelText';
      }
      if (labelText == 'Phone' && value.length != 10) {
        return 'Phone number must be 10 digits';
      }
      if (labelText == 'Email') {
        final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegExp.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
      }
      if (value.length > maxLength) {
        return '$labelText cannot exceed $maxLength characters';
      }
      return null;
    },
    keyboardType: labelText == 'Phone'
        ? TextInputType.phone
        : (labelText == 'Email'
            ? TextInputType.emailAddress
            : TextInputType.text),
    inputFormatters:
        labelText == 'Phone' ? [FilteringTextInputFormatter.digitsOnly] : [],
    onChanged: (text) {},
  );
}


Widget _buildDropdownField(
    String labelText,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool required = false,
    String? selectedItem,
}) {
  return DropdownSearch<String>(
    popupProps: PopupProps.menu(
      showSearchBox: true,
      fit: FlexFit.tight,
      menuProps: MenuProps(
        backgroundColor: Colors.white,
      ),
    ),
    items: items,
    selectedItem: selectedItem, 
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
    ),
    dropdownButtonProps: DropdownButtonProps(
      icon: FaIcon(FontAwesomeIcons.chevronDown),
    ),
    onChanged: (value) {
      if (value != null && value.isNotEmpty) { 
        setState(() {
          onChanged(value);
        });
      } else if (required) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$labelText is required')),
        );
      }
    },
  );
}

Widget _buildShippingInformation() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Use previously saved shipping information',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
          Checkbox(
            value: _useSavedShippingInfo,
            onChanged: (bool? value) {
              setState(() {
                _useSavedShippingInfo = value ?? false;
                if (_useSavedShippingInfo) {
                  nameController.text = savedName ?? '';
                  emailController.text = savedEmail ?? '';
                  phoneController.text = savedPhone ?? '';
                  addressController.text = savedAddress ?? '';
                  
                  selectedProvince = savedProvince ?? '';
                  selectedDistrict = savedDistrict ?? '';
                  selectedTambon = savedTambon ?? '';
                  selectedPostalCodemain = savedPostalCode ?? '';

                  if (selectedProvince != null) {
                    onProvinceSelected(selectedProvince);
                  }
                  if (selectedDistrict != null) {
                    onDistrictSelected(selectedDistrict);
                  }
                  if (selectedTambon != null) {
                    onTambonSelected(selectedTambon);
                  }
                  
                  print('Loaded data: $savedName, $savedProvince, $savedDistrict, $savedTambon, $savedPostalCode');
                } else {
                  nameController.clear();
                  emailController.clear();
                  phoneController.clear();
                  addressController.clear();
                  selectedProvince = '';
                  selectedDistrict = '';
                  selectedTambon = '';
                  selectedPostalCodemain = '';
                }
              });
            },
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Text(
        'Shipping Information',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,color: Colors.amber[800]),
      ),
      SizedBox(height: 16.0),
      Row(
        children: [
          Expanded(
            child: _buildTextField('Name', nameController, maxLength: 30),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: _buildTextField('Email', emailController, maxLength: 30),
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Row(
        children: [
          Expanded(
            child: _buildTextField('Phone', phoneController, maxLength: 10),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: _buildTextField('Address Number', addressController,
                maxLength: 50),
          ),
        ],
      ),
      SizedBox(height: 16.0),
       Row(
        children: [
          Expanded(
            child: _buildDropdownField(
              'Province',
              provinces,
              onProvinceSelected,
              selectedItem: savedProvince?.isNotEmpty == true ? savedProvince : null, 
              required: true,
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: _buildDropdownField(
              'District',
              filteredDistricts,
              onDistrictSelected,
              selectedItem: savedDistrict?.isNotEmpty == true ? savedDistrict : null,
              required: true,
            ),
          ),
          SizedBox(width: 16.0), 
          Expanded(
            child: _buildDropdownField(
              'Tambon',
              filteredTambons,
              onTambonSelected,
              selectedItem: savedTambon?.isNotEmpty == true ? savedTambon : null,
              required: true,
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            flex: 1,
            child: _buildDropdownField(
              'Postal Code',
              filteredPostalCodes,
              (value) {
                setState(() {
                  selectedPostalCodemain = value ?? '';
                });
                print('Selected Postal Code: $selectedPostalCodemain');
              },
              selectedItem: savedPostalCode?.isNotEmpty == true ? savedPostalCode : null,
            ),
          ),
        ],
      ),
      SizedBox(height: 16.0),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Payment Method',
          border: OutlineInputBorder(),
          fillColor: Colors.white, 
          filled: true,     
        ),
        value: _selectedPaymentMethod,
        items: ['Bank Transfer', 'PromptPay']
            .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                ))
            .toList(),
        onChanged: (String? value) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        icon: FaIcon(FontAwesomeIcons.chevronDown),
        dropdownColor: Colors.white,
      ),
      SizedBox(height: 16.0),
      if (_selectedPaymentMethod == 'Bank Transfer') _buildBankTransferDetails(),
      if (_selectedPaymentMethod == 'PromptPay') _buildPromptPayDetails(),
    ],
  );
}

  Widget _buildBankTransferDetails() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
        ),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Transfer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/SCB.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Number: 322-260906-0',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Account Name: กีรตินันท์ พุทธายะ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Please check the account number and name carefully.',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptPayDetails() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PromptPay Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Account Name: กีรตินันท์ พุทธายะ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Please check the account number and name carefully.',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/qr_code.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlipImagePreview(
      BuildContext context, Uint8List? selectedSlipImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () => _pickSlipImage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text(
              'Choose File',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 16),
        selectedSlipImage != null
            ? GestureDetector(
                onTap: () {
                  _showFullImageDialog(context, selectedSlipImage);
                },
                child: Center(
                  child: Image.memory(
                    selectedSlipImage,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : const Text('No slip image selected.'),
      ],
    );
  }

  void _showFullImageDialog(BuildContext context, Uint8List image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.memory(image),
        );
      },
    );
  }
}