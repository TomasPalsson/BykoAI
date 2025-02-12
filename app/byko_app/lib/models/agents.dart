import 'package:byko_app/models/agent_info.dart';

enum Agent {
  byko,
  husasmidjan,
  internet
}

extension GetAgentInfo on Agent {
  AgentInfo get agentInfo {
    if (this == Agent.byko) {
      return AgentInfo(agnetID: '6LFCK7ERMT', agentAliasID: 'YFV7BCG0NA');
    }
    if (this == Agent.husasmidjan) {
      return AgentInfo(agnetID: 'TLIBDZZHNP', agentAliasID: 'GCC0VTKBAH');
    }
    if (this == Agent.internet) {
      return AgentInfo(agnetID: 'DVWHSY4UFR', agentAliasID: '8GVEJ9JV5P');
    }
    throw Exception('Agent not found');
  }

  String get name {
    if (this == Agent.byko) {
      return 'Býkó Scraped';
    }
    if (this == Agent.husasmidjan) {
      return 'Húsasmiðjan API';
    }
    if (this == Agent.internet) {
      return 'Internet';
    }
    throw Exception('Agent not found');
  }
}

