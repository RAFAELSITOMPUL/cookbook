import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Map<String, dynamic>> _items = [];
  final _db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = await _db.database;
    final data = await db.query('shopping_list', orderBy: 'is_checked ASC');
    setState(() => _items = data);
  }

  Future<void> _toggleItem(int id, int currentStatus) async {
    final db = await _db.database;
    await db.update('shopping_list', {'is_checked': currentStatus == 1 ? 0 : 1}, where: 'id = ?', whereArgs: [id]);
    _loadItems();
  }

  Future<void> _deleteItem(int id) async {
    final db = await _db.database;
    await db.delete('shopping_list', where: 'id = ?', whereArgs: [id]);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Belanja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final db = await _db.database;
              await db.delete('shopping_list', where: 'is_checked = 1');
              _loadItems();
            },
          )
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Belum ada item belanja.'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: Checkbox(
                    value: item['is_checked'] == 1,
                    onChanged: (_) => _toggleItem(item['id'], item['is_checked']),
                  ),
                  title: Text(
                    item['nama_bahan'],
                    style: TextStyle(
                      decoration: item['is_checked'] == 1 ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(item['jumlah']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteItem(item['id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog() {
    String name = '';
    String amount = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Belanjaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nama Bahan'),
              onChanged: (v) => name = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Jumlah/Ukuran'),
              onChanged: (v) => amount = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (name.isNotEmpty) {
                final db = await _db.database;
                await db.insert('shopping_list', {'nama_bahan': name, 'jumlah': amount});
                if (mounted) Navigator.pop(context);
                _loadItems();
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
