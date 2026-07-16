import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../screens/recipe_detail_screen.dart';
import '../providers/recipe_provider.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final bool compact;

  const RecipeCard({super.key, required this.recipe, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)));
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildImage(),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: IconButton(
                      icon: Icon(
                        recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: recipe.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        Provider.of<RecipeProvider>(context, listen: false).toggleFavorite(recipe);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${recipe.category} • ${recipe.cookingTime}m • ${recipe.portions}p',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (recipe.image != null && recipe.image!.isNotEmpty) {
      if (recipe.image!.startsWith('http')) {
        return Image.network(
          recipe.image!,
          height: compact ? 120 : 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: compact ? 120 : 180,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        );
      }
      return Image.file(
        File(recipe.image!),
        height: compact ? 120 : 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: compact ? 120 : 180,
      width: double.infinity,
      color: Colors.deepOrange.withOpacity(0.1),
      child: const Icon(Icons.restaurant, size: 50, color: Colors.deepOrange),
    );
  }
}
