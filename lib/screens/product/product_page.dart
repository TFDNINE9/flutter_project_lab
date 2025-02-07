// product_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_project_lab/main.dart';
import 'package:flutter_project_lab/models/product_model.dart';
import 'package:flutter_project_lab/models/category_model.dart';
import 'package:flutter_project_lab/models/unit_model.dart';
import 'package:flutter_project_lab/models/dtos/product_dto.dart';
import 'package:flutter_project_lab/services/network_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final NetworkService _networkService = NetworkService();
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final response = await _networkService.get('/api/products');
      if (response.isSuccess) {
        final loadedProducts = productFromJson(response.content);
        setState(() {
          products = loadedProducts;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load products')),
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
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteProduct(String id, Product product) async {
    try {
      final response =
          await _networkService.delete('/api/products/${product.productId}');
      if (response.isSuccess) {
        await _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete product')),
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
        title: const Text('Products'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(product.productName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Category: ${product.category.categoryName}'),
                              Text('Unit: ${product.unit.unitName}'),
                              Text(
                                  'Price: \$${product.price} | Sale: \$${product.salePrice}'),
                              Text('Quantity: ${product.quantity}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ProductEditDialog(
                                      product: product,
                                      onSave: _loadProducts,
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
                                      title: const Text('Delete Product'),
                                      content: Text(
                                          'Are you sure you want to delete ${product.productName}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteProduct(product.id, product);
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
            builder: (context) => ProductEditDialog(onSave: _loadProducts),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// product_edit_dialog.dart
class ProductEditDialog extends StatefulWidget {
  final Product? product;
  final Function() onSave;

  const ProductEditDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();

  final NetworkService _networkService = NetworkService();
  bool _isSaving = false;
  bool _isLoading = true;

  List<Category> categories = [];
  List<Unit> units = [];
  Category? selectedCategory;
  Unit? selectedUnit;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      // Load categories
      final categoryResponse = await _networkService.get('/api/categories');
      if (categoryResponse.isSuccess) {
        categories = categoryFromJson(categoryResponse.content);
      }

      // Load units
      final unitResponse = await _networkService.get('/api/units');
      if (unitResponse.isSuccess) {
        units = unitFromJson(unitResponse.content);
      }

      // Set initial values if editing
      if (widget.product != null) {
        _nameController.text = widget.product!.productName;
        _quantityController.text = widget.product!.quantity.toString();
        _priceController.text = widget.product!.price.toString();
        _salePriceController.text = widget.product!.salePrice.toString();

        selectedCategory = categories.firstWhere(
          (category) => category.categoryId == widget.product!.categoryId,
        );
        selectedUnit = units.firstWhere(
          (unit) => unit.unitId == widget.product!.unitId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading form data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory == null || selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and unit')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final dto = ProductDto(
        productName: _nameController.text.trim(),
        quantity: int.parse(_quantityController.text),
        price: int.parse(_priceController.text),
        salePrice: int.parse(_salePriceController.text),
        categoryId: selectedCategory!.categoryId,
        unitId: selectedUnit!.unitId,
      );

      final response = widget.product != null
          ? await _networkService.putJson(
              '/api/products/${widget.product!.productId}',
              dto.toJson(),
            )
          : await _networkService.postJson(
              '/api/products',
              dto.toJson(),
            );

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          widget.onSave();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product != null
                    ? 'Product updated successfully'
                    : 'Product created successfully',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save product'),
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
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.categoryName),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Unit>(
                value: selectedUnit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: units.map((Unit unit) {
                  return DropdownMenuItem<Unit>(
                    value: unit,
                    child: Text(unit.unitName),
                  );
                }).toList(),
                onChanged: (Unit? newValue) {
                  setState(() {
                    selectedUnit = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(labelText: 'Sale Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sale price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProduct,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.product != null ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }
}
