import 'category_type.dart';

/// The create/update payload for `POST /categories` and
/// `PATCH /categories/:id`.
class CategoryFormData {
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final String? description;

  const CategoryFormData({
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'type': type.toJson(),
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
    };
  }
}
