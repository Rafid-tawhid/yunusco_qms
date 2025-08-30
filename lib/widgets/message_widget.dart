import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  String? _selectedPredefinedMessage;

  final List<String> _predefinedMessages = [
    "I can't log in to my account",
    "How do I reset my password?",
    "Where can I find my order history?",
    "The app keeps crashing",
    "I need help with payment",
    "Other issue...",
  ];

  void _sendMessage() {
    final message = _selectedPredefinedMessage ?? _messageController.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _selectedPredefinedMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Support')),
      body: Column(
        children: [
          // Predefined messages section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select an option or type your message:',
              style: TextStyle(fontSize: 16),
            ),
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children:
                _predefinedMessages
                    .map(
                      (msg) => ChoiceChip(
                        backgroundColor: Colors.white,
                        label: Text(msg),
                        selected: _selectedPredefinedMessage == msg,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPredefinedMessage = selected ? msg : null;
                            if (selected) _messageController.clear();
                          });
                        },
                      ),
                    )
                    .toList(),
          ),

          // Message history
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_messages[index]),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText:
                          _selectedPredefinedMessage != null
                              ? 'Selected: $_selectedPredefinedMessage'
                              : 'Type your message...',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        setState(() {
                          _selectedPredefinedMessage = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
