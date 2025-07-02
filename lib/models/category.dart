class Category {
  final int? id;
  final String name;
  final bool isExpense;

  Category({this.id, required this.name, required this.isExpense});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isExpense': isExpense ? 1 : 0,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      isExpense: map['isExpense'] == 1,
    );
  }
}
