class PagedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  PagedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
  factory PagedResult.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) convert,
  ) {
    List<dynamic> list = map['items'];
    return PagedResult(
      items: list.map((p) => convert(p as Map<String, dynamic>)).toList(),
      total: map['total'],
      page: map['page'],
      pageSize: map['pageSize'],
      totalPages: map['totalPages'],
    );
  }
}