import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/feedback/app_bottom_sheet.dart';
import '../../../core/widgets/inputs/app_text_field.dart';

/// Shows a name-edit sheet pre-filled with [currentName] and returns the
/// trimmed new name, or `null` if dismissed/unchanged.
Future<String?> showEditNameSheet({
  required BuildContext context,
  required String currentName,
}) {
  return showAppBottomSheet<String>(
    context: context,
    title: 'Edit Name',
    builder: (context) => _EditNameForm(currentName: currentName),
  );
}

class _EditNameForm extends StatefulWidget {
  final String currentName;

  const _EditNameForm({required this.currentName});

  @override
  State<_EditNameForm> createState() => _EditNameFormState();
}

class _EditNameFormState extends State<_EditNameForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.currentName);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final trimmed = _nameController.text.trim();
    Navigator.of(context).pop(trimmed == widget.currentName ? null : trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Full name',
            controller: _nameController,
            textInputAction: TextInputAction.done,
            validator: (value) => Validators.required(value, fieldName: 'Name'),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(label: 'Save', onPressed: _submit),
        ],
      ),
    );
  }
}
