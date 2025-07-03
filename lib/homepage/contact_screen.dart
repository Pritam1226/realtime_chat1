import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactScreen extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Contact')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) {
            // Don't show current user in contact list
            return doc.id != currentUser?.uid;
          }).toList();

          if (users.isEmpty) return Center(child: Text('No other users found.'));

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (ctx, index) {
              final user = users[index];
              final name = user['name'] ?? 'Unnamed';
              final profileImage = user['profileImageURL'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage.isEmpty ? Icon(Icons.person) : null,
                ),
                title: Text(name),
                onTap: () {
                  Navigator.pop(context, user.id); // Pass selected user ID
                  // You can also navigate to a private chat screen directly here
                },
              );
            },
          );
        },
      ),
    );
  }
}
