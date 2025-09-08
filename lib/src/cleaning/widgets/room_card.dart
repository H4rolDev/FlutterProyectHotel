import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:hospedaje_f1/src/cleaning/helpers/room_status_helper.dart';

class ImprovedRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final bool showDetails;

  const ImprovedRoomCard({
    Key? key,
    required this.room,
    this.onTap,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canClean = RoomStatusHelper.canStartCleaning(room.status, room.statusCleaning);
    final statusColor = RoomStatusHelper.getRoomStatusColor(room.status);
    final cleaningColor = RoomStatusHelper.getCleaningStatusColor(room.statusCleaning);
    final description = RoomStatusHelper.getStatusDescription(room.status, room.statusCleaning);

    return GestureDetector(
      onTap: canClean ? onTap : null,
      child: Container(
        height: showDetails ? 140 : 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canClean ? cleaningColor : statusColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
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
                  color: canClean ? const Color(0xFF4CAF50) : statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      if (canClean)
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
                  
                  // Estados
                  Row(
                    children: [
                      _buildStatusChip(
                        room.status,
                        statusColor,
                        RoomStatusHelper.getRoomStatusIcon(room.status),
                      ),
                      const SizedBox(width: 6),
                      _buildStatusChip(
                        _getCleaningDisplayText(room.statusCleaning),
                        cleaningColor,
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
                        color: canClean ? const Color(0xFF4CAF50) : const Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Overlay para habitaciones no disponibles
            if (!canClean)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      room.status.toUpperCase() == 'OCUPADO' 
                        ? Icons.do_not_disturb 
                        : Icons.build,
                      color: statusColor,
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