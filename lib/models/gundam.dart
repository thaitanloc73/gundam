class Gundam {
  final String? id;
  final String name;
  final String grade;
  final String scale;
  final String series;
  final double price;
  final int stock;
  final String imageUrl;

  Gundam({
    this.id,
    required this.name,
    required this.grade,
    required this.scale,
    required this.series,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'scale': scale,
      'series': series,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }

  factory Gundam.fromMap(Map<String, dynamic> map, {String? id}) {
    return Gundam(
      id: id ?? map['id']?.toString(),
      name: map['name'] as String,
      grade: map['grade'] as String,
      scale: map['scale'] as String,
      series: map['series'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      imageUrl: map['imageUrl'] as String,
    );
  }
}
