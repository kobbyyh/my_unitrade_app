
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String image;

  ChatScreen({required this.name, required this.image});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [
    {"text": "Hello, is this still available?", "isSender": "false"},
    {"text": "Yes, it is!", "isSender": "true"},
    {"text": "Great! I'll take it.", "isSender": "false"},
    {"text": "Okay! Let's proceed with payment.", "isSender": "true"},
  ];

  void sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({"text": _messageController.text, "isSender": "true"});
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 77, 64, 1),
      body: SafeArea( // ✅ Wrap Column in SafeArea
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.image),
                    radius: 22,
                  ),
                  SizedBox(width: 10),
                  Text(widget.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Spacer(),
                  Icon(Icons.call, color: Colors.white),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isSender = messages[index]["isSender"] == "true";
                  return Align(
                    alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSender ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: isSender ? Radius.circular(15) : Radius.zero,
                          bottomRight: isSender ? Radius.zero : Radius.circular(15),
                        ),
                      ),
                      child: Text(messages[index]["text"]!,
                          style: TextStyle(color: isSender ? Colors.white : Colors.black, fontSize: 14)),
                    ),
                  );
                },
              ),
            ),

            // Input Box
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.white),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type here",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
