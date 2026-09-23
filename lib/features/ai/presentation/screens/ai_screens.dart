import 'package:flutter/material.dart';
import '../../../../core/widgets/bookhub_widgets.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final messages = <String>[];
  final input = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI assistant')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const EmptyState(
                    title: 'Ask your reading companion',
                    message:
                        'Explain a chapter, find a similar book, or create discussion questions.',
                    icon: Icons.auto_awesome,
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: messages
                        .map(
                          (text) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(text),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      hintText: 'Ask anything about your reading',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (input.text.trim().isEmpty) return;
                    setState(() {
                      messages.add(input.text.trim());
                      input.clear();
                    });
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AIVoiceAssistantScreen extends StatelessWidget {
  const AIVoiceAssistantScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI voice assistant')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.graphic_eq, size: 100, color: Colors.deepPurple),
          const SizedBox(height: 24),
          Text(
            'Tap to speak',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 30),
          FloatingActionButton(onPressed: () {}, child: const Icon(Icons.mic)),
        ],
      ),
    ),
  );
}
