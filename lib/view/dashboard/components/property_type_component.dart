
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class PropertyTypesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> types;
  final String? selectedType;
  final Function(String) onTypeSelected;

  const PropertyTypesWidget({
    super.key,
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final item = types[index];
              final isSelected = selectedType == item['label'];
              return GestureDetector(
                onTap: () => onTypeSelected(item['label']),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: CategoryCard(
                    icon: item['icon'],
                    label: item['label'],
                    isSelected: isSelected,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? context.primaryColor : context.cardColor;
    final contentColor = isSelected ? Colors.white : Theme.of(context).iconTheme.color;

    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: contentColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}