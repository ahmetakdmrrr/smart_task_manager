import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';

/// TaskForm Widget - Görev ekleme/düzenleme formu
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(context, 'Temel Bilgiler', Icons.info_outline),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 32),
            
            _buildSectionTitle(context, 'Durum ve Öncelik', Icons.flag_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPrioritySelector(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusSelector(context)),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle(context, 'Zamanlama', Icons.access_time),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDatePicker(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildHoursField()),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle(context, 'Bağımlılıklar', Icons.link),
            const SizedBox(height: 16),
            _buildDependencySelector(),
            
            const SizedBox(height: 48),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      decoration: const InputDecoration(
        labelText: 'Görev Başlığı',
        prefixIcon: Icon(Icons.title),
        hintText: 'Örn: Ana Sayfa Tasarımı',
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Başlık zorunludur' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Açıklama',
        prefixIcon: Icon(Icons.description_outlined),
        hintText: 'Görev detaylarını buraya girin...',
        alignLabelWithHint: true,
      ),
      maxLines: 4,
    );
  }

  Widget _buildPrioritySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Öncelik', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Priority>(
          value: _priority,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.priority_high),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: Priority.values.map((p) {
            Color color;
            switch (p) {
              case Priority.high: color = AppTheme.priorityHigh; break;
              case Priority.medium: color = AppTheme.priorityMedium; break;
              case Priority.low: color = AppTheme.priorityLow; break;
            }
            return DropdownMenuItem(
              value: p,
              child: Text(
                p.label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _priority = val!),
        ),
      ],
    );
  }

  Widget _buildStatusSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Durum', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskStatus>(
          value: _status,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.timelapse),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: TaskStatus.values.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s.label),
            );
          }).toList(),
          onChanged: (val) => setState(() => _status = val!),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
    
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFFF6D00),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _dueDate = picked);
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          key: ValueKey(_dueDate), // Force rebuild on change
          initialValue: dateFormat.format(_dueDate),
          decoration: const InputDecoration(
            labelText: 'Son Tarih',
            prefixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  Widget _buildHoursField() {
    return TextFormField(
      controller: _hoursController,
      decoration: const InputDecoration(
        labelText: 'Süre (Saat)',
        prefixIcon: Icon(Icons.timer_outlined),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final hours = int.tryParse(value);
          if (hours == null || hours < 1) {
            return 'Geçersiz';
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
        labelText: 'Öncül Görev (Bu görev başlamadan bitmesi gereken)',
        prefixIcon: Icon(Icons.lock_outline),
        helperText: 'Seçilen görev tamamlanana kadar bu görev başlayamaz.',
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Bağımlılık Yok')),
        ...widget.availablePredecessors
            .where((t) => t.id != widget.existingTask?.id)
            .map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(
                    t.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
      ],
      onChanged: (value) => setState(() => _predecessorId = value),
      isExpanded: true,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _saveTask,
        icon: Icon(widget.existingTask != null ? Icons.update : Icons.add_task),
        label: Text(
          widget.existingTask != null ? 'GÖREVİ GÜNCELLE' : 'YENİ GÖREV OLUŞTUR',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
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
