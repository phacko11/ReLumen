// lib/screens/ai_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart'; 

class ChatMessage {
  final String text;
  final bool isUserMessage;
  ChatMessage({required this.text, required this.isUserMessage});
}

class AiAssistantScreen extends StatefulWidget {
  final String? initialPrompt;

  const AiAssistantScreen({super.key, this.initialPrompt});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  GenerativeModel? _model;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final systemInstruction = Content.system(
        "You are Luminas, a friendly and knowledgeable AI assistant from the ReLumen app. "
        "You specialize in Vietnamese culture, history, traditions, and unique local experiences. "
        "Please provide engaging, informative, and respectful answers. "
        "Keep your responses concise and focused on the cultural aspect of the query. "
        "If asked about non-cultural topics, politely steer the conversation back to culture or state your specialization."
    );

    if (geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE_FOR_LOCAL_TESTING_ONLY') {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: geminiApiKey,
        systemInstruction: systemInstruction,
        generationConfig: GenerationConfig(
          // temperature: 0.7, // Optional: Adjust creativity
          // maxOutputTokens: 2048, // Optional: Adjust response length
        )
      );
      print("Luminas AI Model initialized WITH System Instruction.");
    } else {
      print("GEMINI API KEY IS MISSING OR IS THE DEFAULT PLACEHOLDER! Luminas AI features will be limited.");
      // Optionally, you could add a message to the chat list here to inform the user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(text: "Luminas AI is not configured due to a missing API key. Please contact support.", isUserMessage: false));
          });
        }
      });
    }

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      // Add initial prompt to messages and send it
      WidgetsBinding.instance.addPostFrameCallback((_) { // Ensure setState is called after build
         if(mounted) {
            _textController.text = widget.initialPrompt!; // Optionally fill text field
            _sendMessage(widget.initialPrompt!);
         }
      });
    }
  }

  void _scrollToBottom() {
    // Ensure scroll controller is attached to a scroll view
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent, // For reverse: true, minScrollExtent is the bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();

    if (!mounted) return;
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUserMessage: true)); // Insert at beginning for reverse list
      _isLoading = true;
    });
    _scrollToBottom();
    _getAiResponse(text);
  }

  Future<void> _getAiResponse(String userQuery) async {
    if (_model == null) {
      if (mounted) {
        setState(() {
          _messages.insert(0, ChatMessage(text: "Luminas AI is not configured. Missing API Key.", isUserMessage: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
      return;
    }
    // No need to set _isLoading = true here as it's done in _sendMessage

    print("Sending prompt to Gemini: $userQuery");
    String aiResponseText;

    try {
      final content = [Content.text(userQuery)];
      GenerateContentResponse response = await _model!.generateContent(content);
      aiResponseText = response.text ?? "Sorry, I could not generate a response. Please try again.";
      print("Gemini response: $aiResponseText");
    } catch (e) {
      print('Error calling Gemini API: $e');
      aiResponseText = "Sorry, Luminas is having trouble connecting. Please try again later.";
      if (e.toString().toLowerCase().contains("api key not valid")) {
        aiResponseText = "Luminas AI key is not valid. Please check configuration.";
      }
    }

    if (mounted) {
      setState(() {
        _messages.insert(0, ChatMessage(text: aiResponseText, isUserMessage: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luminas AI Assistant'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Assign controller
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Messages grow from the bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // No need to reverse index manually if ListView.reverse is true
                final message = _messages[index]; 
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
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
          color: message.isUserMessage ? Theme.of(context).primaryColor.withOpacity(0.9) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18.0),
            topRight: const Radius.circular(18.0),
            bottomLeft: message.isUserMessage ? const Radius.circular(18.0) : const Radius.circular(4.0),
            bottomRight: message.isUserMessage ? const Radius.circular(4.0) : const Radius.circular(18.0),
          ),
           boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: Offset(0, 1))
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(color: message.isUserMessage ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Use cardColor for background
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 5,
            color: Colors.grey.withOpacity(0.15),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.send,
              onSubmitted: _isLoading ? null : (value) => _sendMessage(value), // Send on keyboard send action
              decoration: const InputDecoration(
                hintText: 'Ask Luminas about culture...',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                filled: false, // Make it transparent or match container
              ),
              minLines: 1,
              maxLines: 5, // Allow multi-line input
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded),
            onPressed: _isLoading ? null : () => _sendMessage(_textController.text),
            color: Theme.of(context).primaryColor,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}