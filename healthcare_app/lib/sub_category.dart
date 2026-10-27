class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final String title;
  final String description;
  final String imageUrl;
  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['subCategoryId'],
      categoryId: map['categoryId'],
      name: map['subCategoryName'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }
}