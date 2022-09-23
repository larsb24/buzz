import 'dart:io';
import 'dart:ui';

import 'package:buzz/provider/preference_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class Background extends ConsumerWidget {
  final Isar isar;
  const Background({
    Key? key,
    required this.isar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blur = ref.read(blurStrengthProvider);
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: background(ref),
    );
  }

  Widget background(WidgetRef ref) {
    final imageSource = ref.read(backgroundProvider);
    if (imageSource.startsWith("/data/user/0/com.example.buzz/")) {
      return Image.file(
        File(imageSource),
        fit: BoxFit.cover,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageSource,
        fit: BoxFit.cover,
      );
    }
  }
}
