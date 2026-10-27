class Bike {
  final int id;
  final int subCategoryId;
  final String name;
  final String imageUrl;
  final double price;
  final String? brakes;
  final String? wheels;
  final String? frame;
  final String? weight;
  final String? drivetrain;
  final String? fork;
  final String? rearShock;
  final String? tires;

  Bike({
    required this.id,
    required this.subCategoryId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.brakes,
    required this.wheels,
    required this.frame,
    required this.weight,
    required this.drivetrain,
    required this.fork,
    required this.rearShock,
    required this.tires,
  });

  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['bikeId'],
      subCategoryId: map['subCategoryId'],
      name: map['bikeName'],
      imageUrl: map['imageUrl'],
      price: (map['price'] as num).toDouble(),
      brakes: map['brakes'],
      wheels: map['wheels'],
      frame: map['frame'],
      weight: map['weight'],
      drivetrain: map['drivetrain'],
      fork: map['fork'],
      rearShock: map['rearShock'],
      tires: map['tires'],
    );
  }
}