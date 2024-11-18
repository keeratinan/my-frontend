import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_luxe_house/screens/base_screen.dart';
import 'package:intl/intl.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool hasStarted = false;
  bool isAdminAvailable = true; 
  bool isMessageSent = false; 

  List<String> predefinedQuestions = [
    'นาฬิกาสำหรับผู้หญิงมีไหม',
    'นาฬิกาสำหรับผู้ชายมียี่ห้ออะไรบ้าง',
    'ส่งนาฬิกากี่วันถึง',
    'พรีออเดอร์รอของกี่วัน',
    'รับผ่อนชำระได้ไหม',
    'นาฬิกามือสองมีไหม',
    'มีการเก็บเงินปลายทางไหม',
    'เปลี่ยนคืนสินค้าได้ไหม',
    'เปลี่ยนสายนาฬิกาได้ไหม',
    'นาฬิกาสำหรับดำน้ำรุ่นไหนดี',
    'มีบริการล้างเครื่องนาฬิกาไหม',
    'ถ้าสายนาฬิกาขาดทำยังไง',
    'นาฬิกาสำหรับใส่ออกงานแนะนำอะไร',
    'มีนาฬิกาสำหรับเด็กไหม',
    'นาฬิกาข้อมือสายหนังดียังไง',
    'นาฬิกาแบตเตอรี่กี่ปี',
    'นาฬิกาเดินไม่ตรงควรทำอย่างไร',
    'นาฬิกาข้อมือสายเหล็กดียังไง',
    'มีส่วนลดไหม',
    'จ่ายเงินยังไง',
  ];

  Future<String> _fetchResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/chatbot/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': userMessage}),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['answer'] ?? 'ขออภัย ไม่พบคำตอบที่ต้องการ';
      } else {
        return 'เกิดข้อผิดพลาดในการดึงข้อมูลจากเซิร์ฟเวอร์';
      }
    } catch (error) {
      return 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์: $error';
    }
  }

  void _handlePredefinedQuestion(String question) {
    _controller.text = question;
    _sendMessage();
  }

  void _sendMessage() {
    String userInput = _controller.text.trim();
    if (userInput.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'user', 'text': userInput});
        messages.add({'sender': 'bot', 'text': 'กำลังค้นหาคำตอบ...'});
        _controller.clear();
      });

      _scrollToBottom(); 
      _fetchResponse(userInput).then((botReply) {
        setState(() {
          messages.removeLast();
          messages.add({'sender': 'bot', 'text': botReply});
          _scrollToBottom(); 
        });
      });
    }
  }

  Future<void> _contactAdmin() async {
    String userInput = _controller.text.trim();
    if (userInput.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/admin/messages'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': userInput,
            'timestamp': DateTime.now().toString(),
            'user': 'customer',
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            isMessageSent = true; 
          });

          Future.delayed(Duration(seconds: 5), () {
            setState(() {
              isMessageSent = false;
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ข้อความของคุณถูกส่งถึง Admin เรียบร้อยแล้ว')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถส่งข้อความถึง Admin ได้ กรุณาลองใหม่')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อความ: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาพิมพ์ข้อความก่อนติดต่อ Admin')),
      );
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentDate =
        DateFormat('MMMM dd, yyyy, hh:mm a').format(DateTime.now());

    return BaseScreen(
      title: 'Chatbot',
      body: hasStarted
          ? Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Chat - $currentDate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 51, 102),
                          ),
                        ),
                   /*     SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: isMessageSent ? null : _contactAdmin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMessageSent
                                  ? Colors.grey
                                  : const Color.fromARGB(255, 0, 51, 102),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: Text(
                              isMessageSent
                                  ? 'ข้อความถูกส่งแล้ว, กรุณารอ...'
                                  : 'ติดต่อ Admin',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ), */
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: ListView.builder(
                        controller: _scrollController, // Attach controller
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index];
                          bool isUser = message['sender'] == 'user';
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Center(
                                      child: FaIcon(FontAwesomeIcons.robot,
                                          color: Colors.white),
                                    ),
                                  ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? const Color.fromARGB(255, 0, 51, 102)
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    message['text'] ?? '',
                                    style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.white),
                                  ),
                                ),
                                if (isUser)
                                  CircleAvatar(
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 51, 102),
                                    child: FaIcon(FontAwesomeIcons.user,
                                        color: Colors.white),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'คำถามยอดนิยม:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                        SizedBox(height: 10.0),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: predefinedQuestions.map((question) {
                            return ElevatedButton(
                              onPressed: () =>
                                  _handlePredefinedQuestion(question),
                              child: Text(
                                question,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: const Color.fromARGB(255, 0, 51, 102),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
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
                            icon: FaIcon(
                              FontAwesomeIcons.paperPlane,
                              color: Colors.grey,
                            ),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _buildWelcomeScreen(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
      color: const Color.fromARGB(255, 238, 242, 249),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ยินดีต้อนรับ!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 51, 102),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'เข้าสู่บริการ Chatbot ของ Luxehouse',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.robot,
                    size: 80,
                    color: const Color.fromARGB(255, 0, 51, 102),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasStarted = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
                child: Text(
                  'เริ่มต้นการสนทนา',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 51, 102),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
