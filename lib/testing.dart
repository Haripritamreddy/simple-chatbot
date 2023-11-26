import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<ChatMessage> chatMessages = [];
  ScrollController _scrollController = ScrollController();

  void _handleSubmitted(String text) {
    _sendMessageToAPI(text);

    ChatMessage message = ChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      chatMessages.add(message);
    });

    messageController.clear();

    _scrollToBottom();
  }

  Future<void> _sendMessageToAPI(String text) async {
    final url = Uri.parse('https://69ee-34-125-254-126.ngrok-free.app/api/generate');
    final requestData = {
      "model": "dolphin",
      "prompt": text,
      "stream": false
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      if (responseBody.containsKey("response")) {
        String aiResponse = responseBody["response"];

        ChatMessage aiMessage = ChatMessage(
          text: aiResponse,
          isUser: false,
        );

        setState(() {
          chatMessages.add(aiMessage);
        });

        _scrollToBottom();
      } else {
        print('API response does not contain "response" field.');
      }
    } else {
      print('Failed to send message to the API.');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LLM Chat"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                return chatMessages[index];
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: messageController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration(
                  hintText: "Send a message",
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(messageController.text),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.black : Colors.black, // Black background
                border: Border.all(
                  color: isUser ? Colors.white : Colors.purple, // White border for user, violet border for AI
                  width: 1.0,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 0.0 : 8.0),
                  topRight: Radius.circular(isUser ? 8.0 : 0.0),
                  bottomLeft: const Radius.circular(8.0),
                  bottomRight: const Radius.circular(8.0),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
