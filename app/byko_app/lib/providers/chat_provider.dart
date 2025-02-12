import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  int _timeTaken = 0;
  int get timeTaken => _timeTaken;

  String? _sessionId;
  StreamSubscription? _subscription;
  
  static String get _baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.0.129:8000';  // Android emulator
    }
    return 'http://192.168.0.129:8000';    // Web and others
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    final stopwatch = Stopwatch()..start();
    _isLoading = true;
    notifyListeners();
    _sessionId ??= const Uuid().v4();

    addMessage(Message(content: content, isUser: true));

    try {
      final uri = Uri.parse('$_baseUrl/chat').replace(
        queryParameters: {
          'prompt': content,
          'session_id': _sessionId,
        },
      );

      final request = http.Request('POST', uri);
      final response = await http.Client().send(request);
      await _subscription?.cancel();
      
      bool isFirstChunk = true;
      String buffer = '';
      int chunkCount = 0;
      
      debugPrint('Starting to receive SSE stream');
      
      _subscription = response.stream.transform(utf8.decoder).listen(
        (data) {
            chunkCount++;
            
              buffer += data;
              final previousLength = buffer.length;
              debugPrint('Processing chunk #$chunkCount - Chunk size: ${data.length} chars, Total size: ${buffer.length} chars, Delta: ${buffer.length - previousLength} chars');
              
              if (isFirstChunk) {
                debugPrint('Adding first message chunk');
                addMessage(Message(content: buffer, isUser: false));
                isFirstChunk = false;
              } else {
                debugPrint('Updating message with new chunk');
                // Update the message immediately with new content
                _messages.last = _messages.last.copyWith(content: buffer);
                notifyListeners();
              }
        },
        onError: (error) {
          stopwatch.stop();
          _timeTaken = stopwatch.elapsedMilliseconds;
          debugPrint('Error receiving SSE: $error');
          _isLoading = false;
          notifyListeners();
          addMessage(
            Message(
              content: 'Error receiving message: $error',
              isUser: false,
            ),
          );
        },
        onDone: () {
          stopwatch.stop();
          _timeTaken = stopwatch.elapsedMilliseconds;
          debugPrint('SSE stream completed. Total chunks received: $chunkCount');
          _isLoading = false;
          notifyListeners();
          _subscription?.cancel();
          _subscription = null;
        },
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      _isLoading = false;
      notifyListeners();
      addMessage(
        Message(
          content: 'Error sending message: $e',
          isUser: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void clearChat() {
    _messages.clear();
    _sessionId = null;
    notifyListeners();
  }
}
