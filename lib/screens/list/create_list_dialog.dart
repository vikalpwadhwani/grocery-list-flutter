import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/list_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateListDialog extends ConsumerStatefulWidget {
  const CreateListDialog({super.key});

  @override
  ConsumerState<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends ConsumerState<CreateListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {

    if (_isLoading) {
      return;
    }

    if (_hasSubmitted) {
      return;
    }

    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true;
        _hasSubmitted = true;
      });


      try {
        final response = await _apiClient.post(
          ApiConstants.lists,
          data: {'name': _nameController.text.trim()},
        );


        if (!mounted) {
          return;
        }

        if (response.data['success']) {
          final newList = GroceryListModel.fromJson(response.data['data']['list']);
          Navigator.of(context).pop(newList);
        } else {
          setState(() {
            _isLoading = false;
            _hasSubmitted = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasSubmitted = false;
        });
      }
    } else {
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
                      Icons.add_shopping_cart,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Create New List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'List Name',
                hint: 'e.g., Weekly Groceries',
                controller: _nameController,
                prefixIcon: Icons.list_alt,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a list name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: _isLoading ? null : () {
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Create',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _createList,
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