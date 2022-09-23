import 'package:buzz/provider/preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';

// TextField controllers
final _backgroundController = TextEditingController();
late double _blurStrenth;
String? imagePath;

String backgroundImageButton = "Choose Image from Gallery";

class SettingsSheet extends ConsumerStatefulWidget {
  final Isar isar;
  const SettingsSheet({Key? key, required this.isar}) : super(key: key);

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _blurStrenth = ref.read(blurStrengthProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title TextField
        TextField(
          focusNode: FocusNode(),
          controller: _backgroundController,

          // Style
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Background url',
          ),

          // Action
          onEditingComplete: () {
            //_focusNode.nextFocus();
          },
        ),
        const Gap(16),
        SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            // Parameters
            label: Text(backgroundImageButton),
            icon: const Icon(Icons.image_outlined),

            // Actions
            onPressed: () async {
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                _backgroundController.clear();
                setState(() {
                  backgroundImageButton = image.name;
                  imagePath = image.path;
                });
              }
            },
          ),
        ),
        const Gap(16),
        const Text("Background blur strength"),
        Slider(
          value: _blurStrenth,
          max: 10,
          divisions: 10,
          onChanged: (value) => setState(
            () => _blurStrenth = value,
          ),
        ),
        const Gap(24),

        // Save button
        Row(
          children: [
            IconButton(
              // Pareameters
              icon: const Icon(Icons.restore),

              // Action
              onPressed: () {
                // Reset settings
                reset();

                // Clear text field
                _backgroundController.clear();

                // Close the sheet
                Navigator.pop(context);
              },
            ),
            IconButton(
              // Pareameters
              icon: const Icon(Icons.info_outline_rounded),

              // Action
              onPressed: () {
                // Show info
                showLicensePage(
                  context: context,
                  applicationName: "Buzz",
                  applicationLegalese: "Buzz is a simple todo list app.",
                  applicationVersion: "0.0.1",
                );
              },
            ),
            const Spacer(),
            FloatingActionButton.extended(
              // Parameters
              label: const Text("Save"),
              icon: const Icon(Icons.check_circle_outline_rounded),

              // Action
              onPressed: () {
                // Save settings
                save();

                // Clear text field
                _backgroundController.clear();

                // Close the sheet
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  // Save settings
  Future<void> save() async {
    // Save background
    if (_backgroundController.text.isNotEmpty) {
      await ref
          .read(backgroundProvider.notifier)
          .update(_backgroundController.text);
    }

    if (imagePath != null) {
      await ref.read(backgroundProvider.notifier).update(imagePath);
    }

    // Save blur strength
    await ref.read(blurStrengthProvider.notifier).update(_blurStrenth);
  }

  // Reset settings
  Future<void> reset() async {
    // Load default values
    final defaultBackground =
        ref.read(backgroundProvider.notifier).defaultValue;
    final defaultBlurStrength =
        ref.read(blurStrengthProvider.notifier).defaultValue;

    // Reset values
    await ref.read(backgroundProvider.notifier).update(defaultBackground);
    await ref.read(blurStrengthProvider.notifier).update(defaultBlurStrength);
  }
}
