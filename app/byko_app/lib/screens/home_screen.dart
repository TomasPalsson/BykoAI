import 'package:byko_app/components/agent_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byko_app/providers/agent_provider.dart';
import 'package:byko_app/providers/chat_provider.dart';
import 'package:byko_app/screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AgentProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: AgentDropdown(),
          backgroundColor: Color(0xFF0067a4),
        ),
        body: ChatScreen(),
      ),
    );
  }
}

