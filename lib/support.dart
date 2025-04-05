import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }

  void _callHelpline(String phoneNumber) async {
    final Uri uri = Uri.parse("tel:$phoneNumber");
    if (!await launchUrl(uri)) {
      throw "Could not call $phoneNumber";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crisis Support',
          style: TextStyle(
            fontFamily: 'FunnelSans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 74, 98, 138),
        elevation: 4,
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 20),
            _buildSupportOptions(),
            const SizedBox(height: 20),
            _buildResourcesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 190, 209, 232),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoText("💙 You're Not Alone", "PCOS can be challenging, but support is available."),
          const SizedBox(height: 8),
          _infoText("📞 Need Urgent Help?", "Contact a crisis counselor below."),
        ],
      ),
    );
  }

  Widget _infoText(String title, String value) {
    return RichText(
      text: TextSpan(
        text: "$title\n",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 74, 98, 138)),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return Column(
      children: [
        _buildSupportCard(
          icon: Icons.call,
          title: "PCOS Helpline",
          subtitle: "Connect with a specialist",
          onTap: () => _callHelpline("1800-123-4567"),
        ),
        _buildSupportCard(
          icon: Icons.chat_bubble_outline,
          title: "Text a Counselor",
          subtitle: "Anonymous mental health chat",
          onTap: () => _launchURL("https://www.mentalhealthchat.com"),
        ),
        _buildSupportCard(
          icon: Icons.groups,
          title: "Join Support Groups",
          subtitle: "Find local & online PCOS groups",
          onTap: () => _launchURL("https://www.pcoscommunity.com"),
        ),
      ],
    );
  }

  Widget _buildSupportCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: const Color.fromARGB(255, 190, 209, 232),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 74, 98, 138),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'FunnelSans',
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📚 Helpful Resources",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'FunnelSans',
            color: Color.fromARGB(255, 74, 98, 138),
          ),
        ),
        const SizedBox(height: 10),
        _buildResourceLink("PCOS & Mental Health", "https://www.pcosmentalhealth.com"),
        _buildResourceLink("Exercise & PCOS", "https://www.pcosworkouts.com"),
        _buildResourceLink("Healthy Eating Guide", "https://www.pcosdietplan.com"),
      ],
    );
  }

  Widget _buildResourceLink(String title, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            const Icon(Icons.open_in_new, color: Color.fromARGB(255, 74, 98, 138)),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
