import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// TaskCard Widget - Görev kartı (Stateless - veri sadece gösterim)
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDependencyWarning;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.showDependencyWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty) ...[
                Text(
                  task.description,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              _buildFooter(),
              if (showDependencyWarning) _buildDependencyWarning(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildPriorityBadge(),
        if (task.hasDelayRisk) _buildRiskIndicator(),
      ],
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    switch (task.priority) {
      case Priority.high:
        color = Colors.red;
        break;
      case Priority.medium:
        color = Colors.orange;
        break;
      case Priority.low:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        task.priority.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRiskIndicator() {
    return const Padding(
      padding: EdgeInsets.only(left: 8),
      child: Tooltip(
        message: 'Gecikme Riski!',
        child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
      ),
    );
  }

  Widget _buildFooter() {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
    
    return Row(
      children: [
        _buildStatusChip(),
        const Spacer(),
        Icon(
          Icons.calendar_today,
          size: 16,
          color: task.isOverdue ? Colors.red : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          dateFormat.format(task.dueDate),
          style: TextStyle(
            color: task.isOverdue ? Colors.red : Colors.grey[600],
            fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (onDelete != null) ...[
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip() {
    Color bgColor;
    Color textColor;
    
    switch (task.status) {
      case TaskStatus.completed:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case TaskStatus.inProgress:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case TaskStatus.pending:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        task.status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDependencyWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock, color: Colors.amber, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Öncül görev tamamlanmadan başlatılamaz',
              style: TextStyle(color: Colors.amber, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
