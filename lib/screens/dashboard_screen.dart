import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../models/recipe_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, child) {
        final totalRecipes = provider.recipes.length;
        final totalFavorites = provider.recipes.where((r) => r.isFavorite).length;
        final totalCategories = provider.recipes.map((r) => r.category).toSet().length;
        final recentRecipes = provider.recipes.take(5).toList();
        final favoriteRecipes = provider.recipes.where((r) => r.isFavorite).take(5).toList();

        return RefreshIndicator(
          onRefresh: provider.fetchRecipes,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(context, totalRecipes, totalFavorites, totalCategories),
                const SizedBox(height: 24),
                _buildHorizontalList(context, 'Resep Terbaru', recentRecipes),
                const SizedBox(height: 24),
                _buildHorizontalList(context, 'Resep Favorit', favoriteRecipes),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(BuildContext context, int recipes, int favorites, int categories) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatCard(context, 'Resep', recipes.toString(), Colors.blue),
          const SizedBox(width: 4),
          _buildStatCard(context, 'Favorit', favorites.toString(), Colors.red),
          const SizedBox(width: 4),
          _buildStatCard(context, 'Kategori', categories.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, String title, List<RecipeModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Belum ada resep.'),
              )
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 160,
                      child: RecipeCard(recipe: items[index], compact: true),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
