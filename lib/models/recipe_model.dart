import 'ingredient_model.dart';
import 'step_model.dart';

class RecipeModel {
  final int? id;
  final String name;
  final String category;
  final int cookingTime;
  final int portions;
  final String difficulty;
  final String description;
  final String? image;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<IngredientModel> ingredients;
  final List<StepModel> steps;

  RecipeModel({
    this.id,
    required this.name,
    required this.category,
    required this.cookingTime,
    required this.portions,
    required this.difficulty,
    required this.description,
    this.image,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.ingredients = const [],
    this.steps = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_resep': name,
      'kategori': category,
      'waktu_memasak': cookingTime,
      'porsi': portions,
      'tingkat_kesulitan': difficulty,
      'deskripsi': description,
      'gambar': image,
      'favorit': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map, {List<IngredientModel>? ingredients, List<StepModel>? steps}) {
    return RecipeModel(
      id: map['id'],
      name: map['nama_resep'],
      category: map['kategori'],
      cookingTime: map['waktu_memasak'],
      portions: map['porsi'],
      difficulty: map['tingkat_kesulitan'],
      description: map['deskripsi'],
      image: map['gambar'],
      isFavorite: map['favorit'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      ingredients: ingredients ?? [],
      steps: steps ?? [],
    );
  }

  RecipeModel copyWith({
    int? id,
    String? name,
    String? category,
    int? cookingTime,
    int? portions,
    String? difficulty,
    String? description,
    String? image,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<IngredientModel>? ingredients,
    List<StepModel>? steps,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      cookingTime: cookingTime ?? this.cookingTime,
      portions: portions ?? this.portions,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }
}
