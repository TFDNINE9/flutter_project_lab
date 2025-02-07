// category_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_project_lab/main.dart';
import 'package:flutter_project_lab/models/category_model.dart';
import 'package:flutter_project_lab/models/dtos/category_dto.dart';
import 'package:flutter_project_lab/services/network_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final NetworkService _networkService = NetworkService();
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      final response = await _networkService.get('/api/categories');
      if (response.isSuccess) {
        final loadedCategories = categoryFromJson(response.content);
        setState(() {
          categories = loadedCategories;
        });
      } else {
        // Handle error - you might want to show a snackbar or dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load categories')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteCategory(String id, dynamic category) async {
    try {
      final response = await _networkService
          .delete('/api/categories/${category.categoryId}');
      if (response.isSuccess) {
        await _loadCategories(); // Reload the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete category')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Category List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(category.categoryName),
                          subtitle: Text('ID: ${category.categoryId}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CateEditDialog(
                                      category: category,
                                      onSave: _loadCategories,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Category'),
                                      content: Text(
                                          'Are you sure you want to delete ${category.categoryName}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteCategory(
                                                category.id, category);
                                          },
                                          child: const Text('Delete'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CateEditDialog(onSave: _loadCategories),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// cate_edit_dialog.dart
class CateEditDialog extends StatefulWidget {
  final Category? category; // If provided, we're editing an existing category
  final Function() onSave; // Callback to refresh the list after save

  const CateEditDialog({
    super.key,
    this.category,
    required this.onSave,
  });

  @override
  State<CateEditDialog> createState() => _CateEditDialogState();
}

class _CateEditDialogState extends State<CateEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final NetworkService _networkService = NetworkService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.categoryName;
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final dto = CategoryDto(categoryName: _nameController.text.trim());
      final response = widget.category != null
          ? await _networkService.putJson(
              '/api/categories/${widget.category!.categoryId}',
              dto.toJson(),
            )
          : await _networkService.postJson(
              '/api/categories',
              dto.toJson(),
            );

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          widget.onSave();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.category != null
                    ? 'Category updated successfully'
                    : 'Category created successfully',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save category'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter category name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveCategory,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.category != null ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
