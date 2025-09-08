class Room {
  final int id;
  final String roomNumber;
  final String description;
  final int capacity;
  final int floor;
  final String status;
  final String statusCleaning;
  final int roomTypeId;
  final String roomTypeName;
  final List<RoomProductAssignment> roomProductAssignments;

  Room({
    required this.id,
    required this.roomNumber,
    required this.description,
    required this.capacity,
    required this.floor,
    required this.status,
    required this.statusCleaning,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.roomProductAssignments,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      roomNumber: json['number'] ?? '',
      description: json['description'] ?? '',
      capacity: json['capacity'] ?? 0,
      floor: json['floor'] ?? 0,
      status: json['status'] ?? '',
      statusCleaning: json['statusCleaning'] ?? '',
      roomTypeId: json['roomTypeId'] ?? 0,
      roomTypeName: json['roomTypeName'] ?? '',
      roomProductAssignments: (json['roomProductAssignments'] as List<dynamic>?)
          ?.map((item) => RoomProductAssignment.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': roomNumber,
      'description': description,
      'capacity': capacity,
      'floor': floor,
      'status': status,
      'statusCleaning': statusCleaning,
      'roomTypeId': roomTypeId,
      'roomTypeName': roomTypeName,
      'roomProductAssignments': roomProductAssignments.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Room(id: $id, roomNumber: $roomNumber, status: $status, statusCleaning: $statusCleaning)';
  }
}

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
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
    };
  }
}