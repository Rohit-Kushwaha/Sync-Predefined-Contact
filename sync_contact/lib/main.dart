import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sync_contact/view_contact_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sync Contacts',
      home: ContactsManager(),
    );
  }
}

class ContactsManager extends StatefulWidget {
  const ContactsManager({super.key});

  @override
  State<ContactsManager> createState() => _ContactsManagerState();
}

class _ContactsManagerState extends State<ContactsManager> {
  ValueNotifier<bool> isAdding = ValueNotifier(false);
  ValueNotifier<bool> isDeleting = ValueNotifier(false);

  // Track deleting state
  final List<Map<String, String>> predefinedContacts = [
    {"name": "Alice", "phone": "1234567890"},
    {"name": "Bob", "phone": "9876543210"},
    {"name": "Charlie", "phone": "5556667777"},
    {"name": "Diana", "phone": "4445556666"},
    {"name": "Eve", "phone": "3334445555"},
  ];

  final List<Map<String, String>> addedContacts = [];

  // Function to request contacts permission
  Future<bool> requestContactsPermission() async {
    PermissionStatus status = await Permission.contacts.request();
    return status.isGranted;
  }

  // Function to add predefined contacts
  Future<void> addContacts() async {
    isAdding.value = true;
    if (await requestContactsPermission()) {
      for (var contactData in predefinedContacts) {
        final contact = Contact()
          ..name.first = contactData["name"]!
          ..phones = [Phone(contactData["phone"]!)];

        await FlutterContacts.insertContact(contact);
        addedContacts.add(contactData);
        debugPrint("Added contact: ${contactData["name"]}");
      }
      debugPrint("All contacts added successfully");
    } else {
      debugPrint("Permission denied to add contacts");
    }
    isAdding.value = false;
  }

  // Function to delete predefined contacts
  Future<void> deleteContacts() async {
    isDeleting.value = true;

    if (await requestContactsPermission()) {
      addedContacts.clear();
      for (var contactData in predefinedContacts) {
        final name = contactData["name"]!;
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        for (var contact in contacts) {
          if (contact.name.first == name) {
            await FlutterContacts.deleteContact(contact);
            print("Deleted contact: $name");
          }
        }
      }
      debugPrint("All matching contacts deleted successfully");
    } else {
      debugPrint("Permission denied to delete contacts");
    }
    isDeleting.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts Manager"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: isAdding,
              builder: (context, adding, child) {
                return ElevatedButton(
                  onPressed: adding ? null : addContacts,
                  child: adding
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Add Contacts"),
                );
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: isDeleting,
              builder: (context, deleting, child) {
                return ElevatedButton(
                  onPressed: deleting ? null : deleteContacts,
                  child: deleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Delete Contacts"),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewContactsScreen(contacts: addedContacts),
                  ),
                );
              },
              child: const Text("View Added Contacts"),
            ),
          ],
        ),
      ),
    );
  }
}
