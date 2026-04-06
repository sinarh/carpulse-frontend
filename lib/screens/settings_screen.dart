import "package:flutter/material.dart";
import "../services/api.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await Api.clearToken(); // we’ll add this if you don’t have it yet
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Log out"),
              subtitle: const Text("Sign out of your account on this device"),
              onTap: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(blurRadius: 18, color: Color(0x11000000), offset: Offset(0, 10))
        ],
      ),
      child: child,
    );
  }
}
