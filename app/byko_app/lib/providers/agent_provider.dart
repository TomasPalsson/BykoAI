import 'package:byko_app/models/agent_info.dart';
import 'package:flutter/material.dart';
import 'package:byko_app/models/agents.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgentProvider extends ChangeNotifier {
  Agent _agent = Agent.byko;
  AgentInfo get agentInfo => _agent.agentInfo;
  Agent get agent => _agent;

  void setAgent(Agent agent) async {
    _agent = agent;
    Uri uri = Uri.parse('http://192.168.0.129:8000/set_agent');
    print(uri);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: json.encode({
          'agentId': agent.agentInfo.agnetID,
          'agentAliasId': agent.agentInfo.agentAliasID,
        }),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode != 200) {
        throw Exception('Failed to set agent: ${response.statusCode}');
      }
    } catch (e) {
      print("Error setting agent: $e");
      rethrow;
    }
    notifyListeners();
  }
}
