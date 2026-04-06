import "dart:convert";
import "package:flutter/material.dart";
import "../services/api.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;
  bool loading = false;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    final res = await Api.post("/auth/login", {
      "email": emailCtrl.text.trim(),
      "password": passCtrl.text,
    });

    setState(() => loading = false);

    if (res.statusCode != 200) {
      setState(() => error = "Invalid email or password");
      return;
    }

    final data = jsonDecode(res.body);
    await Api.saveToken(data["access_token"]);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/vehicles");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFF3F4F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Big centered logo
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B5CF6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 18,
                          color: Color(0x22000000),
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/logo.png", // change if you kept lib/assets
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.directions_car, color: Colors.white, size: 42),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SizedBox(height: 6),
                  const Text(
                    "Sign in to monitor your vehicle health",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  // Login card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 18,
                          color: Color(0x11000000),
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          controller: emailCtrl,
                          label: "Email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: passCtrl,
                          label: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 14),
                        if (error != null) ...[
                          Text(error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B5CF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(loading ? "Signing in..." : "Sign In"),
                          ),
                        ),
                        TextButton(
                            onPressed: () => Navigator.pushNamed(context, "/register"),
                            child: const Text("Create an account"),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Copyright Sina Rafizadeh Hamedani #100373524",
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
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
}
