import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme_provider.dart';
import 'admin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _aboutUsText = "Loading...";
  String _appVersion = "1.0.0";
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _fetchGlobalSettings();
  }

  void _checkAdminStatus() {
    final user = FirebaseAuth.instance.currentUser;
    // Specific condition given by User
    if (user != null && user.phoneNumber == "+94760900934") {
      setState(() {
        _isAdmin = true;
      });
    }
  }

  Future<void> _fetchGlobalSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('GlobalSettings').doc('config').get();
      if (doc.exists) {
        if(mounted) {
          setState(() {
            _aboutUsText = doc.data()?['aboutUs'] ?? "About Us details currently unavailable.";
            _appVersion = doc.data()?['version'] ?? "1.0.0";
          });
        }
      } else {
        setState(() => _aboutUsText = "No About Us configured.");
      }
    } catch (e) {
      if(mounted) setState(() => _aboutUsText = "Error loading about us.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final headerStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SwitchListTile(
                  title: const Text('Theme (Black / White)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(themeProvider.isDarkMode ? 'Black Theme' : 'White Theme'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                ),
                const Divider(height: 32),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text('Font Color', style: headerStyle),
                ),
                Wrap(
                  children: CustomFontColor.values.map((color) {
                    return RadioListTile<CustomFontColor>(
                      title: Text(color.name[0].toUpperCase() + color.name.substring(1)),
                      value: color,
                      groupValue: themeProvider.fontColor,
                      onChanged: (value) {
                        if (value != null) themeProvider.setFontColor(value);
                      },
                    );
                  }).toList(),
                ),
                const Divider(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text('Font Type', style: headerStyle),
                ),
                Wrap(
                  children: CustomFontFamily.values.map((family) {
                    return RadioListTile<CustomFontFamily>(
                      title: Text(family.name[0].toUpperCase() + family.name.substring(1)),
                      value: family,
                      groupValue: themeProvider.fontFamily,
                      onChanged: (value) {
                        if (value != null) themeProvider.setFontFamily(value);
                      },
                    );
                  }).toList(),
                ),

                const Divider(height: 32),

                // HIDDEN ADMIN PANEL
                if (_isAdmin)
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.red),
                    title: const Text("Admin Dashboard", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Manage Global Settings & Users"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
                    },
                  ),
                  
                const Divider(height: 32),
                
                // About Us
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("About Us"),
                  subtitle: Text(_aboutUsText),
                ),
                ListTile(
                  leading: const Icon(Icons.verified),
                  title: const Text("App Version"),
                  subtitle: Text(_appVersion),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'Developed by AiLK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
