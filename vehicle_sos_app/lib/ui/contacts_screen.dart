import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ContactsScreen extends StatelessWidget {
  final List<Map<String, String>> emergencyContacts;
  final VoidCallback addNewContact;
  final Function(Map<String, String>) callContact;
  final Function(Map<String, String>) messageContact;
  final Function(String id, String name, String phone, String relation) updateContact;
  final Function(String id) deleteContact;

  const ContactsScreen({
    super.key,
    required this.emergencyContacts,
    required this.addNewContact,
    required this.callContact,
    required this.messageContact,
    required this.updateContact,
    required this.deleteContact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.user_plus),
            onPressed: addNewContact,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildContactCard(context, contact),
          );
        },
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Map<String, String> contact) {
    bool isRemovable = contact['removable'] == 'true';
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(LucideIcons.user, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(contact['relation']!, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.phone, color: Colors.green),
                onPressed: () => callContact(contact),
              ),
              IconButton(
                icon: const Icon(LucideIcons.message_square, color: Colors.blue),
                onPressed: () => messageContact(contact),
              ),
              if (isRemovable)
                IconButton(
                  icon: const Icon(LucideIcons.user_pen, color: Colors.orange),
                  onPressed: () => _showEditContactDialog(context, contact),
                ),
              if (isRemovable)
                IconButton(
                  icon: const Icon(LucideIcons.trash, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(context, contact['id']!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(BuildContext context, Map<String, String> contact) {
    final TextEditingController nameController = TextEditingController(text: contact['name']);
    final TextEditingController phoneController = TextEditingController(text: contact['phone']);
    final TextEditingController relationController = TextEditingController(text: contact['relation']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: relationController,
                decoration: const InputDecoration(labelText: 'Relation'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                updateContact(
                  contact['id']!,
                  nameController.text,
                  phoneController.text,
                  relationController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String contactId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: const Text('Are you sure you want to delete this contact?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteContact(contactId);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}