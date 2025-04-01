import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  final List<Map<String, String>> chats = [
    {"name": "Alexander Acheampong", "lastMessage": "Hello, is it still available?", "image": "assets/user-profile.jpg"},
    {"name": "Kwabena Tuesday", "lastMessage": "I'll send the money soon.", "image": "assets/user-profile.jpg"},
    {"name": "Kweku Wednesday", "lastMessage": "Thanks for the order!", "image": "assets/user-profile.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Green Navbar
          Container(
            color: Color.fromRGBO(0, 77, 64, 1), // Green navbar
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
            child: Row(
              children: [
                Image.asset('assets/app_logo_white.png', width: 70, height: 70), // Logo
                Expanded(
                  child: Center(
                    child: Text(
                      "Messages",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
          ),

          SizedBox(height: 20),

          // **Search Bar**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search Direct Messages",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // **Chat List**
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(name: chats[index]["name"]!, image: chats[index]["image"]!),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(chats[index]["image"]!),
                          radius: 25,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chats[index]["name"]!,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Text(
                              chats[index]["lastMessage"]!,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
