import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byko_app/providers/chat_provider.dart';
import 'package:byko_app/components/chat_bubble.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _messageController = TextEditingController();
    final _chatProvider = Provider.of<ChatProvider>(context);
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return ListView.builder(
                      reverse: false,
                      itemBuilder: (context, index) => index == chatProvider.messages.length ?
                       const ChatBubble(message: "", isUser: false, last: true, isLoading: true) : ChatBubble(
                        message: chatProvider.messages[index].content,
                        isUser: chatProvider.messages[index].isUser,
                        last: index == chatProvider.messages.length,
                        timeTaken: chatProvider.timeTaken.toString()),
                      itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                      // Add padding at the bottom to prevent messages from being hidden behind input
                      padding: EdgeInsets.only(bottom: 40),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 
              8.0 + MediaQuery.of(context).viewInsets.bottom),
            child: TextField(
              controller: _messageController,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _chatProvider.sendMessage(value);
                  _messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

