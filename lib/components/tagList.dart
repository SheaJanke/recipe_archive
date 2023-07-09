import 'package:flutter/material.dart';
import 'package:recipe_archive/constants/colors.dart';

class TagList extends StatelessWidget {
  const TagList(this.tags, this.onDeleteTag, {super.key});

  final List<String> tags;
  final Function(String deletedTag)? onDeleteTag;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (String tag in tags)
          Chip(
            backgroundColor: TAG_COLOR,
            label: Text('#$tag'),
            onDeleted: () => onDeleteTag!(tag),
            deleteIcon: onDeleteTag != null
                ? const Icon(
                    Icons.close,
                    size: 20,
                  )
                : null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
