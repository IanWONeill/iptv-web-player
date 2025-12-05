import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      backgroundColor: const Color(0xFF0f0f1e),
      body: ListView(
        children: [
          _buildSection(
            'Playback',
            [
              _buildSwitchTile('Auto-play next episode', true),
              _buildSwitchTile('Remember playback position', true),
              _buildSwitchTile('Skip intro/recap', false),
            ],
          ),
          const Divider(color: Color(0xFF2a2a3e)),
          _buildSection(
            'CORS Proxy',
            [
              _buildInfoTile('Primary Proxy', 'Cloudflare Worker'),
              _buildInfoTile('Fallback Proxy', 'PHP Backend'),
              _buildInfoTile('Service Worker', 'Enabled'),
            ],
          ),
          const Divider(color: Color(0xFF2a2a3e)),
          _buildSection(
            'Interface',
            [
              _buildSwitchTile('Show channel logos', true),
              _buildSwitchTile('Show EPG info', true),
              _buildSwitchTile('Dark mode', true),
            ],
          ),
          const Divider(color: Color(0xFF2a2a3e)),
          _buildSection(
            'About',
            [
              _buildInfoTile('Version', '1.0.0'),
              _buildInfoTile('Build', 'Flutter Web'),
              _buildInfoTile('License', 'MIT License'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00d9ff),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: (bool newValue) {
        // TODO: Implement settings persistence
      },
      activeColor: const Color(0xFF00d9ff),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
