import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../core/theme/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onSelected;

  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          widget.title.text.xl.bold.make().px(20),
          const SizedBox(height: 10),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = _currentValue == option;
                return ListTile(
                  title: option.text.medium.color(isSelected ? AppTheme.secondaryColor : Colors.black).make(),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.secondaryColor) : null,
                  onTap: () {
                    setState(() => _currentValue = option);
                    widget.onSelected(option);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              widget.onSelected(null);
              Navigator.pop(context);
            },
            child: "Clear Filter".text.color(Colors.grey).make(),
          ),
        ],
      ),
    );
  }
}
