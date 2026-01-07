import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
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
      // AppTheme'den gelen cardTheme zaten margin ve shape'i hallediyor
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardTheme.color!,
                Theme.of(context).cardTheme.color!.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              if (task.description.isNotEmpty) ...[
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
              ],
              _buildFooter(context),
              if (showDependencyWarning) _buildDependencyWarning(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            task.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ),
        const SizedBox(width: 8),
        _buildPriorityBadge(context),
        if (task.hasDelayRisk) _buildRiskIndicator(context),
      ],
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color color;
    switch (task.priority) {
      case Priority.high:
        color = AppTheme.priorityHigh;
        break;
      case Priority.medium:
        color = AppTheme.priorityMedium;
        break;
      case Priority.low:
        color = AppTheme.priorityLow;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        task.priority.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: 'Gecikme Riski!',
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
          ),
          child: const Icon(Icons.warning, color: Colors.red, size: 16),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
    final isOverdue = task.isOverdue;
    
    return Row(
      children: [
        _buildStatusChip(context),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOverdue 
                ? Colors.red.withOpacity(0.1) 
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: isOverdue 
                ? Border.all(color: Colors.red.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: isOverdue ? Colors.red : Colors.grey[400],
              ),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(task.dueDate),
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.grey[300],
                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.delete_outline, color: Colors.grey[500], size: 20),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (task.status) {
      case TaskStatus.completed:
        color = AppTheme.priorityLow; // Green
        icon = Icons.check_circle_outline;
        break;
      case TaskStatus.inProgress:
        color = Colors.blueAccent;
        icon = Icons.timelapse;
        break;
      case TaskStatus.pending:
        color = Colors.grey;
        icon = Icons.pending_outlined;
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          task.status.label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDependencyWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Öncül görev tamamlanmadan başlatılamaz',
              style: TextStyle(
                color: Colors.orange[300], 
                fontSize: 12,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }
}
