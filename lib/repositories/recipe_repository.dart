import '../database/database_helper.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import '../models/step_model.dart';

class RecipeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertRecipe(RecipeModel recipe) async {
    final db = await _dbHelper.database;
    int id = await db.insert('resep', recipe.toMap());
    
    for (var ingredient in recipe.ingredients) {
      await db.insert('bahan', ingredient.toMap()..['resep_id'] = id);
    }
    
    for (var step in recipe.steps) {
      await db.insert('langkah', step.toMap()..['resep_id'] = id);
    }
    
    return id;
  }

  Future<List<RecipeModel>> getAllRecipes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('resep', orderBy: 'created_at DESC');
    
    List<RecipeModel> recipes = [];
    for (var map in maps) {
      final ingredients = await getIngredientsForRecipe(map['id']);
      final steps = await getStepsForRecipe(map['id']);
      recipes.add(RecipeModel.fromMap(map, ingredients: ingredients, steps: steps));
    }
    return recipes;
  }

  Future<List<IngredientModel>> getIngredientsForRecipe(int recipeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('bahan', where: 'resep_id = ?', whereArgs: [recipeId]);
    return List.generate(maps.length, (i) => IngredientModel.fromMap(maps[i]));
  }

  Future<List<StepModel>> getStepsForRecipe(int recipeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('langkah', where: 'resep_id = ?', whereArgs: [recipeId], orderBy: 'urutan ASC');
    return List.generate(maps.length, (i) => StepModel.fromMap(maps[i]));
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    final db = await _dbHelper.database;
    await db.update('resep', recipe.toMap(), where: 'id = ?', whereArgs: [recipe.id]);
    
    // Delete existing ingredients and steps then re-add
    await db.delete('bahan', where: 'resep_id = ?', whereArgs: [recipe.id]);
    await db.delete('langkah', where: 'resep_id = ?', whereArgs: [recipe.id]);
    
    for (var ingredient in recipe.ingredients) {
      await db.insert('bahan', ingredient.toMap()..['resep_id'] = recipe.id);
    }
    
    for (var step in recipe.steps) {
      await db.insert('langkah', step.toMap()..['resep_id'] = recipe.id);
    }
  }

  Future<void> deleteRecipe(int id) async {
    final db = await _dbHelper.database;
    await db.delete('resep', where: 'id = ?', whereArgs: [id]);
    // Cascade delete handles ingredients and steps if foreign keys are configured correctly
    // or we can manually delete them.
    await db.delete('bahan', where: 'resep_id = ?', whereArgs: [id]);
    await db.delete('langkah', where: 'resep_id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.update('resep', {'favorit': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> resetDatabase() async {
    await _dbHelper.resetDatabase();
  }

  Future<String> backupDatabase() async {
    return await _dbHelper.backupDatabase();
  }

  Future<void> restoreDatabase() async {
    await _dbHelper.restoreDatabase();
  }

  Future<void> seedRecipes(List<RecipeModel> recipes) async {
    final db = await _dbHelper.database;
    
    // Gunakan transaksi manual yang lebih efisien untuk memasukkan data masal
    await db.transaction((txn) async {
      for (var recipe in recipes) {
        int id = await txn.insert('resep', recipe.toMap());
        for (var ingredient in recipe.ingredients) {
          await txn.insert('bahan', ingredient.toMap()..['resep_id'] = id);
        }
        for (var step in recipe.steps) {
          await txn.insert('langkah', step.toMap()..['resep_id'] = id);
        }
      }
    });
  }

  Future<void> seedShoppingList(List<Map<String, dynamic>> items) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (var item in items) {
        await txn.insert('shopping_list', item);
      }
    });
  }

  // Shopping List CRUD
  Future<void> insertShoppingItem(String name, String amount) async {
    final db = await _dbHelper.database;
    await db.insert('shopping_list', {'nama_bahan': name, 'jumlah': amount, 'is_checked': 0});
  }

  // Meal Plan CRUD
  Future<void> insertMealPlan(int recipeId, String date) async {
    final db = await _dbHelper.database;
    await db.insert('meal_plan', {'resep_id': recipeId, 'tanggal': date});
  }
}
