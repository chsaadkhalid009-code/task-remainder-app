import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;
  late TimeOfDay _time;
  late String _repeatType;
  late String _category;

  final List<String> _categories = ['work', 'personal', 'health', 'family', 'prayer'];
  final List<String> _repeatTypes = ['never', 'daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _time = widget.task?.time ?? TimeOfDay.now();
    _repeatType = widget.task?.repeatType ?? 'never';
    _category = widget.task?.category ?? 'work';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFFBE9D7),
      appBar: AppBar(
        title: Text('New Reminder', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Task Title', isDark),
              _buildTextField(
                isDark: isDark,
                initialValue: _title,
                hintText: 'Title',
                onSaved: (val) => _title = val!,
              ),
              const SizedBox(height: 15),
              _buildFieldLabel('Label', isDark),
              _buildDropdownField(
                isDark: isDark,
                value: _category,
                items: _categories,
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 15),
              _buildFieldLabel('Reminder Date', isDark),
              _buildDatePickerField(isDark),
              const SizedBox(height: 15),
              _buildFieldLabel('Reminder Time', isDark),
              _buildTimePickerField(isDark),
              const SizedBox(height: 15),
              _buildFieldLabel('Repeat', isDark),
              _buildDropdownField(
                isDark: isDark,
                value: _repeatType,
                items: _repeatTypes,
                onChanged: (val) => setState(() => _repeatType = val!),
              ),
              const SizedBox(height: 15),
              _buildFieldLabel('Ringtone', isDark),
              _buildDropdownField(
                isDark: isDark,
                value: 'Default',
                items: ['Default', 'Piano', 'Bell'],
                onChanged: (val) {},
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: isDark ? Colors.blueAccent : Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Reset', style: TextStyle(color: isDark ? Colors.blueAccent : Colors.orange)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: isDark ? Colors.blueAccent : Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _submitData,
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
    );
  }

  Widget _buildTextField({required bool isDark, required String initialValue, required String hintText, required Function(String?) onSaved}) {
    return TextFormField(
      initialValue: initialValue,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black38),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField({required bool isDark, required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePickerField(bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) setState(() => _dueDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMd().format(_dueDate), style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            Icon(Icons.calendar_today, size: 20, color: isDark ? Colors.white70 : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerField(bool isDark) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _time);
        if (time != null) setState(() => _time = time);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_time.format(context), style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            Icon(Icons.access_time, size: 20, color: isDark ? Colors.white70 : Colors.grey),
          ],
        ),
      ),
    );
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final taskData = Task(
        id: widget.task?.id,
        title: _title,
        description: '',
        dueDate: _dueDate,
        time: _time,
        isCompleted: widget.task?.isCompleted ?? false,
        repeatType: _repeatType,
        category: _category,
      );

      if (widget.task == null) {
        Provider.of<TaskProvider>(context, listen: false).addTask(taskData);
      } else {
        Provider.of<TaskProvider>(context, listen: false).updateTask(taskData);
      }
      Navigator.of(context).pop();
    }
  }
}
