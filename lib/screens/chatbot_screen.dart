import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'bot',
      'text': 'Hello! I am your task mangement  Assistant. How can I help you today? I can suggest exercises, diet plans, running tips, or give you some motivation!'
    }
  ];

  void _handleSend() {
    if (_controller.text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': _controller.text});
    });

    String userText = _controller.text.toLowerCase();
    _controller.clear();

    // Mock AI Logic
    Future.delayed(Duration(milliseconds: 500), () {
      String response = "I'm not sure about that. Try asking about exercise, running, diet, or motivation!";

      if (userText.contains('exercise') || userText.contains('workout')) {
        response = "For beginners, I recommend a mix of bodyweight exercises: 15 Squats, 10 Pushups, and a 30-second Plank. Do 3 sets!";
      } else if (userText.contains('run')) {
        response = "If you're starting out, try running for 20 minutes at a pace where you can still hold a conversation. Consistency is key!";
      } else if (userText.contains('diet') || userText.contains('food')) {
        response = "A balanced diet should include 40% carbs, 30% protein, and 30% healthy fats. Don't forget to stay hydrated!";
      } else if (userText.contains('motivation')) {
        response = "The only bad workout is the one that didn't happen. You've got this! One step at a time.";
      }

      setState(() {
        _messages.add({'role': 'bot', 'text': response});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : Color(0xFFFBE9D7),
      appBar: AppBar(
        title: Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isBot = msg['role'] == 'bot';
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot
                          ? (isDark ? Colors.grey[800] : Colors.white)
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(15).copyWith(
                        bottomLeft: isBot ? Radius.zero : Radius.circular(15),
                        bottomRight: isBot ? Radius.circular(15) : Radius.zero,
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isBot ? (isDark ? Colors.white : Colors.black87) : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      filled: true,
                      fillColor: isDark ? Colors.grey[850] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _handleSend,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
