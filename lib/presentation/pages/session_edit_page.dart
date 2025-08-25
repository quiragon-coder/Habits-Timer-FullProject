import 'package:flutter/material.dart';

class SessionEditPage extends StatelessWidget {
  const SessionEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier session")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: "Heure de début")),
            const TextField(decoration: InputDecoration(labelText: "Heure de fin")),
            const TextField(decoration: InputDecoration(labelText: "Note")),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}