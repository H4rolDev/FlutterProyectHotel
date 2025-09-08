class Cleaning {
  final int id;
  final int roomId;
  final int employeeId;
  final String roomNumber; // Añadido aquí
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? cancellationDate;
  final List<Incident>? incidents;

  Cleaning({
    required this.id,
    required this.roomId,
    required this.employeeId,
    required this.roomNumber, // Añadido aquí
    required this.status,
    required this.startDate,
    this.endDate,
    this.cancellationDate,
    this.incidents,
  });

  factory Cleaning.fromJson(Map<String, dynamic> json) {
    var incidentList = (json['incidents'] != null && json['incidents'] is List)
        ? (json['incidents'] as List)
            .map((incidentJson) => Incident.fromJson(incidentJson))
            .toList()
        : null;

    return Cleaning(
      id: json['id'] ?? 0,
      roomId: json['roomId'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      roomNumber: json['roomNumber'] ?? '',
      status: json['status'] ?? 'Desconocido',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      cancellationDate: json['cancellationDate'] != null
          ? DateTime.parse(json['cancellationDate'])
          : null,
      incidents: incidentList,
    );
  }

  Map<String, dynamic> toJson() {
    var incidentListJson = incidents?.map((incident) => incident.toJson()).toList();

    return {
      'id': id,
      'roomId': roomId,
      'employeeId': employeeId,
      'roomNumber': roomNumber, 
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cancellationDate': cancellationDate?.toIso8601String(),
      'incidents': incidentListJson,
    };
  }
}

class Incident {
  final int id;
  final int cleaningId;
  final String description;
  final List<IncidentPhoto>? incidentPhotos;

  Incident({
    required this.id,
    required this.cleaningId,
    required this.description,
    this.incidentPhotos,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    var photoList =
        (json['incidentPhotos'] != null && json['incidentPhotos'] is List)
            ? (json['incidentPhotos'] as List)
                .map((photoJson) => IncidentPhoto.fromJson(photoJson))
                .toList()
            : null;

    return Incident(
      id: json['id'] ?? 0,
      cleaningId: json['cleaningId'] ?? 0,
      description: json['description'] ?? '',
      incidentPhotos: photoList,
    );
  }

  Map<String, dynamic> toJson() {
    var photoListJson = incidentPhotos?.map((photo) => photo.toJson()).toList();

    return {
      'id': id,
      'cleaningId': cleaningId,
      'description': description,
      'incidentPhotos': photoListJson,
    };
  }
}

class IncidentPhoto {
  final int id;
  final int incidentId;
  final String imageUrl;

  IncidentPhoto({
    required this.id,
    required this.incidentId,
    required this.imageUrl,
  });

  factory IncidentPhoto.fromJson(Map<String, dynamic> json) {
    return IncidentPhoto(
      id: json['id'] ?? 0,
      incidentId: json['incidentId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incidentId': incidentId,
      'imageUrl': imageUrl,
    };
  }
}
