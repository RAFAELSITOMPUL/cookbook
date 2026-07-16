import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'add_edit_recipe_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String _searchQuery = '';
  String _sortBy = 'Terbaru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari resep, kategori, atau bahan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          _buildSortAndFilter(),
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, provider, child) {
                var recipes = provider.searchRecipes(_searchQuery);
                
                // Sorting logic
                if (_sortBy == 'Nama A-Z') {
                  recipes.sort((a, b) => a.name.compareTo(b.name));
                } else if (_sortBy == 'Nama Z-A') {
                  recipes.sort((a, b) => b.name.compareTo(a.name));
                } else if (_sortBy == 'Terbaru') {
                  recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                } else if (_sortBy == 'Waktu Memasak') {
                  recipes.sort((a, b) => a.cookingTime.compareTo(b.cookingTime));
                }

                if (recipes.isEmpty) {
                  return const Center(child: Text('Tidak ada resep ditemukan.'));
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditRecipeScreen()));
        },
        label: const Text('Tambah Resep'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSortAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Urutkan: '),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _sortBy,
              items: ['Terbaru', 'Nama A-Z', 'Nama Z-A', 'Waktu Memasak']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
