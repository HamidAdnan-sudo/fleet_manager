import 'package:flutter/material.dart';
import 'package:fleet_manager/core/constants/app_colors.dart';

/// Shows an existing truck's details, or acts as an "Add Truck" form
/// when [truck] is null. No location/GPS fields — plate, model, driver,
/// capacity and status only.
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
  late final TextEditingController _driverController;
  late final TextEditingController _capacityController;

  bool get _isEditing => widget.truck != null;

  @override
  void initState() {
    super.initState();
    final t = widget.truck;
    _plateController = TextEditingController(text: t?['plate'] ?? '');
    _modelController = TextEditingController(text: t?['model'] ?? '');
    _driverController = TextEditingController(text: t?['driver'] ?? '');
    _capacityController = TextEditingController(text: t?['capacity'] ?? '');
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _driverController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
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
                    label: Text(AppColors.statusLabel(
                        widget.truck!['status'] as String)),
                    backgroundColor: AppColors.statusColor(
                            widget.truck!['status'] as String)
                        .withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                        color: AppColors.statusColor(
                            widget.truck!['status'] as String)),
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
                TextFormField(
                  controller: _driverController,
                  decoration: const InputDecoration(
                    labelText: 'Assigned driver',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(_isEditing ? 'Save Changes' : 'Add Truck'),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
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
