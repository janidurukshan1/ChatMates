import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _updateController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentSettings();
  }

  Future<void> _fetchCurrentSettings() async {
    final doc = await FirebaseFirestore.instance.collection('GlobalSettings').doc('config').get();
    if (doc.exists) {
      final data = doc.data()!;
      _updateController.text = data['notification'] ?? '';
      _versionController.text = data['version'] ?? '1.0.0';
      _aboutController.text = data['aboutUs'] ?? '';
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('GlobalSettings').doc('config').set({
        'notification': _updateController.text.trim(),
        'version': _versionController.text.trim(),
        'aboutUs': _aboutController.text.trim(),
      }, SetOptions(merge: true));
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Global Settings Updated successfully!')));
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent, // Distinguish admin area
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text("Push Global Notification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _updateController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Leave blank to clear banner"),
              ),
              const SizedBox(height: 24),
              
              const Text("App Version", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _versionController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              
              const Text("About Us Text", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _aboutController,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _saveSettings, 
                icon: const Icon(Icons.save),
                label: const Text("Save Global Settings"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              ),

              const Divider(height: 64),
              
              const Text("User Management", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const Text("Block or unblock specific users from accessing chats."),
              
              const SizedBox(height: 16),
              // StreamBuilder to show users
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No users found.");

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var userDoc = snapshot.data!.docs[index];
                      var data = userDoc.data() as Map<String, dynamic>? ?? {};
                      bool isBlocked = data['isBlocked'] ?? false;
                      String phone = data['phone'] ?? userDoc.id;

                      return ListTile(
                        title: Text(phone),
                        trailing: Switch(
                          value: isBlocked,
                          activeColor: Colors.red,
                          onChanged: (val) async {
                            await FirebaseFirestore.instance.collection('users').doc(userDoc.id).set({
                              'isBlocked': val
                            }, SetOptions(merge: true));
                          },
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
    );
  }
}
