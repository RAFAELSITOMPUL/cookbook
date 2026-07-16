import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../utils/pdf_helper.dart';
import 'add_edit_recipe_screen.dart';

import 'cooking_mode_screen.dart';
import '../database/database_helper.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(recipe.isFavorite ? Icons.favorite : Icons.favorite_border, color: recipe.isFavorite ? Colors.red : null),
                onPressed: () => Provider.of<RecipeProvider>(context, listen: false).toggleFavorite(recipe),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  const PopupMenuItem(value: 'share', child: Text('Bagikan')),
                  const PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: recipe.image != null
                  ? Image.file(File(recipe.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                  : _buildPlaceholder(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildInfoChips(context),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => CookingModeScreen(recipe: recipe)));
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Mode Masak'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                final dateStr = "${picked.day}/${picked.month}/${picked.year}";
                                await DatabaseHelper().insertMealPlan(recipe.id!, dateStr);
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dijadwalkan untuk $dateStr')));
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Jadwal Masak'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final db = await DatabaseHelper().database;
                          for (var ing in recipe.ingredients) {
                            await db.insert('shopping_list', {'nama_bahan': ing.name, 'jumlah': ing.amount});
                          }
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bahan ditambahkan ke Daftar Belanja')));
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Beli Semua Bahan'),
                      ),
                    ),
                    const Divider(height: 32),
                    Text('Deskripsi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(recipe.description),
                    const Divider(height: 32),
                    Text('Bahan-bahan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...recipe.ingredients.map((ing) => ListTile(
                          leading: const Icon(Icons.check_circle_outline, color: Colors.deepOrange),
                          title: Text(ing.name),
                          trailing: Text(ing.amount, style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    const Divider(height: 32),
                    Text('Langkah Memasak', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...recipe.steps.map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(radius: 12, child: Text(step.order.toString(), style: const TextStyle(fontSize: 12))),
                              const SizedBox(width: 12),
                              Expanded(child: Text(step.description)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.deepOrange.withOpacity(0.1),
      child: const Icon(Icons.restaurant, size: 100, color: Colors.deepOrange),
    );
  }

  Widget _buildInfoChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        Chip(label: Text(recipe.category), avatar: const Icon(Icons.category, size: 16)),
        Chip(label: Text('${recipe.cookingTime} Menit'), avatar: const Icon(Icons.timer, size: 16)),
        Chip(label: Text('${recipe.portions} Porsi'), avatar: const Icon(Icons.people, size: 16)),
        Chip(label: Text(recipe.difficulty), avatar: const Icon(Icons.speed, size: 16)),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRecipeScreen(recipe: recipe)));
        break;
      case 'delete':
        _confirmDelete(context);
        break;
      case 'share':
        Share.share('${recipe.name}\n\n${recipe.description}\n\nBahan:\n${recipe.ingredients.map((e) => "- ${e.name}: ${e.amount}").join('\n')}');
        break;
      case 'pdf':
        PdfHelper.generateAndPrintRecipe(recipe);
        break;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Provider.of<RecipeProvider>(context, listen: false).deleteRecipe(recipe.id!);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resep berhasil dihapus')));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
