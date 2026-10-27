class Category {
  final int id;
  final String name;
  final String title;
  final String description;
  final String icon;
  Category({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.icon,
  });
  factory Category.fromJson(Map<String, dynamic> map) {
    return Category(
      id: map['categoryId'],
      name: map['categoryName'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
    );
  }
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'icon': icon,
    };
  }
}