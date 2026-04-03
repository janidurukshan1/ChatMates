import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatMates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: currentUserId == null 
        ? const Center(child: Text("Please login first"))
        : Column(
            children: [
              // GLOBAL NOTIFICATION STREAM
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('GlobalSettings').doc('config').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final notification = data['notification'] as String?;
                    
                    if (notification != null && notification.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text(
                          "System Update: $notification",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // CHATS STREAM
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('users', arrayContains: currentUserId)
                      .orderBy('lastMessageTime', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No active chats yet.\nStart a new one!"),
                      );
                    }

                    final chatDocs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: chatDocs.length,
                      itemBuilder: (context, index) {
                        final chatData = chatDocs[index].data() as Map<String, dynamic>;
                        final List<dynamic> users = chatData['users'] ?? [];
                        final otherUserId = users.firstWhere(
                          (user) => user != currentUserId,
                          orElse: () => "Unknown",
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text("User: $otherUserId"),
                          subtitle: Text(
                            chatData['lastMessage'] ?? "No messages",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatId: chatDocs[index].id,
                                  recipientId: otherUserId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context),
        child: const Icon(Icons.chat),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final TextEditingController newChatController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Start New Chat"),
          content: TextField(
            controller: newChatController,
            decoration: const InputDecoration(hintText: "Enter user phone or ID"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic to create a new chat sequence goes here
                Navigator.pop(context);
              },
              child: const Text("Start"),
            )
          ],
        );
      }
    );
  }
}
