/* (CheckoutFromCartScreen_Old) 

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../screens/base_screen.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';


class CheckoutFromCartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> product;

  CheckoutFromCartScreen({required this.products, required this.product});

  @override
  _CheckoutFromCartScreenState createState() => _CheckoutFromCartScreenState();
}

class _CheckoutFromCartScreenState extends State<CheckoutFromCartScreen> {
  bool _isCheckboxChecked = false;
  bool _isLoading = false;

  Uint8List? _selectedPromptPayImage;
  Uint8List? _selectedBankTransferImage;
  Uint8List? _selectedSlipImage;

  late double totalAmount = 0.0;
  int quantity = 1;
  final Map<String, int> quantities = {};
  
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
  final TextEditingController noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


@override
void initState() {
  super.initState();
  if (widget.products == null || widget.products.isEmpty) {
    throw Exception("Products list cannot be null or empty");
  }
  for (var product in widget.products) {
    quantities[product['serialNumber']] = 1; 
  }
  fetchDataFromMongoDB();
}

  Future<void> _pickSlipImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedSlipImage = bytes;
      });
    }
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
                    'DistrictThai': district['DistrictThai'].toString(),
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

Future<void> _submitOrderDataToMongoDB({
  required String name,
  required String email,
  required String phone,
  required String address,
  required String province,
  required String district,
  required String tambon,
  required String postalCodemain,
}) async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
  });
  if (widget.products.isEmpty) {
    _showSnackBar('No products in cart.');
    _resetLoadingState();
    return;
  }

   String? slipBase64;
  if (_selectedSlipImage != null) {
    slipBase64 = base64Encode(_selectedSlipImage!);
  } else {
    _showSnackBar('Please select a slip image.');
    _resetLoadingState();
    return;
  }

  Map<String, dynamic> shippingInfo = {
    'name': nameController.text.trim(),
    'email': emailController.text.trim(),
    'phone': phoneController.text.trim(),
    'address': addressController.text.trim(),
    'province': selectedProvince ?? '',
    'district': selectedDistrict ?? '',
    'tambon': selectedTambon ?? '',
    'postalCodemain': selectedPostalCodemain,
  };

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'products': widget.products.map((product) => {
          'quantity': quantities[product['serialNumber']] ?? 1,
          'price': product['price'],
          'images': product['images'],
          'brand': product['brand'],
          'serialNumber': product['serialNumber'],
        }).toList(),
        'shippingInfo': shippingInfo,
        'slip': slipBase64,
      }),
    );

    if (response.statusCode == 201) {
      _showSnackBar('Order confirmed successfully!');
      Navigator.pushReplacementNamed(context, '/shipping');
    } else {
      _showSnackBar('Failed to confirm order: ${response.statusCode} - ${response.body}');
    }
  } catch (error) {
    _showSnackBar('Error confirming order: $error');
  } finally {
    _resetLoadingState();
  }
}

void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
void _resetLoadingState() {
  setState(() {
    _isLoading = false;
  });
}

@override
Widget build(BuildContext context) {
  double deliveryFee = widget.products.isNotEmpty ? 100.0 : 0.0;
  double totalProductPrice = widget.products.fold(0, (sum, product) {
    double productPrice = product['price']?.toDouble() ?? 0;
    return sum + (productPrice * (quantities[product['serialNumber']] ?? 1));
  });
  double totalPrice = totalProductPrice + deliveryFee;

  return BaseScreen(
    title: 'Luxe House',
    body: SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, 
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(16),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.products.map((product) {
                          return _buildProductDetails(product);
                        }).toList(),
                        Divider(),
                        _buildTotalSection(totalProductPrice, deliveryFee),
                        SizedBox(height: 24.0),
                        _buildNoteToSellerSection(),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24.0),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShippingInformation(),
                      SizedBox(height: 32.0),
                      _buildSlipImagePreview(context, _selectedSlipImage),
                      SizedBox(height: 32.0),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading ? Colors.grey : const Color.fromARGB(255, 0, 51, 102), 
                            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
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
            ],
          ),
        ),
      ),
    ),
  );
}

void _handleSubmit() async {
  if (_formKey.currentState?.validate() ?? false) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitting your order...')),
    );

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final province = selectedProvince?.trim(); 
    final district = selectedDistrict?.trim();   
    final tambon = selectedTambon?.trim();      
    final postalCodemain = selectedPostalCodemain?.trim();

    debugPrint('Shipping Info: Name: $name, Email: $email, Phone: $phone');
    debugPrint('Address: $address');
    debugPrint('Province: $province, District: $district, Tambon: $tambon, PostalCode: $postalCodemain');

    if (widget.products.isNotEmpty && name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && address.isNotEmpty) {
      if (province != null && district != null && tambon != null && postalCodemain != null && postalCodemain.isNotEmpty) {
        await _submitOrderDataToMongoDB(
          name: name,
          email: email,
          phone: phone,
          address: address,
          province: province,
          district: district,
          tambon: tambon,
          postalCodemain: postalCodemain,
        );
      } else {
        _showSnackBar('Please complete all shipping information.');
      }
    } else {
      _showSnackBar('Please complete the required fields.');
    }
  } else {
    _showSnackBar('Please fill out the form correctly.');
  }
}


 Widget _buildProductDetails(Map<String, dynamic> product) {
  String serialNumber = product['serialNumber'] ?? 'unknow';
  double productPrice = product['price']?.toDouble() ?? 0.0;
  int quantity = quantities[serialNumber] ?? 1;
  var formatter = NumberFormat('#,###'); 
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          product['images'] != null
              ? Image.network(
                  product['images'],
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
                  child: Center(child: Text('No Image Available')),
                ),
          SizedBox(width: 24.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['brand'] ?? 'No Brand',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Text(
                  product['serialNumber'] ?? 'No Serial Number',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text('Quantity', style: TextStyle(fontSize: 18)),
                    Spacer(),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.minus),
                      onPressed: () {
                        setState(() {
                          if (quantities[serialNumber]! > 1) {
                            quantities[serialNumber] =
                                quantities[serialNumber]! - 1;
                          }
                        });
                      },
                    ),
                    Text('${quantities[serialNumber]}',
                        style: TextStyle(fontSize: 18)),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.plus),
                      onPressed: () {
                        setState(() {
                          quantities[serialNumber] =
                              quantities[serialNumber]! + 1;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                Text(
                  'Product Total Price: ${formatter.format(productPrice * quantities[serialNumber]!)} ฿', 
                  style: TextStyle(fontSize: 18),
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildTotalSection(double productPrice, double deliveryFee) {
  double totalPrice = productPrice + deliveryFee;
  var formatter = NumberFormat('#,###');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Delivery Fee: ${formatter.format(100)} ฿', 
        style: TextStyle(fontSize: 18),
      ),
      Text(
        'Total: ${formatter.format(totalPrice)} ฿',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
    ],
  );
}


  Widget _buildNoteToSellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.0),
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
            side: BorderSide(color: Colors.grey),
          ),
          child: Text(
            'Choose File',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      SizedBox(height: 16),
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
          : Text('No slip image selected.'),
    ],
  );
}

void _showFullImageDialog(BuildContext context, Uint8List image) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(
                image,
                fit: BoxFit.contain,
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
} */

/*
(CheckoutFromCartScreen_New) */
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/base_screen.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class CheckoutFromCartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> product;

  CheckoutFromCartScreen({required this.products, required this.product});

  @override
  _CheckoutFromCartScreenState createState() => _CheckoutFromCartScreenState();
}

class _CheckoutFromCartScreenState extends State<CheckoutFromCartScreen> {
  bool _useSavedShippingInfo = false;
  Uint8List? _selectedPromptPayImage;
  Uint8List? _selectedBankTransferImage;
  Uint8List? _selectedSlipImage;

  late double totalAmount = 0.0;
  int quantity = 1;
  final Map<String, int> quantities = {};
  
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
  final TextEditingController noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


@override
void initState() {
  super.initState();
  if (widget.products == null || widget.products.isEmpty) {
    throw Exception("Products list cannot be null or empty");
  }
  for (var product in widget.products) {
    quantities[product['serialNumber']] = 1; 
  }
  fetchDataFromMongoDB();
  fetchUserData();
}

  Future<void> _pickSlipImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedSlipImage = bytes;
      });
    }
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
                    'DistrictThai': district['DistrictThai'].toString(),
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

Future<void> _submitOrderDataToMongoDB({
  required String name,
  required String email,
  required String phone,
  required String address,
  required String province,
  required String district,
  required String tambon,
  required String postalCodemain,
}) async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
  });
  if (widget.products.isEmpty) {
    _showSnackBar('No products in cart.');
    _resetLoadingState();
    return;
  }

   String? slipBase64;
  if (_selectedSlipImage != null) {
    slipBase64 = base64Encode(_selectedSlipImage!);
  } else {
    _showSnackBar('Please select a slip image.');
    _resetLoadingState();
    return;
  }

  Map<String, dynamic> shippingInfo = {
    'name': nameController.text.trim(),
    'email': emailController.text.trim(),
    'phone': phoneController.text.trim(),
    'address': addressController.text.trim(),
    'province': selectedProvince ?? '',
    'district': selectedDistrict ?? '',
    'tambon': selectedTambon ?? '',
    'postalCodemain': selectedPostalCodemain,
  };

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'products': widget.products.map((product) => {
          'quantity': quantities[product['serialNumber']] ?? 1,
          'price': product['price'],
          'images': product['images'],
          'brand': product['brand'],
          'serialNumber': product['serialNumber'],
        }).toList(),
        'shippingInfo': shippingInfo,
        'slip': slipBase64,
      }),
    );

    if (response.statusCode == 201) {
      _showSnackBar('Order confirmed successfully!');
      Navigator.pushReplacementNamed(context, '/shipping');
    } else {
      _showSnackBar('Failed to confirm order: ${response.statusCode} - ${response.body}');
    }
  } catch (error) {
    _showSnackBar('Error confirming order: $error');
  } finally {
    _resetLoadingState();
  }
}

void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
void _resetLoadingState() {
  setState(() {
    _isLoading = false;
  });
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
  double deliveryFee = widget.products.isNotEmpty ? 100.0 : 0.0;
  double totalProductPrice = widget.products.fold(0, (sum, product) {
    double productPrice = product['price']?.toDouble() ?? 0;
    return sum + (productPrice * (quantities[product['serialNumber']] ?? 1));
  });
  double totalPrice = totalProductPrice + deliveryFee;

  return BaseScreen(
    title: 'Luxe House',
    body: SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, 
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.products.map((product) {
                          return _buildProductDetails(product);
                        }).toList(),
                        Divider(),
                        _buildTotalSection(totalProductPrice, deliveryFee),
                        SizedBox(height: 24.0),
                        _buildNoteToSellerSection(),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24.0),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShippingInformation(),
                      SizedBox(height: 32.0),
                      _buildSlipImagePreview(context, _selectedSlipImage),
                      SizedBox(height: 32.0),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading ? Colors.grey : const Color.fromARGB(255, 0, 51, 102), 
                            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
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
            ],
          ),
        ),
      ),
    ),
  );
}

void _handleSubmit() async {
  if (_formKey.currentState?.validate() ?? false) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submitting your order...')),
    );

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final province = selectedProvince?.trim();
    final district = selectedDistrict?.trim();
    final tambon = selectedTambon?.trim();
    final postalCodemain = selectedPostalCodemain?.trim();

    if (widget.products.isNotEmpty && name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && address.isNotEmpty) {
      if (province != null && district != null && tambon != null && postalCodemain != null && postalCodemain.isNotEmpty) {
        await _submitOrderDataToMongoDB(
          name: name,
          email: email,
          phone: phone,
          address: address,
          province: province,
          district: district,
          tambon: tambon,
          postalCodemain: postalCodemain,
        );
      } else {
        _showSnackBar('Please complete all shipping information.');
      }
    } else {
      _showSnackBar('Please complete the required fields.');
    }
  } else {
    _showSnackBar('Please fill out the form correctly.');
  }
}


 Widget _buildProductDetails(Map<String, dynamic> product) {
  String serialNumber = product['serialNumber'] ?? 'unknow';
  double productPrice = product['price']?.toDouble() ?? 0.0;
  int quantity = quantities[serialNumber] ?? 1;
  var formatter = NumberFormat('#,###'); 
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          product['images'] != null
              ? Image.network(
                  product['images'],
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
                  child: Center(child: Text('No Image Available')),
                ),
          SizedBox(width: 24.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['brand'] ?? 'No Brand',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.amber[800]),
                ),
                Text(
                  product['serialNumber'] ?? 'No Serial Number',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text('Quantity', style: TextStyle(fontSize: 18)),
                    Spacer(),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.minus),
                      onPressed: () {
                        setState(() {
                          if (quantities[serialNumber]! > 1) {
                            quantities[serialNumber] =
                                quantities[serialNumber]! - 1;
                          }
                        });
                      },
                    ),
                    Text('${quantities[serialNumber]}',
                        style: TextStyle(fontSize: 18)),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.plus),
                      onPressed: () {
                        setState(() {
                          quantities[serialNumber] =
                              quantities[serialNumber]! + 1;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                Text(
                  'Product Total Price: ${formatter.format(productPrice * quantities[serialNumber]!)} ฿', 
                  style: TextStyle(fontSize: 18),
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildTotalSection(double productPrice, double deliveryFee) {
  double totalPrice = productPrice + deliveryFee;
  var formatter = NumberFormat('#,###');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Delivery Fee: ${formatter.format(100)} ฿', 
        style: TextStyle(fontSize: 18),
      ),
      Text(
        'Total: ${formatter.format(totalPrice)} ฿',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,color: Colors.amber[800]),
      ),
    ],
  );
}


  Widget _buildNoteToSellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.0),
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
    onChanged: (text) {
    },
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
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.amber[800]),
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

Widget _buildSlipImagePreview(BuildContext context, Uint8List? selectedSlipImage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Center(
        child: ElevatedButton(
          onPressed: () => _pickSlipImage(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey),
          ),
          child: Text(
            'Choose File',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      SizedBox(height: 16),
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
          : Text('No slip image selected.'),
    ],
  );
}

void _showFullImageDialog(BuildContext context, Uint8List image) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(
                image,
                fit: BoxFit.contain,
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