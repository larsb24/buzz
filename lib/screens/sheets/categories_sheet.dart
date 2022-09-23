import 'package:buzz/collections/category.dart';
import 'package:buzz/screens/home.dart';
import 'package:buzz/screens/sheets/add_edit_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class CategoriesSheet extends StatefulWidget {
  final Isar isar;
  const CategoriesSheet({Key? key, required this.isar}) : super(key: key);

  @override
  State<CategoriesSheet> createState() => _CategoriesSheetState();
}

class _CategoriesSheetState extends State<CategoriesSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: FutureBuilder(
            future: categoriesList(),
            builder: (context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return snapshot.data!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        FloatingActionButton.extended(
          // Parameters
          label: const Text("Create Category"),
          icon: const Icon(Icons.add_rounded),

          // Actions
          onPressed: () {
            Navigator.pop(context);
            showBottomActionSheet(
              context,
              AddEditCategorySheet(
                isar: widget.isar,
              ),
            );
          },
        )
      ],
    );
  }

  // Category list future
  Future<List<Category>> loadCategories() async {
    return widget.isar.categorys.where().findAll();
  }

  Future<Widget> categoriesList() async {
    // load list of tasks
    final List<Category> categories = await loadCategories();
    setState(() {});

    // build list of categories
    return ListView.builder(
      itemCount: categories.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(categories[index].name),
          onTap: () {
            Navigator.pop(context);
            showBottomActionSheet(
              context,
              AddEditCategorySheet(
                isar: widget.isar,
                category: categories[index],
              ),
            );
          },
        );
      },
    );
  }
}
