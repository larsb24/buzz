import 'package:buzz/collections/category.dart';
import 'package:isar/isar.dart';

part "task.g.dart";

@Collection()
class Task {
  Id id = Isar.autoIncrement;

  late String title;

  @Index()
  late String reminder;

  @Index()
  late String uuid;

  @Index()
  final IsarLink<Category> category = IsarLink<Category>();
}
