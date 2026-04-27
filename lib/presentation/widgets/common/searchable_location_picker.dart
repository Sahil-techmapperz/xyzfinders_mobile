import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SearchableLocationPicker<T> extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabel;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool isLoading;

  const SearchableLocationPicker({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    this.selectedItem,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
    this.isLoading = false,
  });

  @override
  State<SearchableLocationPicker<T>> createState() => _SearchableLocationPickerState<T>();
}

class _SearchableLocationPickerState<T> extends State<SearchableLocationPicker<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.isLoading ? null : () => _showSearchSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: FormField<T>(
            initialValue: widget.selectedItem,
            validator: widget.validator,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.hasError ? Colors.red : Colors.grey.shade200,
                        width: state.hasError ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.icon, color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.selectedItem != null 
                                ? widget.itemLabel(widget.selectedItem as T) 
                                : widget.hint,
                            style: TextStyle(
                              color: widget.selectedItem != null ? Colors.black87 : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                          )
                        else
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchSheet<T>(
        title: widget.label,
        items: widget.items,
        itemLabel: widget.itemLabel,
        onSelected: (item) {
          widget.onChanged(item);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SearchSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T) onSelected;

  const _SearchSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filter);
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget.itemLabel(item).toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  title: Text(widget.itemLabel(item)),
                  onTap: () => widget.onSelected(item),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
