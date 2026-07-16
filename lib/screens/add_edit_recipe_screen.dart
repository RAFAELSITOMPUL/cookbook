import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import '../models/step_model.dart';
import '../providers/recipe_provider.dart';
import '../constants/app_constants.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final RecipeModel? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _timeController;
  late TextEditingController _portionController;
  
  String _selectedCategory = AppConstants.categories.first;
  String _selectedDifficulty = AppConstants.difficultyLevels.first;
  String? _imagePath;
  
  List<IngredientModel> _ingredients = [];
  List<StepModel> _steps = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe?.name ?? '');
    _descController = TextEditingController(text: widget.recipe?.description ?? '');
    _timeController = TextEditingController(text: widget.recipe?.cookingTime.toString() ?? '');
    _portionController = TextEditingController(text: widget.recipe?.portions.toString() ?? '');
    _selectedCategory = widget.recipe?.category ?? AppConstants.categories.first;
    _selectedDifficulty = widget.recipe?.difficulty ?? AppConstants.difficultyLevels.first;
    _imagePath = widget.recipe?.image;
    _ingredients = widget.recipe != null ? List.from(widget.recipe!.ingredients) : [];
    _steps = widget.recipe != null ? List.from(widget.recipe!.steps) : [];
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientModel(name: '', amount: ''));
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(StepModel(order: _steps.length + 1, description: ''));
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty) {
        _showError('Minimal satu bahan harus diisi');
        return;
      }
      if (_steps.isEmpty) {
        _showError('Minimal satu langkah harus diisi');
        return;
      }

      final recipe = RecipeModel(
        id: widget.recipe?.id,
        name: _nameController.text,
        category: _selectedCategory,
        cookingTime: int.parse(_timeController.text),
        portions: int.parse(_portionController.text),
        difficulty: _selectedDifficulty,
        description: _descController.text,
        image: _imagePath,
        isFavorite: widget.recipe?.isFavorite ?? false,
        createdAt: widget.recipe?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        ingredients: _ingredients,
        steps: _steps,
      );

      final provider = Provider.of<RecipeProvider>(context, listen: false);
      if (widget.recipe == null) {
        provider.addRecipe(recipe);
      } else {
        provider.updateRecipe(recipe);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.recipe == null ? 'Resep berhasil ditambah' : 'Resep berhasil diubah')),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Tambah Resep' : 'Edit Resep'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveRecipe),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Resep', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      items: AppConstants.categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(labelText: 'Kesulitan', border: OutlineInputBorder()),
                      items: AppConstants.difficultyLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedDifficulty = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Waktu (Menit)', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _portionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Porsi', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true, // Tambahkan ini agar teks panjang terpotong (dipangkas)
                value: widget.recipe != null && AppConstants.descriptionTemplates.contains(_descController.text) 
                    ? _descController.text 
                    : (_descController.text.isEmpty ? null : null),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Resep (Pilih Template)',
                  border: OutlineInputBorder(),
                  hintText: 'Pilih deskripsi yang sesuai',
                ),
                items: AppConstants.descriptionTemplates.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _descController.text = v!;
                  });
                },
                validator: (v) => _descController.text.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Kustom Deskripsi',
                  border: OutlineInputBorder(),
                  helperText: 'Anda bisa memilih dari dropdown di atas atau mengeditnya di sini',
                ),
                onChanged: (v) {
                  setState(() {}); // Trigger rebuild to update dropdown state if needed
                },
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              _buildIngredientsList(),
              const SizedBox(height: 24),
              _buildStepsList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          image: _imagePath != null ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover) : null,
        ),
        child: _imagePath == null ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey) : null,
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeri'), onTap: () { _pickImage(ImageSource.gallery); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Kamera'), onTap: () { _pickImage(ImageSource.camera); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bahan-bahan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.deepOrange), onPressed: _addIngredient),
          ],
        ),
        ...List.generate(_ingredients.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return AppConstants.commonIngredients.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _ingredients[index] = IngredientModel(name: selection, amount: _ingredients[index].amount);
                      });
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      if (controller.text.isEmpty && _ingredients[index].name.isNotEmpty) {
                        controller.text = _ingredients[index].name;
                      }
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Nama Bahan',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true, // Membuat input lebih ringkas
                        ),
                        onChanged: (v) {
                          _ingredients[index] = IngredientModel(name: v, amount: _ingredients[index].amount);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4), // Kurangi jarak
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: _ingredients[index].amount,
                    decoration: const InputDecoration(
                      hintText: 'Jumlah',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true, // Membuat input lebih ringkas
                    ),
                    onChanged: (v) => _ingredients[index] = IngredientModel(name: _ingredients[index].name, amount: v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => setState(() => _ingredients.removeAt(index)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Langkah Memasak', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.deepOrange), onPressed: _addStep),
          ],
        ),
        ...List.generate(_steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                CircleAvatar(child: Text((index + 1).toString())),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _steps[index].description,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Deskripsi Langkah', border: OutlineInputBorder()),
                    onChanged: (v) => _steps[index] = StepModel(order: index + 1, description: v),
                  ),
                ),
                IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _steps.removeAt(index))),
              ],
            ),
          );
        }),
      ],
    );
  }
}
