import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(ChatBotApp());

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatScreen(),
    );
  }
}

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isLoading = true;
    });

    _controller.clear();
    _getBotResponse(text);
  }

  Future<void> _getBotResponse(String userMessage) async {
    const apiKey = 'AIzaSyBAb370SaKPh_aFNJT5LV6lj1ovKvNloZc';
    const apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['candidates'][0]['content']['parts'][0]['text'] ?? 'No reply';

        setState(() {
          _messages.add(Message(text: botReply.trim(), isUser: false));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to get response');
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(text: '❌ Error: ${e.toString()}', isUser: false));
        _isLoading = false;
      });
    }
  }

  bool _isVisible = true;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    // Start fade-out after 3 seconds
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _opacity = 0.0;
      });

      // Remove the container completely after fade-out
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isVisible = false;
        });
      });
    });
  }


  Widget _buildMessage(Message msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.indigoAccent.shade200 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: msg.isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Chatbot",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: Column(

        children: [

          Center(
            child: _isVisible ? AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1),
              child: Container(
                margin: EdgeInsets.only(top: 30, bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Your onPressed logic
                  },
                  icon: Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: EdgeInsets.all(12),
                    minimumSize: Size(250, 70),
                  ),
                  label: Text(
                    "Let your assistant help you!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
                : SizedBox(), // Empty when not visible
          ),


          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildMessage(_messages[_messages.length - 1 - index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12,bottom: 12,left: 10,right: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey.shade800),
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,color: Colors.indigoAccent.shade200,size: 35,),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}
















