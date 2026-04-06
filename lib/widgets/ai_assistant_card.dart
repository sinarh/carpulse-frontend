import "dart:convert";
import "package:flutter/material.dart";
import "../services/api.dart";

class AIAssistantCard extends StatefulWidget {
  final int vehicleId;
  const AIAssistantCard({super.key, required this.vehicleId});

  @override
  State<AIAssistantCard> createState() => _AIAssistantCardState();
}

class _AIAssistantCardState extends State<AIAssistantCard> {
  final TextEditingController ctrl = TextEditingController();
  final List<Map<String, String>> messages = []; // {role: user|ai, text: ...}

  bool loading = false;
  String? error;

  Future<void> send() async {
    final text = ctrl.text.trim();
    if (text.isEmpty || loading) return;

    setState(() {
      error = null;
      loading = true;
      messages.add({"role": "user", "text": text});
      ctrl.clear();
    });

    final res = await Api.post(
      "/ai/chat/",
      {"vehicle_id": widget.vehicleId, "message": text},
      auth: true,
    );

    setState(() => loading = false);

    if (res.statusCode != 200) {
      setState(() => error = "AI request failed (${res.statusCode})");
      return;
    }

    final data = jsonDecode(res.body);
    final reply = (data["reply"] ?? "").toString();

    setState(() {
      messages.add({"role": "ai", "text": reply.isEmpty ? "No response." : reply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(blurRadius: 18, color: Color(0x11000000), offset: Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF5B5CF6)),
              SizedBox(width: 8),
              Text("AI Assistant", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),

          // Chat area
          if (messages.isEmpty)
            const Text(
              "Ask about your logs, maintenance, or what the data might mean.",
              style: TextStyle(color: Colors.black54),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  final isUser = m["role"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF5B5CF6) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        m["text"] ?? "",
                        style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 10),

          if (error != null) ...[
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
          ],

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => send(),
                  decoration: InputDecoration(
                    hintText: "Ask CarPulse...",
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
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B5CF6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
