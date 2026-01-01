import 'package:flutter/material.dart';
import '../services/request_service.dart';
import '../services/storage_service.dart';
import '../models/petrol_request.dart';

class CreateRequestDialog extends StatefulWidget {
  final double latitude;
  final double longitude;
  final VoidCallback onRequestCreated;

  const CreateRequestDialog({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onRequestCreated,
  });

  @override
  State<CreateRequestDialog> createState() => _CreateRequestDialogState();
}

class _CreateRequestDialogState extends State<CreateRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _quantityController = TextEditingController();
  String _urgency = 'normal';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _createRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final quantity = _quantityController.text.isNotEmpty
          ? double.tryParse(_quantityController.text)
          : null;

      // Create request data
      final requestData = CreateRequestData(
        userId: userId,
        latitude: widget.latitude,
        longitude: widget.longitude,
        message: _messageController.text.trim(),
        quantityLiters: quantity,
        urgency: _urgency,
        userRole: 'needy',
      );

      await RequestService.createRequest(requestData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRequestCreated();
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Petrol Request'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message *',
                  hintText: 'Describe your request (e.g., Need 20 liters of petrol)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (Liters)',
                  hintText: 'Optional: Enter quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              const Text(
                'Urgency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Normal'),
                      selected: _urgency == 'normal',
                      onSelected: _isLoading
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() => _urgency = 'normal');
                              }
                            },
                      selectedColor: const Color(0xFFFF6B35),
                      labelStyle: TextStyle(
                        color: _urgency == 'normal' ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Urgent'),
                      selected: _urgency == 'urgent',
                      onSelected: _isLoading
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() => _urgency = 'urgent');
                              }
                            },
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(
                        color: _urgency == 'urgent' ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create Request'),
        ),
      ],
    );
  }
}

