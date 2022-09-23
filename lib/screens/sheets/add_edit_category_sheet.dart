import 'package:buzz/collections/category.dart';
import 'package:buzz/screens/home.dart';
import 'package:buzz/screens/sheets/add_edit_task_sheet.dart';
import 'package:buzz/screens/sheets/categories_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:isar/isar.dart';

final TextEditingController _nameController = TextEditingController();

class AddEditCategorySheet extends StatefulWidget {
  final Isar isar;
  final Category? category;
  const AddEditCategorySheet({
    Key? key,
    required this.isar,
    this.category,
  }) : super(key: key);

  @override
  State<AddEditCategorySheet> createState() => _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends State<AddEditCategorySheet> {
  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          // Parameters
          autofocus: true,
          controller: _nameController,

          // Style
          decoration: textFieldBoder("Name"),
        ),
        const Gap(24),
        FloatingActionButton.extended(
          // Parameters
          label: const Text("Save"),
          icon: const Icon(Icons.check_circle_outline_rounded),

          // Actions
          onPressed: () {
            // Save category
            if (_nameController.text.isNotEmpty) {
              save();
            }
            // Clear text field
            _nameController.clear();

            // Close sheet
            Navigator.pop(context);
            showBottomActionSheet(
              context,
              CategoriesSheet(
                isar: widget.isar,
              ),
            );
          },
        )
      ],
    );
  }

  Future<void> save() async {
    // Create the category
    final Category category = Category()
      ..name = _nameController.text
      ..id = widget.category?.id ?? Isar.autoIncrement;

    // Save the category
    await widget.isar.writeTxn(() async => widget.isar.categorys.put(category));
  }
}
