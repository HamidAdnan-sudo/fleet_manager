import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';
import 'package:fleet_manager/core/services/fleet_service.dart';
import 'package:fleet_manager/core/supabase_service.dart';

/// Shows an existing trip's details, or acts as a "Log Trip" form when
/// [trip] is null. Pops `true` when a save/update succeeds so the
/// caller (TripsScreen) knows to refresh its list.
class TripDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? trip;
  const TripDetailScreen({super.key, this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _originController;
  late final TextEditingController _destinationController;
  late final TextEditingController _cargoController;

  String _status = 'pending';
  String? _truckId;
  bool _saving = false;
  bool _loadingTrucks = true;
  List<Map<String, dynamic>> _trucks = [];

  bool get _isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    _originController = TextEditingController(text: t?['origin'] as String? ?? '');
    _destinationController = TextEditingController(text: t?['destination'] as String? ?? '');
    _cargoController = TextEditingController(text: t?['cargo'] as String? ?? '');
    _status = (t?['status'] as String?) ?? 'pending';
    _truckId = t?['truck_id'] as String?;
    _loadTrucks();
  }

  Future<void> _loadTrucks() async {
    try {
      final trucks = await FleetService.fetchTrucks();
      if (!mounted) return;
      setState(() {
        _trucks = trucks;
        _loadingTrucks = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTrucks = false);
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _save({String? overrideStatus}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      final values = <String, dynamic>{
        if (_isEditing) 'id': widget.trip!['id'],
        'truck_id': _truckId,
        'origin': _originController.text.trim(),
        'destination': _destinationController.text.trim(),
        'cargo': _cargoController.text.trim(),
        'status': overrideStatus ?? _status,
        if (!_isEditing) 'created_by': userId,
        if (!_isEditing && (overrideStatus ?? _status) == 'in_transit')
          'started_at': DateTime.now().toIso8601String(),
      };
      await FleetService.upsertTrip(values);
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save trip: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? (widget.trip!['route'] as String? ?? 'Trip') : 'Log a Trip'),
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
                  Row(
                    children: [
                      Chip(
                        label: Text(AppColors.statusLabel(_status)),
                        backgroundColor: AppColors.statusColor(_status).withValues(alpha: 0.15),
                        labelStyle: TextStyle(color: AppColors.statusColor(_status)),
                        side: BorderSide.none,
                      ),
                      const Spacer(),
                      Text(widget.trip!['date'] as String? ?? '',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField<String?>(
                  initialValue: _truckId,
                  decoration: InputDecoration(
                    labelText: 'Truck',
                    prefixIcon: const Icon(Icons.local_shipping_outlined),
                    helperText: _loadingTrucks ? 'Loading trucks…' : null,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Unassigned')),
                    ..._trucks.map((t) => DropdownMenuItem<String?>(
                          value: t['id'] as String,
                          child: Text(t['plate'] as String? ?? 'Truck'),
                        )),
                  ],
                  onChanged: (v) => setState(() => _truckId = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _originController,
                  decoration: const InputDecoration(
                    labelText: 'Origin',
                    prefixIcon: Icon(Icons.trip_origin_rounded),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cargoController,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'in_transit', child: Text('In Transit')),
                    DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                    DropdownMenuItem(value: 'delayed', child: Text('Delayed')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _saving ? null : () => _save(),
                  child: _saving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Log Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
