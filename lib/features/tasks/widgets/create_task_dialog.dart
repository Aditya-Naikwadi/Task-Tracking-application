import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/voice_input_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import 'package:intl/intl.dart';

class CreateTaskDialog extends StatefulWidget {
  const CreateTaskDialog({super.key});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.work;
  int _timerMinutes = 25;
  
  final VoiceInputService _voiceService = VoiceInputService();
  bool _isListening = false;
  String _tagsStr = '';
  String _assignStr = '';

  @override
  void initState() {
    super.initState();
    _voiceService.init();
  }

  void _toggleVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _voiceService.startListening((text) {
        setState(() {
          _titleController.text = text;
          _isListening = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.teal),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Task Title',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? AppColors.orange : AppColors.teal,
                    ),
                    onPressed: _toggleVoiceInput,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Description (Optional)'),
              ),
              const SizedBox(height: 20),
              
              // Priority & Category
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<TaskPriority>(
                      'Priority',
                      _priority,
                      TaskPriority.values,
                      (val) => setState(() => _priority = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown<TaskCategory>(
                      'Category',
                      _category,
                      TaskCategory.values,
                      (val) => setState(() => _category = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Deadline Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline', style: TextStyle(color: AppColors.textSecondary)),
                subtitle: Text(DateFormat('MMM dd, hh:mm a').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today, color: AppColors.teal),
                onTap: _selectDateTime,
              ),
              
              // Timer Setting
              const Text('Timer Duration (min)', style: TextStyle(color: AppColors.textSecondary)),
              Slider(
                value: _timerMinutes.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: '$_timerMinutes min',
                activeColor: AppColors.orange,
                onChanged: (val) => setState(() => _timerMinutes = val.toInt()),
              ),
              const SizedBox(height: 16),
              
              const Text('Collaboration & Metadata', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Add Tags (comma separated)',
                  prefixIcon: Icon(Icons.label_outline, color: AppColors.teal),
                ),
                onChanged: (text) => _tagsStr = text,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Assign Users (emails)',
                  prefixIcon: Icon(Icons.person_add_alt_1_outlined, color: AppColors.teal),
                ),
                onChanged: (text) => _assignStr = text,
              ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitTask,
                      child: const Text('CREATE'),
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

  Widget _buildDropdown<T extends Enum>(String label, T value, List<T> items, ValueChanged<T?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: Container(height: 1, color: AppColors.teal.withValues(alpha: 0.3)),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item.name.toUpperCase(), style: const TextStyle(fontSize: 14)),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submitTask() {
    if (_titleController.text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descController.text,
      deadline: _selectedDate,
      priority: _priority,
      category: _category,
      status: TaskStatus.pending,
      ownerId: authProvider.user!.uid,
      totalTimerSeconds: _timerMinutes * 60,
      remainingSeconds: _timerMinutes * 60,
      tags: _tagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      assignedTo: _assignStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );

    taskProvider.addTask(newTask);
    Navigator.pop(context);
  }
}
