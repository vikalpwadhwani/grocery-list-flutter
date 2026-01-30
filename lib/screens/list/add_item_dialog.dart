import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/items_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddItemDialog extends ConsumerStatefulWidget {
  final String listId;

  const AddItemDialog({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  bool _isLoading = false;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {

    if (_isLoading || _hasSubmitted) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _hasSubmitted = true;
      });


      final success = await ref.read(listDetailProvider(widget.listId).notifier).addItem(
        name: _nameController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 1,
        unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      );


      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          _hasSubmitted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_circle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Item Name',
                hint: 'e.g., Milk',
                controller: _nameController,
                prefixIcon: Icons.shopping_basket,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: 'Quantity',
                      hint: '1',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.numbers,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final qty = int.tryParse(value);
                          if (qty == null || qty < 1) {
                            return 'Invalid';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      label: 'Unit (optional)',
                      hint: 'e.g., liters, kg',
                      controller: _unitController,
                      prefixIcon: Icons.straighten,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Add',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _addItem,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}