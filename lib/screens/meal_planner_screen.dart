import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  List<Map<String, dynamic>> _plans = [];
  final _db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final db = await _db.database;
    final data = await db.rawQuery('''
      SELECT meal_plan.*, resep.nama_resep 
      FROM meal_plan 
      JOIN resep ON meal_plan.resep_id = resep.id 
      ORDER BY tanggal ASC
    ''');
    setState(() => _plans = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Masak')),
      body: _plans.isEmpty
          ? const Center(child: Text('Belum ada jadwal masak.'))
          : ListView.builder(
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.deepOrange),
                  title: Text(plan['nama_resep']),
                  subtitle: Text(plan['tanggal']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final db = await _db.database;
                      await db.delete('meal_plan', where: 'id = ?', whereArgs: [plan['id']]);
                      _loadPlans();
                    },
                  ),
                );
              },
            ),
    );
  }
}
