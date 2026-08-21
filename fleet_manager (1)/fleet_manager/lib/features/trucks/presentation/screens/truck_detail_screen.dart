import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/services/fleet_service.dart';
import 'package:fleet_manager/core/supabase_service.dart';

/// Shows an existing truck's details, or acts as an "Add Truck" form
/// when [truck] is null. Pops `true` when a save/update succeeds so the
/// caller (TrucksScreen) knows to refresh its list.
class TruckDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? truck;
  const TruckDetailScreen({super.key, this.truck});

  @override
  State<TruckDetailScreen> createState() => _TruckDetailScreenState();
}

class _TruckDetailScreenState extends State<TruckDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _modelController;
  late final TextEditingController _capacityController;

  String _status = 'idle';
  String? _driverId;
  bool _saving = false;
  bool _loadingDrivers = true;
  List<Map<String, dynamic>> _drivers = [];

  bool get _isEditing => widget.truck != null;

  @override
  void initState() {
    super.initState();
    final t = widget.truck;
    _plateController = TextEditingController(text: t?['plate'] as String? ?? '');
    _modelController = TextEditingController(text: t?['model'] as String? ?? '');
    _capacityController = TextEditingController(text: t?['capacity'] as String? ?? '');
    _status = (t?['status'] as String?) ?? 'idle';
    _driverId = t?['driver_id'] as String?;
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      final drivers = await FleetService.fetchDrivers();
      if (!mounted) return;
      setState(() {
        _drivers = drivers;
        _loadingDrivers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDrivers = false);
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _save({String? overrideStatus}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      final values = <String, dynamic>{
        if (_isEditing) 'id': widget.truck!['id'],
        'plate': _plateController.text.trim(),
        'model': _modelController.text.trim(),
        'driver_id': _driverId,
        'capacity': int.tryParse(_capacityController.text.trim()),
        'status': overrideStatus ?? _status,
        if (!_isEditing) 'created_by': userId,
      };
      await FleetService.upsertTruck(values);
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save truck: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Truck Details' : 'Add Truck'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing) ...[
                  Chip(
                    label: Text(AppColors.statusLabel(_status)),
                    backgroundColor: AppColors.statusColor(_status).withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: AppColors.statusColor(_status)),
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _plateController,
                  decoration: const InputDecoration(
                    labelText: 'Number plate',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Truck model',
                    prefixIcon: Icon(Icons.local_shipping_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Load capacity (tonnes)',
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'idle', child: Text('Idle')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: _driverId,
                  decoration: InputDecoration(
                    labelText: 'Assigned driver',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    helperText: _loadingDrivers ? 'Loading drivers…' : null,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Unassigned')),
                    ..._drivers.map((d) => DropdownMenuItem<String?>(
                          value: d['id'] as String,
                          child: Text((d['full_name'] as String?) ?? (d['email'] as String? ?? 'Driver')),
                        )),
                  ],
                  onChanged: (v) => setState(() => _driverId = v),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _saving ? null : () => _save(),
                  child: _saving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Add Truck'),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : () => _save(overrideStatus: 'maintenance'),
                    icon: const Icon(Icons.build_outlined),
                    label: const Text('Log Maintenance'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
