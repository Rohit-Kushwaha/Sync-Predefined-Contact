import 'package:flutter/material.dart';

class ViewContactsScreen extends StatelessWidget {
  final List<Map<String, String>> contacts;

  const ViewContactsScreen({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Added Contacts"),
      ),
      body: contacts.isEmpty
          ? const Center(
              child: Text("No contacts added yet."),
            )
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact["name"] ?? ""),
                  subtitle: Text(contact["phone"] ?? ""),
                );
              },
            ),
    );
  }
}
