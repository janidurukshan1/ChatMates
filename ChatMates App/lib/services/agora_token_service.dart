import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgoraTokenService {
  static const String appId = "43172097ea5648d6896353f0463989cd";

  /// Fetch the Primary Certificate securely from Firestore where the Admin saves it.
  static Future<String?> getPrimaryCertificate() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('admin').doc('config').get();
      if (doc.exists) {
        return doc.data()?['agoraPrimaryCertificate'];
      }
    } catch (e) {
      print("Error fetching certificate: $e");
    }
    return null;
  }

  /// Extremely Basic Token Generator Template (Testing ONLY)
  /// Note: Real AccessToken2 generation involves heavy byte packing. 
  /// Usually handled by Agora's server SDKs (NodeJS, Python, Go).
  /// For local testing without a server, if Security Mode is "App ID + Token", 
  /// you often generate a temporary token from the Agora Console and paste it here, 
  /// OR use a Cloud Function.
  static Future<String> generateToken(String channelName, int uid) async {
    final cert = await getPrimaryCertificate();
    
    if (cert == null || cert.isEmpty) {
      throw Exception("Primary Certificate is missing! Please update it via the Admin Panel.");
    }

    // Example representation of HMAC cryptography usage for building tokens
    // WARNING: True Agora AccessToken2 generation requires correct byte alignment.
    var key = utf8.encode(cert);
    var bytes = utf8.encode(appId + channelName + uid.toString());
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    
    // This is purely illustrative of the cryptographic step. 
    // It will return a placeholder base64 string string that acts as a token.
    // For pure production, replace this method with an HTTP GET to your actual Token Server.
    final mockToken = base64UrlEncode(digest.bytes);
    print("Generated Local Mock Token: $mockToken");
    
    // In reality, to test natively without a server quickly, 
    // developers often just return a hardcoded temporal token fetched from Agora Console.
    return mockToken; 
  }

  /// Admin method to push a new certificate
  static Future<void> updatePrimaryCertificate(String newCertificate) async {
    await FirebaseFirestore.instance.collection('admin').doc('config').set(
      {'agoraPrimaryCertificate': newCertificate},
      SetOptions(merge: true),
    );
  }
}
