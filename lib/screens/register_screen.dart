import "dart:convert";
import "package:flutter/material.dart";
import "../services/api.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  String? error;
  bool loading = false;

  Future<void> register() async {
    final email = emailCtrl.text.trim();
    final p1 = passCtrl.text;
    final p2 = pass2Ctrl.text;

    if (email.isEmpty || p1.isEmpty) {
      setState(() => error = "Email and password required");
      return;
    }
    if (p1 != p2) {
      setState(() => error = "Passwords do not match");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.post("/auth/register", {
      "email": email,
      "password": p1,
    });

    setState(() => loading = false);

    if (res.statusCode != 201 && res.statusCode != 200) {
      // show server error if present
      try {
        final data = jsonDecode(res.body);
        setState(() => error = data["error"]?.toString() ?? "Registration failed");
      } catch (_) {
        setState(() => error = "Registration failed");
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context); // back to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created. Please log in.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Create account"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              children: [
                _field(emailCtrl, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(passCtrl, "Password", Icons.lock_outline, obscure: true),
                const SizedBox(height: 12),
                _field(pass2Ctrl, "Confirm password", Icons.lock_outline, obscure: true),
                const SizedBox(height: 12),
                if (error != null) ...[
                  Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5CF6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(loading ? "Creating..." : "Create account"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool obscure = false, TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5B5CF6), width: 1.6),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0x11000000), offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}
