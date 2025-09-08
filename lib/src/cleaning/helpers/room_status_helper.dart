import 'package:flutter/material.dart';

class RoomStatusHelper {
  // Colores para estados de habitación
  static Color getRoomStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'LIBRE':
        return const Color(0xFF4CAF50); // Verde - disponible
      case 'OCUPADO':
        return const Color(0xFFE53E3E); // Rojo - ocupado (no molestar)
      case 'MANTENIMIENTO':
        return const Color(0xFFFF9800); // Naranja - en mantenimiento
      default:
        return Colors.grey;
    }
  }

  // Colores para estados de limpieza
  static Color getCleaningStatusColor(String statusCleaning) {
    switch (statusCleaning.toUpperCase()) {
      case 'LIMPIO':
        return const Color(0xFF2196F3); // Azul - limpio
      case 'PARA_LIMPIAR':
      case 'PARA LIMPIAR':
        return const Color(0xFFFFC107); // Amarillo - necesita limpieza
      case 'LIMPIANDO':
        return const Color(0xFF9C27B0); // Púrpura - en proceso de limpieza
      default:
        return Colors.grey;
    }
  }

  // Iconos para estados de habitación
  static IconData getRoomStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'LIBRE':
        return Icons.check_circle;
      case 'OCUPADO':
        return Icons.person;
      case 'MANTENIMIENTO':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }

  // Iconos para estados de limpieza
  static IconData getCleaningStatusIcon(String statusCleaning) {
    switch (statusCleaning.toUpperCase()) {
      case 'LIMPIO':
        return Icons.cleaning_services;
      case 'PARA_LIMPIAR':
      case 'PARA LIMPIAR':
        return Icons.warning;
      case 'LIMPIANDO':
        return Icons.refresh;
      default:
        return Icons.help_outline;
    }
  }

  // Obtener prioridad de limpieza (para ordenar)
  static int getCleaningPriority(String status, String statusCleaning) {
    // Prioridad más alta = número menor
    if (statusCleaning.toUpperCase().contains('PARA') && status.toUpperCase() == 'LIBRE') {
      return 1; // Máxima prioridad: libre y necesita limpieza
    }
    if (statusCleaning.toUpperCase().contains('LIMPIANDO')) {
      return 2; // En proceso
    }
    if (statusCleaning.toUpperCase().contains('PARA') && status.toUpperCase() == 'OCUPADO') {
      return 3; // Ocupado pero necesita limpieza después
    }
    if (status.toUpperCase() == 'MANTENIMIENTO') {
      return 4; // Mantenimiento
    }
    return 5; // Otros casos
  }

  // Mensaje descriptivo para el personal
  static String getStatusDescription(String status, String statusCleaning) {
    final roomStatus = status.toUpperCase();
    final cleanStatus = statusCleaning.toUpperCase();

    if (roomStatus == 'OCUPADO' && cleanStatus.contains('PARA')) {
      return 'Pendiente - Huésped presente';
    }
    if (roomStatus == 'LIBRE' && cleanStatus.contains('PARA')) {
      return 'Listo para limpiar';
    }
    if (cleanStatus.contains('LIMPIANDO')) {
      return 'Limpieza en proceso';
    }
    if (cleanStatus == 'LIMPIO') {
      return 'Habitación lista';
    }
    if (roomStatus == 'MANTENIMIENTO') {
      return 'En mantenimiento';
    }
    return 'Estado: $status';
  }

  // Verificar si se puede iniciar limpieza
  static bool canStartCleaning(String status, String statusCleaning) {
    return status.toUpperCase() == 'LIBRE' && 
           statusCleaning.toUpperCase().contains('PARA');
  }
}