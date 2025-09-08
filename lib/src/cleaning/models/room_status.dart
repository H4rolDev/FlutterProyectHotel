import 'package:flutter/material.dart';

enum RoomStatus {
  libre('LIBRE', 'Libre', 'Disponible para huéspedes'),
  ocupado('OCUPADO', 'Ocupado', 'Huésped en la habitación'),
  mantenimiento('MANTENIMIENTO', 'Mantenimiento', 'En reparación o mantenimiento');

  const RoomStatus(this.apiValue, this.displayName, this.description);

  final String apiValue;
  final String displayName;
  final String description;

  static RoomStatus fromString(String value) {
    return RoomStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => RoomStatus.libre,
    );
  }
}

enum CleaningStatus {
  limpio('LIMPIO', 'Limpio', 'Habitación lista'),
  paraLimpiar('PARA_LIMPIAR', 'Para Limpiar', 'Requiere limpieza'),
  limpiando('LIMPIANDO', 'Limpiando', 'En proceso de limpieza');

  const CleaningStatus(this.apiValue, this.displayName, this.description);

  final String apiValue;
  final String displayName;
  final String description;

  static CleaningStatus fromString(String value) {
    return CleaningStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => CleaningStatus.paraLimpiar,
    );
  }
}

class RoomStatusHelper {
  static Map<String, dynamic> getStatusColor(RoomStatus roomStatus, CleaningStatus cleaningStatus) {
    // Prioridad para personal de limpieza
    if (cleaningStatus == CleaningStatus.paraLimpiar && roomStatus == RoomStatus.libre) {
      return {
        'color': const Color(0xFFE53E3E), // Rojo - Alta prioridad
        'backgroundColor': const Color(0xFFFED7D7),
        'priority': 1,
        'actionable': true,
        'message': 'Necesita limpieza urgente'
      };
    }
    
    if (cleaningStatus == CleaningStatus.limpiando) {
      return {
        'color': const Color(0xFFD69E2E), // Amarillo - En proceso
        'backgroundColor': const Color(0xFFFEF5E7),
        'priority': 2,
        'actionable': false,
        'message': 'Limpieza en proceso'
      };
    }
    
    if (roomStatus == RoomStatus.ocupado) {
      return {
        'color': const Color(0xFF805AD5), // Morado - No molestar
        'backgroundColor': const Color(0xFFF7FAFC),
        'priority': 4,
        'actionable': false,
        'message': 'Huésped presente - No molestar'
      };
    }
    
    if (roomStatus == RoomStatus.mantenimiento) {
      return {
        'color': const Color(0xFF718096), // Gris - Mantenimiento
        'backgroundColor': const Color(0xFFEDF2F7),
        'priority': 5,
        'actionable': false,
        'message': 'En mantenimiento'
      };
    }
    
    // Habitación lista (libre y limpia)
    return {
      'color': const Color(0xFF38A169), // Verde - Todo bien
      'backgroundColor': const Color(0xFFF0FFF4),
      'priority': 3,
      'actionable': false,
      'message': 'Habitación lista'
    };
  }
  
  static String getPriorityLabel(int priority) {
    switch (priority) {
      case 1: return 'URGENTE';
      case 2: return 'EN PROCESO';
      case 3: return 'LISTA';
      case 4: return 'OCUPADA';
      case 5: return 'MANTENIMIENTO';
      default: return '';
    }
  }
}
