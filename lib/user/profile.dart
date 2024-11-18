import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_luxe_house/screens/base_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileOverlay extends StatefulWidget {
  @override
  _ProfileOverlayState createState() => _ProfileOverlayState();

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
              width: 270,
              child: ProfileOverlay(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOverlayState extends State<ProfileOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Menu',
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
            ListTile(
              leading: FaIcon(FontAwesomeIcons.user),
              title: Text('ข้อมูลโปรไฟล์'),
              onTap: () {
                Navigator.pushNamed(context, '/profile').then((_) {
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.shippingFast),
              title: Text('ข้อมูลการจัดส่งสินค้า'),
              onTap: () {
                Navigator.pushNamed(context, '/shipping').then((_) {
                  Navigator.pop(context);
                });
              },
            ),
            /* ListTile(
              leading: FaIcon(FontAwesomeIcons.receipt),
              title: Text('Receipt'),
              onTap: () {
                Navigator.pushNamed(context, '/receipt').then((_) {
                  Navigator.pop(context);
                });
              },
            ), */
          ],
        ),
      ),
    );
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------profile--------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

class ProfileInfoPage extends StatefulWidget {
  final String token;
  final http.Client client;

  ProfileInfoPage({Key? key, required this.token, required http.Client? client})
      : client = client ?? http.Client(),
        super(key: key);

  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  String username = '';
  String email = '';
  String phone = '';
  String address = '';
  String province = '';
  String district = '';
  String tambon = '';
  String postalCode = '';

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

  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchDataFromMongoDB();
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
            username = data['username'];
            email = data['email'];
            phone = data['phone'] ?? '';
            address = data['address'] ?? '';
            province = data['province'] ?? '';
            district = data['district'] ?? '';
            tambon = data['tambon'] ?? '';
            postalCode = data['postal_code'] ?? '';

            phoneController.text = phone;
            addressController.text = address;
          });
        } else {
          print('Failed to load user data: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
      print('Token not found');
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

  void _saveShippingInformation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final url = 'http://localhost:3000/users/me';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final data = {
      'phone': phoneController.text,
      'address': addressController.text,
      'province': selectedProvince,
      'district': selectedDistrict,
      'tambon': selectedTambon,
      'postal_code': selectedPostalCodemain,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print('Shipping Information Saved');
        print('Response: ${response.body}');
        prefs.setString('phone', phoneController.text);
        prefs.setString('address', addressController.text);
        prefs.setString('province', selectedProvince!);
        prefs.setString('district', selectedDistrict!);
        prefs.setString('tambon', selectedTambon!);
        prefs.setString('postal_code', selectedPostalCodemain);

        fetchUserData();
      } else {
        print(
            'Failed to save shipping information. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Profile Information',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 25),
              _buildShippingInformation(),
              SizedBox(height: 25),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF003366),
              child: Icon(FontAwesomeIcons.user, color: Colors.white, size: 40),
            ),
            SizedBox(height: 20),
            Text(
              'Profile',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadonlyTextField(String label, String value, IconData icon) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildShippingInformation() {
    return Card(
      color: Colors.white,
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildReadonlyTextField(
                'Username', username, FontAwesomeIcons.user),
            SizedBox(height: 10),
            _buildReadonlyTextField('Email', email, FontAwesomeIcons.envelope),
            SizedBox(height: 20),
            Text(
              'Shipping Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.amber[800],
              ),
            ),
            SizedBox(height: 10),
            (phone.isEmpty &&
                    address.isEmpty &&
                    province.isEmpty &&
                    district.isEmpty &&
                    tambon.isEmpty &&
                    postalCode.isEmpty)
                ? _buildEditableShippingFields()
                : _buildReadonlyShippingFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableShippingFields() {
    return Column(
      children: [
        Row(
          children: [
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
              child: _buildDropdownField(
                'Province',
                provinces,
                onProvinceSelected,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: _buildDropdownField(
                'District',
                filteredDistricts,
                onDistrictSelected,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: _buildDropdownField(
                'Tambon',
                filteredTambons,
                onTambonSelected,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: _buildDropdownField(
                'Postal Code',
                filteredPostalCodes,
                (value) {
                  setState(() {
                    selectedPostalCodemain = value ?? '';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadonlyShippingFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildReadonlyTextField(
                  'Phone', phone, FontAwesomeIcons.phone),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildReadonlyTextField(
                  'Address', address, FontAwesomeIcons.mapMarkedAlt),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildReadonlyTextField(
                  'Province', province, FontAwesomeIcons.city),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildReadonlyTextField(
                  'District', district, FontAwesomeIcons.mapSigns),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildReadonlyTextField(
                  'Tambon', tambon, FontAwesomeIcons.map),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildReadonlyTextField(
                  'Postal Code', postalCode, FontAwesomeIcons.envelope),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLength = 40}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        counterText: '',
      ),
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: _saveShippingInformation,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.grey),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text('Save'),
          ),
        ),
        SizedBox(width: 5),
        SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: () {
              _confirmLogout(context);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text('Logout'),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/userlogin');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------profile--------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

class ForgotPassword2Screen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPassword2Screen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    final email = _emailController.text;
    final username = _usernameController.text;
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    print('Email: $email');
    print('Username: $username');
    print('Old Password: $oldPassword');
    print('New Password: $newPassword');

    if (email.isEmpty ||
        username.isEmpty ||
        oldPassword.isEmpty ||
        newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/users/resetpassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password has been reset successfully')),
        );
        Navigator.of(context).pushReplacementNamed('/userlogin');
      } else {
        var errorResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to reset password: ${errorResponse['message']}')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'RESET PASSWORD',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: Center(
          child: Container(
            width: 500,
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color.fromARGB(255, 0, 51, 102),
                      child: Icon(FontAwesomeIcons.lockOpen,
                          color: Colors.white, size: 40),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.envelope),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.user),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.lock),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.lock),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        _resetPassword(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: Text('Reset Password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
