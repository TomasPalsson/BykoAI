import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isLoading;
  final bool last;
  final String timeTaken;
  const ChatBubble({super.key, required this.message, required this.isUser, required this.last, this.isLoading = false, this.timeTaken = "0"});

  List<TextSpan> _parseMessage(BuildContext context) {
    final List<TextSpan> spans = [];
    final RegExp linkPattern = RegExp(r'\{\{(.*?)\|(.*?)\}\}');
    String remainingText = message;
    int lastMatchEnd = 0;

    for (final match in linkPattern.allMatches(message)) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: message.substring(lastMatchEnd, match.start),
        ));
      }

      // Extract text and link from the match
      final text = match.group(1) ?? '';
      final link = match.group(2) ?? '';

      // Add the link span
      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFFfecf35),
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri url = Uri.parse("https://www.husa.is$link");
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
      ));

      lastMatchEnd = match.end;
    }

    // Add any remaining text after the last match
    if (lastMatchEnd < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastMatchEnd),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    String aiText = isLoading ? "AI" : "AI ($timeTaken ms)";
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(isUser ? "You" : aiText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                  ),
                  border: Border.all(
                    color: isUser ? const Color(0xFFfecf35) : const Color.fromARGB(255, 37, 150, 190),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: isLoading && last ? LoadingAnimationWidget.waveDots(color: Colors.white, size: 20) : RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,  
                    children: _parseMessage(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

