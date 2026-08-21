import 'package:flutter/material.dart';
import 'package:fleet_manager/core/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _maintenanceAlerts = true;

  Future<void> _changePassword() async {
    final controller = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
            helperText: 'Minimum 6 characters',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (newPassword == null || newPassword.length < 6) {
      if (newPassword != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')),
        );
      }
      return;
    }

    try {
      await SupabaseService.client.auth.updateUser(UserAttributes(password: newPassword));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('Trip status updates'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          SwitchListTile(
            title: const Text('Maintenance alerts'),
            subtitle: const Text('Reminders for scheduled servicing'),
            value: _maintenanceAlerts,
            onChanged: (v) => setState(() => _maintenanceAlerts = v),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Change password'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _changePassword,
          ),
        ],
      ),
    );
  }
}
