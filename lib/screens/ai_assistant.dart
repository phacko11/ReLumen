import 'package:flutter/material.dart';
// import 'package:cloud_functions/cloud_functions.dart'; // Uncomment when ready for actual Cloud Function calls

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Uncomment and configure when ready for Firebase Functions
  // final HttpsCallable _callable = FirebaseFunctions.instanceFor(region: 'your-cloud-function-region')
  //                                   .httpsCallable('yourCloudFunctionName');

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUserMessage: true));
      _isLoading = true;
    });

    _getAiResponse(text);
  }

  Future<void> _getAiResponse(String userQuery) async {
    // Placeholder for actual AI call via Cloud Function
    print("User query: $userQuery"); // For debugging

    // Simulate network delay and AI processing
    await Future.delayed(const Duration(seconds: 2));

    String aiResponseText = "I am Luminas. You asked: '$userQuery'. Real AI features are coming soon!";

    // --- Example of how you might call a Cloud Function (for later) ---
    /*
    if (mounted) { // Check if the widget is still in the tree
      setState(() { _isLoading = true; });
    }

    try {
      // final HttpsCallableResult result = await _callable.call(<String, dynamic>{
      //   'prompt': userQuery,
      // });
      // aiResponseText = result.data['response'] ?? "Error: No response data from AI.";
    } on FirebaseFunctionsException catch (e) {
      print('FirebaseFunctionsException: ${e.code} - ${e.message}');
      aiResponseText = "Error calling AI assistant. Code: ${e.code}";
    } catch (e) {
      print('Generic error calling AI: $e');
      aiResponseText = "An unexpected error occurred with the AI assistant.";
    }
    */
    // --- End of Cloud Function example ---

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: aiResponseText, isUserMessage: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luminas Chatbot'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(), // Or CircularProgressIndicator()
            ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: message.isUserMessage ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: message.isUserMessage ? const Radius.circular(16.0) : const Radius.circular(0),
            bottomRight: message.isUserMessage ? const Radius.circular(0) : const Radius.circular(16.0),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: message.isUserMessage ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 1,
            color: Colors.grey.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.send,
              onSubmitted: _isLoading ? null : _sendMessage,
              decoration: const InputDecoration(
                hintText: 'Ask something about culture...',
                border: InputBorder.none, 
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _sendMessage(_textController.text),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}