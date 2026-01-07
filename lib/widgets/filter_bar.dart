import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildSearchField(),
          _buildPriorityDropdown(),
          _buildStatusDropdown(),
          _buildSortDropdown(),
          _buildSortDirectionButton(),
          _buildClearButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 250,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Görev ara...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          isDense: true,
        ),
        onChanged: (value) {
          filterProvider.setSearchQuery(value);
          onFilterChanged?.call();
        },
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<Priority?>(
          value: filterProvider.selectedPriority,
          hint: const Text('Öncelik'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tümü')),
            ...Priority.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.label),
                )),
          ],
          onChanged: (value) {
            filterProvider.setSelectedPriority(value);
            onFilterChanged?.call();
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<TaskStatus?>(
          value: filterProvider.selectedStatus,
          hint: const Text('Durum'),
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
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<SortOption>(
          value: filterProvider.sortOption,
          items: SortOption.values.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.label),
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

  Widget _buildSortDirectionButton() {
    return IconButton(
      icon: Icon(
        filterProvider.sortAscending
            ? Icons.arrow_upward
            : Icons.arrow_downward,
      ),
      tooltip: filterProvider.sortAscending ? 'Artan' : 'Azalan',
      onPressed: () {
        filterProvider.toggleSortDirection();
        onFilterChanged?.call();
      },
    );
  }

  Widget _buildClearButton() {
    return TextButton.icon(
      icon: const Icon(Icons.clear_all),
      label: const Text('Temizle'),
      onPressed: () {
        filterProvider.clearFilters();
        onFilterChanged?.call();
      },
    );
  }
}
