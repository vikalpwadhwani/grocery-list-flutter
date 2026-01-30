import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/item_model.dart';
import '../../providers/items_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditItemDialog extends ConsumerStatefulWidget {
  final String listId;
  final ItemModel item;

  const EditItemDialog({
    super.key,
    required this.listId,
    required this.item,
  });

  @override
  ConsumerState<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends ConsumerState<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
    _unitController = TextEditingController(text: widget.item.unit ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await ref.read(listDetailProvider(widget.listId).notifier).updateItem(
            itemId: widget.item.id,
            name: _nameController.text.trim(),
            quantity: int.tryParse(_quantityController.text) ?? 1,
            unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
          );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.of(context).pop();
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Name field
              CustomTextField(
                label: 'Item Name',
                hint: 'e.g., Milk',
                controller: _nameController,
                prefixIcon: Icons.shopping_basket,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Quantity and Unit
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
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _updateItem,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Save',
                      isLoading: _isLoading,
                      onPressed: _updateItem,
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