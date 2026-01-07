import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../providers/filter_provider.dart';

/// FilterBar Widget - Filtreleme çubuğu (Stateless)
class FilterBar extends StatelessWidget {
  final FilterProvider filterProvider;
  final VoidCallback? onFilterChanged;

  const FilterBar({
    super.key,
    required this.filterProvider,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchField(context)),
              const SizedBox(width: 12),
              _buildSortDirectionButton(context),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPriorityDropdown(context),
                const SizedBox(width: 12),
                _buildStatusDropdown(context),
                const SizedBox(width: 12),
                _buildSortDropdown(context),
                const SizedBox(width: 12),
                if (filterProvider.hasActiveFilters) _buildClearButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Görevlerde ara...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, 
            color: Theme.of(context).platform == TargetPlatform.android 
                ? Theme.of(context).primaryColor 
                : Colors.grey[400]
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
        ),
        onChanged: (value) {
          filterProvider.setSearchQuery(value);
          onFilterChanged?.call();
        },
      ),
    );
  }

  Widget _buildDropdownContainer(BuildContext context, Widget child, {bool isActive = false}) {
    final activeColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.15) : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: _buildDropdownContainer(
        context,
        DropdownButton<Priority?>(
          value: filterProvider.selectedPriority,
          dropdownColor: Theme.of(context).cardTheme.color,
          icon: Icon(Icons.keyboard_arrow_down, 
            color: filterProvider.selectedPriority != null 
              ? Theme.of(context).primaryColor 
              : Colors.grey
          ),
          hint: Row(
            children: const [
              Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Öncelik', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tümü')),
            ...Priority.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.label, style: TextStyle(
                    color: p == Priority.high ? AppTheme.priorityHigh : 
                           p == Priority.medium ? AppTheme.priorityMedium : 
                           AppTheme.priorityLow
                  )),
                )),
          ],
          onChanged: (value) {
            filterProvider.setSelectedPriority(value);
            onFilterChanged?.call();
          },
        ),
        isActive: filterProvider.selectedPriority != null,
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: _buildDropdownContainer(
        context,
        DropdownButton<TaskStatus?>(
          value: filterProvider.selectedStatus,
          dropdownColor: Theme.of(context).cardTheme.color,
          icon: Icon(Icons.keyboard_arrow_down, 
            color: filterProvider.selectedStatus != null 
              ? Theme.of(context).primaryColor 
              : Colors.grey
          ),
          hint: Row(
            children: const [
              Icon(Icons.timelapse, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Durum', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tümü')),
            ...TaskStatus.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.label),
                )),
          ],
          onChanged: (value) {
            filterProvider.setSelectedStatus(value);
            onFilterChanged?.call();
          },
        ),
        isActive: filterProvider.selectedStatus != null,
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: _buildDropdownContainer(
        context,
        DropdownButton<SortOption>(
          value: filterProvider.sortOption,
          dropdownColor: Theme.of(context).cardTheme.color,
          icon: const Icon(Icons.sort, color: Colors.grey, size: 18),
          items: SortOption.values.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.label, style: const TextStyle(fontSize: 13)),
              )).toList(),
          onChanged: (value) {
            if (value != null) {
              filterProvider.setSortOption(value);
              onFilterChanged?.call();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSortDirectionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          filterProvider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          color: Colors.white,
          size: 20,
        ),
        tooltip: filterProvider.sortAscending ? 'Artan' : 'Azalan',
        onPressed: () {
          filterProvider.toggleSortDirection();
          onFilterChanged?.call();
        },
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.clear_all, size: 16),
      label: const Text('Temizle', style: TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: Colors.red[300],
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: Colors.red.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        filterProvider.clearFilters();
        onFilterChanged?.call();
      },
    );
  }
}

