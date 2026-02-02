import '../../helpers/ExportImports.dart';

class HorizontalFilterChips extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final String selectedValue;
  final Function(String) onSelectionChanged;

  const HorizontalFilterChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: options.map((option) {
            final isSelected = option['value'] == selectedValue;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(
                  option['label'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                selected: isSelected,
                selectedColor: grailGold,
                backgroundColor: Colors.grey[300],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide.none,
                ),
                side: BorderSide.none,
                onSelected: (_) {
                  onSelectionChanged(option['value']);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
