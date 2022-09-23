import 'package:buzz/const/const.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences_riverpod/shared_preferences_riverpod.dart';

late final StateNotifierProvider<PrefNotifier, String> backgroundProvider;

late final StateNotifierProvider<PrefNotifier, double> blurStrengthProvider;

void initProviders() {
  backgroundProvider = createPrefProvider<String>(
    prefs: (_) => prefs,
    prefKey: "background",
    defaultValue: "https://t.ly/TrQb",
  );

  blurStrengthProvider = createPrefProvider<double>(
    prefs: (_) => prefs,
    prefKey: "blurStrength",
    defaultValue: 10,
  );
}
