class RoomProductAssignment {
  final int roomId;
  final int productId;
  final String productName;
  final int quantity;

  RoomProductAssignment({
    required this.roomId,
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  factory RoomProductAssignment.fromJson(Map<String, dynamic> json) {
    return RoomProductAssignment(
      roomId: json['roomId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? 'No especificado',
      quantity: json['quantity'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'RoomProductAssignment{roomId: $roomId, productId: $productId, productName: $productName, quantity: $quantity}';
  }
}
