class StepModel {
  final int? id;
  final int? recipeId;
  final int order;
  final String description;

  StepModel({
    this.id,
    this.recipeId,
    required this.order,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resep_id': recipeId,
      'urutan': order,
      'deskripsi': description,
    };
  }

  factory StepModel.fromMap(Map<String, dynamic> map) {
    return StepModel(
      id: map['id'],
      recipeId: map['resep_id'],
      order: map['urutan'],
      description: map['deskripsi'],
    );
  }
}
