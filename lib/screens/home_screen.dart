import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'add_task_screen.dart';
import 'category_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'today_tasks_screen.dart';
import 'scheduled_tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Work', 'icon': Icons.work_outline, 'color': Colors.blue},
    {'name': 'Personal', 'icon': Icons.person_outline, 'color': Colors.orange},
    {'name': 'Health', 'icon': Icons.health_and_safety_outlined, 'color': Colors.green},
    {'name': 'Family', 'icon': Icons.family_restroom_outlined, 'color': Colors.purple},
    {'name': 'Prayer', 'icon': Icons.mosque_outlined, 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final now = DateTime.now();
          final todayCount = taskProvider.tasks.where((t) => 
            !t.isCompleted && 
            t.dueDate.year == now.year && 
            t.dueDate.month == now.month && 
            t.dueDate.day == now.day
          ).length;
          final completedCount = taskProvider.tasks.where((t) => t.isCompleted).length;
          final scheduledCount = taskProvider.tasks.where((t) => !t.isCompleted).length;

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.5,
                        children: [
                          _buildSummaryCard(
                            context, 
                            'Today', 
                            todayCount.toString(), 
                            const Color(0xFFFFEAB4), // Light Yellow
                            const Color(0xFF4A412A), // Dark Yellow
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => TodayTasksScreen()))
                          ),
                          _buildSummaryCard(
                            context, 
                            'Scheduled', 
                            scheduledCount.toString(), 
                            const Color(0xFFD6F3FF), // Light Blue
                            const Color(0xFF2A3D4A), // Dark Blue
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduledTasksScreen()))
                          ),
                          _buildSummaryCard(
                            context, 
                            'Completed', 
                            completedCount.toString(), 
                            const Color(0xFFD0F5D0), // Light Green
                            const Color(0xFF2A4A2A), // Dark Green
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedTasksScreen()))
                          ),
                          _buildSummaryCard(
                            context, 
                            'Cancelled', 
                            '0', 
                            const Color(0xFFFFD6D6), // Light Red
                            const Color(0xFF4A2A2A), // Dark Red
                            () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cancelled tasks yet')))
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('My Lists', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          const Text('Edit', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: _categories.map((cat) {
                          final tasks = taskProvider.getTasksByCategory(cat['name'].toLowerCase());
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryTasksScreen(
                                      categoryName: cat['name'],
                                      categoryColor: cat['color'],
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: cat['color'].withOpacity(0.1),
                                child: Icon(cat['icon'], color: cat['color']),
                              ),
                              title: Text(cat['name'], style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                              trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3D3D3D) : Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(tasks.length.toString(), style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        elevation: 4,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskScreen())),
        label: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text('New Reminder', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String count, Color lightColor, Color darkColor, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? darkColor : lightColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ),
              Text(title, style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
