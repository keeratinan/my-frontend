import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_luxe_house/admin/admin_dashboard.dart';
import 'base_screen2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges; 

class ChatbotAdminScreen extends StatefulWidget {
  @override
  _ChatbotAdminScreenState createState() => _ChatbotAdminScreenState();
}

class _ChatbotAdminScreenState extends State<ChatbotAdminScreen> {
  List<dynamic> chatbotData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatbotData();
  }

  Future<void> fetchChatbotData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/chatbot'));
      if (response.statusCode == 200) {
        setState(() {
          chatbotData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load chatbot data');
      }
    } catch (e) {
      print('Error fetching chatbot data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addChatbot() async {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

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
              'เพิ่มคำถาม',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'คำถาม',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: 'คำตอบ',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (questionController.text.isEmpty ||
                    answerController.text.isEmpty) {
                  _showSnackBar('กรุณากรอกข้อมูลให้ครบถ้วน');
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/chatbot'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'คำถาม': questionController.text,
                      'คำตอบ': answerController.text,
                    }),
                  );

                  if (response.statusCode == 201) {
                    Navigator.of(context).pop();
                    fetchChatbotData();
                    _showSnackBar('เพิ่มคำถามสำเร็จ');
                  } else {
                    Navigator.of(context).pop();
                    _showSnackBar('เพิ่มคำถามไม่สำเร็จ: ${response.body}');
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  _showSnackBar('เกิดข้อผิดพลาดในการเพิ่มคำถาม: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'เพิ่มคำถาม',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editChatbot(Map chatbot) async {
    final questionController =
        TextEditingController(text: chatbot['คำถาม'] ?? '');
    final answerController =
        TextEditingController(text: chatbot['คำตอบ'] ?? '');

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
              'แก้ไขคำถาม',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'คำถาม',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: 'คำตอบ',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 107, 107, 107)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      Center(child: CircularProgressIndicator()),
                );

                try {
                  final response = await http.put(
                    Uri.parse(
                        'http://localhost:3000/chatbot/${chatbot['_id']}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'คำถาม': questionController.text,
                      'คำตอบ': answerController.text,
                    }),
                  );
                  Navigator.of(context).pop();
                  if (response.statusCode == 200) {
                    fetchChatbotData();
                    Navigator.of(context).pop();
                    _showSnackBar('แก้ไขคำถามสำเร็จ');
                  } else {
                    Navigator.of(context).pop();
                    _showSnackBar('แก้ไขคำถามไม่สำเร็จ: ${response.body}');
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  _showSnackBar('เกิดข้อผิดพลาดในการแก้ไขคำถาม: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'อัพเดทคำถาม',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Chatbot Admin',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chatbot Admin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 51, 102),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _addChatbot,
                    child: Text('เพิ่มคำถาม'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Card(
                          color: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Question')),
                                DataColumn(label: Text('Answer')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: chatbotData.map((chatbot) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(chatbot['คำถาม'] ?? '')),
                                    DataCell(Text(chatbot['คำตอบ'] ?? '')),
                                    DataCell(
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                _editChatbot(chatbot),
                                            child: Text('แก้ไข'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[200],
                                              foregroundColor: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
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
}
