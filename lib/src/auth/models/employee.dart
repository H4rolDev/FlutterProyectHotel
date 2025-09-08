class Employee {
  final int id;
  final String documentType;
  final String documentNumber;
  final String name;
  final String lastName;
  final String phone;
  final String companyId;
  final String userId;

  Employee({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.companyId,
    required this.userId,
  });

  // Crear un Employee desde un JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      name: json['name'],
      lastName: json['lastName'],
      phone: json['phone'],
      companyId: json['companyId'],
      userId: json['userId'],
    );
  }
}
