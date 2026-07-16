class IngredientModel {
  final int? id;
  final int? recipeId;
  final String name;
  final String amount;

  IngredientModel({
    this.id,
    this.recipeId,
    required this.name,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resep_id': recipeId,
      'nama_bahan': name,
      'jumlah': amount,
    };
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      id: map['id'],
      recipeId: map['resep_id'],
      name: map['nama_bahan'],
      amount: map['jumlah'],
    );
  }
}
