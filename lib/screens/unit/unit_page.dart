// unit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_project_lab/main.dart';
import 'package:flutter_project_lab/models/unit_model.dart';
import 'package:flutter_project_lab/models/dtos/unit_dto.dart';
import 'package:flutter_project_lab/services/network_service.dart';

class UnitPage extends StatefulWidget {
  const UnitPage({super.key});

  @override
  State<UnitPage> createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  final NetworkService _networkService = NetworkService();
  List<Unit> units = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() => isLoading = true);
    try {
      final response = await _networkService.get('/api/units');
      if (response.isSuccess) {
        final loadedUnits = unitFromJson(response.content);
        setState(() {
          units = loadedUnits;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load units')),
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

  Future<void> _deleteUnit(String id, Unit unit) async {
    try {
      final response =
          await _networkService.delete('/api/units/${unit.unitId}');
      if (response.isSuccess) {
        await _loadUnits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete unit')),
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
        title: const Text('Units'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search units...',
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
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(unit.unitName),
                          subtitle: Text('ID: ${unit.unitId}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => UnitEditDialog(
                                      unit: unit,
                                      onSave: _loadUnits,
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
                                      title: const Text('Delete Unit'),
                                      content: Text(
                                          'Are you sure you want to delete ${unit.unitName}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteUnit(unit.id, unit);
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
            builder: (context) => UnitEditDialog(onSave: _loadUnits),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// unit_edit_dialog.dart
class UnitEditDialog extends StatefulWidget {
  final Unit? unit;
  final Function() onSave;

  const UnitEditDialog({
    super.key,
    this.unit,
    required this.onSave,
  });

  @override
  State<UnitEditDialog> createState() => _UnitEditDialogState();
}

class _UnitEditDialogState extends State<UnitEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final NetworkService _networkService = NetworkService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.unit != null) {
      _nameController.text = widget.unit!.unitName;
    }
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final dto = UnitDto(unitName: _nameController.text.trim());
      final response = widget.unit != null
          ? await _networkService.putJson(
              '/api/units/${widget.unit!.unitId}',
              dto.toJson(),
            )
          : await _networkService.postJson(
              '/api/units',
              dto.toJson(),
            );

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          widget.onSave();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.unit != null
                    ? 'Unit updated successfully'
                    : 'Unit created successfully',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save unit'),
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
      title: Text(widget.unit != null ? 'Edit Unit' : 'Add Unit'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Unit Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter unit name';
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
          onPressed: _isSaving ? null : _saveUnit,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.unit != null ? 'Update' : 'Save'),
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
