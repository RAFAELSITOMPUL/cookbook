import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../constants/app_constants.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: const Text('Semua'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
              ),
              ...AppConstants.categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              final recipes = _selectedCategory == null
                  ? provider.recipes
                  : provider.recipes.where((r) => r.category == _selectedCategory).toList();

              if (recipes.isEmpty) {
                return const Center(child: Text('Tidak ada resep di kategori ini.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(recipe: recipes[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
