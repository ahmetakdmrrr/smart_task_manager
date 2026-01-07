import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// TaskForm Widget - Görev ekleme/düzenleme formu (Stateful - form state)
class TaskForm extends StatefulWidget {
  final Task? existingTask;
  final List<Task> availablePredecessors;
  final void Function(Task task) onSave;

  const TaskForm({
    super.key,
    this.existingTask,
    required this.availablePredecessors,
    required this.onSave,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _hoursController;
  late Priority _priority;
  late TaskStatus _status;
  late DateTime _dueDate;
  String? _predecessorId;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _hoursController = TextEditingController(
        text: task?.estimatedHours.toString() ?? '1');
    _priority = task?.priority ?? Priority.medium;
    _status = task?.status ?? TaskStatus.pending;
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _predecessorId = task?.predecessorId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            _buildStatusSelector(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildHoursField(),
            const SizedBox(height: 16),
            _buildDependencySelector(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Görev Başlığı *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Başlık zorunludur';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Açıklama',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Öncelik', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<Priority>(
          segments: Priority.values
              .map((p) => ButtonSegment(value: p, label: Text(p.label)))
              .toList(),
          selected: {_priority},
          onSelectionChanged: (selected) {
            setState(() => _priority = selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Durum', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<TaskStatus>(
          segments: TaskStatus.values
              .map((s) => ButtonSegment(value: s, label: Text(s.label)))
              .toList(),
          selected: {_status},
          onSelectionChanged: (selected) {
            setState(() => _status = selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) {
          setState(() => _dueDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Son Teslim Tarihi',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(dateFormat.format(_dueDate)),
      ),
    );
  }

  Widget _buildHoursField() {
    return TextFormField(
      controller: _hoursController,
      decoration: const InputDecoration(
        labelText: 'Tahmini Süre (saat)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timer),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final hours = int.tryParse(value);
          if (hours == null || hours < 1) {
            return 'Geçerli bir süre girin';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDependencySelector() {
    return DropdownButtonFormField<String?>(
      value: _predecessorId,
      decoration: const InputDecoration(
        labelText: 'Öncül Görev (Bağımlılık)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.link),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Yok')),
        ...widget.availablePredecessors
            .where((t) => t.id != widget.existingTask?.id)
            .map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.title),
                )),
      ],
      onChanged: (value) {
        setState(() => _predecessorId = value);
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _saveTask,
      icon: const Icon(Icons.save),
      label: Text(widget.existingTask != null ? 'Güncelle' : 'Kaydet'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.existingTask?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priorityIndex: _priority.index,
        dueDate: _dueDate,
        estimatedHours: int.tryParse(_hoursController.text) ?? 1,
        statusIndex: _status.index,
        predecessorId: _predecessorId,
        createdAt: widget.existingTask?.createdAt,
      );
      widget.onSave(task);
    }
  }
}
