import 'package:flutter/material.dart';
import 'dart:async';
import 'chat_bot_client.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatController = TextEditingController();
  final _chatClient = ChatbotClient(
    projectId: 'ovacare',
    agentId: '3cd22390-5cf9-406d-9814-c0fe709d7ab6',
    location: 'global',
  );

  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
  }

  void _sendInitialMessage() async {
    final response = await _chatClient.sendMessage('1', 'Hi');
    setState(() {
      _messages.add({'text': response, 'isUser': false});
    });
  }

  void _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'text': message, 'isUser': true});
      _isTyping = true;
    });

    _chatController.clear();

    await Future.delayed(Duration(seconds: 1));

    final response = await _chatClient.sendMessage('1', message);

    setState(() {
      _isTyping = false;
      _messages.add({'text': response, 'isUser': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241,249,249), 
      appBar: AppBar(
        title: Text(
          'Ovacare Bot',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 74,98,138), 
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/logo.png'),
                            radius: 16,
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'OvaCare Bot is typing...',
                            style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'FunnelSans'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                bool isUserMessage = message['isUser'];

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10), 
                  child: Align(
                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isUserMessage) ...[
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/logo.png'),
                            radius: 20,
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0), 
                                child: Text(
                                  isUserMessage ? "You" : "OvaCare Bot",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                    fontFamily: 'FunnelSans'
                                  ),
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUserMessage ? Colors.white : Color.fromARGB(255, 74,98,138),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  message['text'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isUserMessage ? Color.fromARGB(255, 74,98,138): Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'FunnelSans'
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUserMessage) ...[
                          SizedBox(width: 10),
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/user_avatar.png'),
                            radius: 20,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _chatController,
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.black45, fontFamily: 'FunnelSans'),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color.fromARGB(255, 74,98,138),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
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
