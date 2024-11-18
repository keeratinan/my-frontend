import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_luxe_house/admin/base_screen2.dart';

class AdminMessagesScreen extends StatefulWidget {
  @override
  _AdminMessagesScreenState createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  List<Map<String, dynamic>> messages = [];

  final TextEditingController _controller = TextEditingController();

  Future<void> _fetchMessages() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/messages/admin'));
      if (response.statusCode == 200) {
        print(
            'Messages received: ${response.body}');
        setState(() {
          messages = List<Map<String, dynamic>>.from(jsonDecode(response.body))
              .map((msg) => {'sender': msg['user'], 'text': msg['message']})
              .toList();
        });
      } else {
        print('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching messages: $error');
    }
  }

  Future<void> _sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'user': 'admin'}),
      );
      if (response.statusCode == 200) {
        setState(() {
          messages.add({'sender': 'admin', 'text': message});
        });
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Admin Messages',
      actions: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.sync),
          onPressed: _fetchMessages,
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isAdmin = message['sender'] == 'admin';
                return Align(
                  alignment:
                      isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: isAdmin
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isAdmin)
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: FaIcon(FontAwesomeIcons.user),
                          ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(message['text'] ??
                              'ข้อความว่างเปล่า'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.paperPlane),
                    color: Colors.grey,
                    onPressed: () {
                      String adminInput = _controller.text.trim();
                      if (adminInput.isNotEmpty) {
                        _sendMessage(adminInput);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
