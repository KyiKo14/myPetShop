// lib/Screen/contact_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Contact Us',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.grey, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.pets, color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'Get in Touch',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We'd love to hear from you. Our team is always here to help.",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Contact Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            _contactCard(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: '+95 9 123 456 789',
              onTap: () => _launch('tel:+959123456789'),
            ),
            _contactCard(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'support@mypetshop.com',
              onTap: () => _launch('mailto:support@mypetshop.com'),
            ),
            _contactCard(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: 'No. 9, SeikKanThar Street, Yangon, Myanmar',
              onTap: () => _launch(
                  'https://maps.google.com/?q=Yangon,Myanmar'),
            ),
            _contactCard(
              icon: Icons.access_time_outlined,
              label: 'Business Hours',
              value: 'Mon – Sat: 9:00 AM – 6:00 PM',
              onTap: null,
            ),

            const SizedBox(height: 24),
            const Text(
              'Send a Message',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _MessageForm(),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _MessageForm extends StatefulWidget {
  @override
  State<_MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<_MessageForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _msgCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate send
    setState(() => _sending = false);
    _nameCtrl.clear();
    _emailCtrl.clear();
    _msgCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent! We will reply soon.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _input(_nameCtrl, 'Your Name', Icons.person_outline),
          const SizedBox(height: 12),
          _input(_emailCtrl, 'Email Address', Icons.email_outlined),
          const SizedBox(height: 12),
          _input(_msgCtrl, 'Your Message', Icons.message_outlined,
              maxLines: 4),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Send Message',
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey.shade400, size: 20) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple)),
      ),
    );
  }
}