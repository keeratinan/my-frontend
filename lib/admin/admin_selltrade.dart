import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_luxe_house/admin/admin_dashboard.dart';
import 'base_screen2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminSellTradeScreen extends StatefulWidget {
  @override
  _AdminSellTradeScreenState createState() => _AdminSellTradeScreenState();
}

class _AdminSellTradeScreenState extends State<AdminSellTradeScreen> {
  List<Map<String, dynamic>> customerData = [];

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData() async {
    final url = Uri.parse('http://localhost:3000/trade');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(data);
        setState(() {
          customerData = data.map((item) {
            return {
              'name': item['name'] ?? 'N/A',
              'email': item['email'] ?? 'N/A',
              'phone': item['phone'] ?? 'N/A',
              'brand': item['brand'] ?? 'N/A',
              'year': item['year'] ?? 'N/A',
              'type': item['type'] ?? 'N/A',
              'addedAt': item['addedAt'] ?? 'N/A',
              'images': item['images'] ?? [],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Admin Dashboard',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sell/Trade',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:  Color.fromARGB(255, 0, 51, 102), 
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListView.builder(
                      itemCount: customerData.length,
                      itemBuilder: (context, index) {
                        return _buildSellTradeTile(customerData[index]);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: AdminDrawer(),
    );
  }

  Widget _buildSellTradeTile(Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(
          'Sell/Trade',  
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 51, 102)),
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
                _buildDetailsSection(data),
                const SizedBox(height: 24),
                _buildImagesSection(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> data) {
    return Card(
      color: Color(0xFFF9F9F9),
      margin: const EdgeInsets.only(top: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Name: ${data['name'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailItem('Email', data['email']),
            _buildDetailItem('Phone', data['phone']),
            _buildDetailItem('Brand', data['brand']),
            _buildDetailItem('Year', data['year']),
            _buildDetailItem('Type', data['type']),
            _buildDetailItem('Added At', data['addedAt']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images:',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: (data['images'] as List).length,
            itemBuilder: (context, index) {
              String image = data['images'][index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        content: Container(
                          width: 300,
                          height: 300,
                          child: Image.memory(
                            base64Decode(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(image),
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
