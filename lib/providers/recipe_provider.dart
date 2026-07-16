import 'dart:math';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import '../models/step_model.dart';
import '../repositories/recipe_repository.dart';
import '../constants/app_constants.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _repository = RecipeRepository();
  List<RecipeModel> _recipes = [];
  bool _isLoading = false;

  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    notifyListeners();
    _recipes = await _repository.getAllRecipes();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    await _repository.insertRecipe(recipe);
    await fetchRecipes();
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    await _repository.updateRecipe(recipe);
    await fetchRecipes();
  }

  Future<void> deleteRecipe(int id) async {
    await _repository.deleteRecipe(id);
    await fetchRecipes();
  }

  Future<void> toggleFavorite(RecipeModel recipe) async {
    final newStatus = !recipe.isFavorite;
    await _repository.toggleFavorite(recipe.id!, newStatus);
    
    // Optimistic update
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _recipes[index] = recipe.copyWith(isFavorite: newStatus);
      notifyListeners();
    }
  }

  List<RecipeModel> searchRecipes(String query) {
    if (query.isEmpty) return _recipes;
    return _recipes.where((recipe) {
      final nameLower = recipe.name.toLowerCase();
      final categoryLower = recipe.category.toLowerCase();
      final ingredientsLower = recipe.ingredients.map((i) => i.name.toLowerCase()).join(' ');
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) ||
             categoryLower.contains(searchLower) ||
             ingredientsLower.contains(searchLower);
    }).toList();
  }

  Future<void> resetDatabase() async {
    await _repository.resetDatabase();
    await fetchRecipes();
  }

  Future<void> backupDatabase() async {
    await _repository.backupDatabase();
  }

  Future<void> restoreDatabase() async {
    await _repository.restoreDatabase();
    await fetchRecipes();
  }

  Future<void> generateDummyData() async {
    _isLoading = true;
    notifyListeners();

    final random = Random();
    
    // Pecah menjadi 6 batch (50 resep per batch) agar tidak macet
    for (int batch = 0; batch < 6; batch++) {
      final List<RecipeModel> batchRecipes = [];
      for (int i = 1; i <= 50; i++) {
        final category = AppConstants.categories[random.nextInt(AppConstants.categories.length)];
        final name = "$category Spesial ${['Enak', 'Mantap', 'Lezat', 'Gurih', 'Nagih'][random.nextInt(5)]} #${(batch * 50) + i}";
        
        final recipe = RecipeModel(
          name: name,
          category: category,
          cookingTime: (random.nextInt(10) + 2) * 5,
          portions: random.nextInt(6) + 1,
          difficulty: AppConstants.difficultyLevels[random.nextInt(AppConstants.difficultyLevels.length)],
          description: AppConstants.descriptionTemplates[random.nextInt(AppConstants.descriptionTemplates.length)],
          image: AppConstants.recipeImages[random.nextInt(AppConstants.recipeImages.length)],
          createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          updatedAt: DateTime.now(),
          ingredients: [
            IngredientModel(name: AppConstants.commonIngredients[random.nextInt(50)], amount: "${random.nextInt(5) + 1} siung"),
            IngredientModel(name: AppConstants.commonIngredients[random.nextInt(40) + 50], amount: "${random.nextInt(500) + 100} gram"),
          ],
          steps: _generateDynamicSteps(category, random),
        );
        batchRecipes.add(recipe);
      }
      await _repository.seedRecipes(batchRecipes);
      // Beri jeda sangat singkat agar UI tidak freeze
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await fetchRecipes();
  }

  Future<void> generateShoppingListData() async {
    _isLoading = true;
    notifyListeners();

    final random = Random();
    
    // Pecah menjadi 8 batch (50 item per batch) agar tidak macet
    for (int batch = 0; batch < 8; batch++) {
      final List<Map<String, dynamic>> batchItems = [];
      for (int i = 1; i <= 50; i++) {
        batchItems.add({
          'nama_bahan': AppConstants.commonIngredients[random.nextInt(AppConstants.commonIngredients.length)],
          'jumlah': "${random.nextInt(10) + 1} ${['kg', 'gram', 'liter', 'bungkus', 'buah'][random.nextInt(5)]}",
          'is_checked': random.nextBool() ? 1 : 0,
        });
      }
      await _repository.seedShoppingList(batchItems);
      // Beri jeda singkat agar UI tidak freeze
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _isLoading = false;
    notifyListeners();
  }

  List<StepModel> _generateDynamicSteps(String category, Random random) {
    List<String> steps = [];
    
    if (category.contains('Minuman') || category.contains('Jus') || category.contains('Kopi')) {
      steps = [
        "Siapkan buah atau bahan utama dan cuci bersih.",
        "Masukkan bahan ke dalam blender atau wadah penyajian.",
        "Tambahkan air, es batu, atau pemanis sesuai selera.",
        "Haluskan atau aduk hingga tercampur rata.",
        "Tuangkan ke dalam gelas dan sajikan selagi dingin."
      ];
    } else if (category.contains('Goreng') || category.contains('Deep Fried')) {
      steps = [
        "Bersihkan bahan utama dan potong sesuai selera.",
        "Bumbui bahan atau balut dengan tepung bumbu.",
        "Panaskan minyak goreng dalam jumlah yang cukup.",
        "Goreng hingga berwarna kuning keemasan dan renyah.",
        "Tiriskan minyak dan sajikan dengan saus pilihan."
      ];
    } else if (category.contains('Bakar') || category.contains('Grill') || category.contains('Roasted')) {
      steps = [
        "Marinated bahan utama dengan bumbu selama 30 menit.",
        "Siapkan alat pemanggang atau oven dengan suhu yang pas.",
        "Panggang bahan sambil sesekali diolesi sisa bumbu.",
        "Balik secara teratur agar matang merata dan tidak gosong.",
        "Angkat dan sajikan dengan lalapan segar."
      ];
    } else if (category.contains('Tumis') || category.contains('Stir-Fry')) {
      steps = [
        "Iris tipis bawang merah, bawang putih, dan cabai.",
        "Tumis bumbu iris hingga harum dan layu.",
        "Masukkan bahan utama (sayur/daging) ke dalam wajan.",
        "Tambahkan sedikit air dan penyedap rasa.",
        "Masak sebentar hingga bumbu meresap dan sajikan."
      ];
    } else {
      steps = [
        "Siapkan bahan-bahan segar yang diperlukan.",
        "Haluskan bumbu rempah menggunakan ulekan atau blender.",
        "Tumis bumbu halus hingga matang dan mengeluarkan aroma.",
        "Masukkan bahan utama dan masak dengan api sedang.",
        "Koreksi rasa dan masak hingga tingkat kematangan yang pas."
      ];
    }

    return List.generate(steps.length, (i) => StepModel(order: i + 1, description: steps[i]));
  }
}
