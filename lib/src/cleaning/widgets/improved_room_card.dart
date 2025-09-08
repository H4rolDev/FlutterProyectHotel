import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:hospedaje_f1/src/cleaning/helpers/room_status_helper.dart';

class ImprovedRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final bool showDetails;
  final String? filterContext; // Nuevo parámetro para saber el contexto del filtro

  const ImprovedRoomCard({
    Key? key,
    required this.room,
    this.onTap,
    this.showDetails = false,
    this.filterContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canClean = RoomStatusHelper.canStartCleaning(room.status, room.statusCleaning);
    
    // Colores dinámicos según el contexto del filtro
    Color primaryColor;
    Color borderColor;
    Color accentColor;
    IconData cardIcon;
    
    switch (filterContext) {
      case 'DISPONIBLES':
        primaryColor = const Color(0xFF48BB78); // Verde intenso
        borderColor = const Color(0xFF48BB78);
        accentColor = const Color(0xFF38A169);
        cardIcon = Icons.cleaning_services;
        break;
      case 'PARA_LIMPIAR':
        primaryColor = const Color(0xFFFFC107); // Amarillo/Naranja
        borderColor = const Color(0xFFFFC107);
        accentColor = const Color(0xFFE0A800);
        cardIcon = Icons.warning;
        break;
      case 'OCUPADAS':
        primaryColor = const Color(0xFFE53E3E); // Rojo
        borderColor = const Color(0xFFE53E3E);
        accentColor = const Color(0xFFC53030);
        cardIcon = Icons.do_not_disturb;
        break;
      case 'LIMPIAS':
        primaryColor = const Color(0xFF4299E1); // Azul
        borderColor = const Color(0xFF4299E1);
        accentColor = const Color(0xFF3182CE);
        cardIcon = Icons.check_circle;
        break;
      case 'MANTENIMIENTO':
        primaryColor = const Color(0xFFED8936); // Naranja
        borderColor = const Color(0xFFED8936);
        accentColor = const Color(0xFFDD6B20);
        cardIcon = Icons.build;
        break;
      default:
        // Lógica original cuando no hay filtro específico
        primaryColor = canClean ? const Color(0xFF48BB78) : RoomStatusHelper.getRoomStatusColor(room.status);
        borderColor = canClean ? RoomStatusHelper.getCleaningStatusColor(room.statusCleaning) : RoomStatusHelper.getRoomStatusColor(room.status);
        accentColor = primaryColor;
        cardIcon = canClean ? Icons.cleaning_services : RoomStatusHelper.getRoomStatusIcon(room.status);
        break;
    }

    final description = RoomStatusHelper.getStatusDescription(room.status, room.statusCleaning);

    return GestureDetector(
      onTap: canClean ? onTap : null,
      child: Container(
        height: showDetails ? 140 : 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Indicador de prioridad lateral
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            
            // Badge superior derecho según filtro
            if (filterContext != null && filterContext != 'TODOS')
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    cardIcon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con número de habitación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.roomNumber,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      if (canClean && filterContext == null)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cleaning_services,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tipo de habitación
                  Text(
                    room.roomTypeName ?? 'Sin tipo',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Estados con colores dinámicos
                  Row(
                    children: [
                      _buildStatusChip(
                        room.status,
                        primaryColor,
                        RoomStatusHelper.getRoomStatusIcon(room.status),
                      ),
                      const SizedBox(width: 6),
                      _buildStatusChip(
                        _getCleaningDisplayText(room.statusCleaning),
                        accentColor,
                        RoomStatusHelper.getCleaningStatusIcon(room.statusCleaning),
                        isSmall: true,
                      ),
                    ],
                  ),
                  
                  if (showDetails) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Overlay para habitaciones no disponibles (solo cuando no hay filtro específico)
            if (!canClean && (filterContext == null || filterContext == 'TODOS'))
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      room.status.toUpperCase() == 'OCUPADO' 
                        ? Icons.do_not_disturb 
                        : Icons.build,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color, IconData icon, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 4 : 6,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmall ? 10 : 12,
            color: color,
          ),
          if (!isSmall) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 8,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getCleaningDisplayText(String statusCleaning) {
    switch (statusCleaning.toUpperCase()) {
      case 'PARA_LIMPIAR':
      case 'PARA LIMPIAR':
        return 'Por limpiar';
      case 'LIMPIANDO':
        return 'Limpiando';
      case 'LIMPIO':
        return 'Limpio';
      default:
        return statusCleaning;
    }
  }
}