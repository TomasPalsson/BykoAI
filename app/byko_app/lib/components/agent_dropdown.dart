import 'package:flutter/material.dart';
import 'package:byko_app/models/agents.dart';
import 'package:provider/provider.dart';
import 'package:byko_app/providers/agent_provider.dart';
import 'package:byko_app/providers/chat_provider.dart';

class AgentDropdown extends StatelessWidget {
  const AgentDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Agent>(
          value: Provider.of<AgentProvider>(context).agent,
          dropdownColor: Theme.of(context).primaryColor,
          style: Theme.of(context).textTheme.bodyMedium,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: Agent.values.map((Agent agent) {
            return DropdownMenuItem<Agent>(
              value: agent,
              child: Text(
                agent.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (Agent? newValue) {
            if (newValue != null) {
              Provider.of<ChatProvider>(context, listen: false).clearChat();
              Provider.of<AgentProvider>(context, listen: false).setAgent(newValue);
            }
          },
        ),
      ),
    );
  }
}
