import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:hospedaje_f1/src/cleaning/models/room_status.dart';

class StatusRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;

  const StatusRoomCard({
    Key? key,
    required this.room,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomStatus = RoomStatus.fromString(room.status);
    final cleaningStatus = CleaningStatus.fromString(room.statusCleaning);
    final statusInfo = RoomStatusHelper.getStatusColor(roomStatus, cleaningStatus);

    return GestureDetector(
      onTap: statusInfo['actionable'] ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: statusInfo['backgroundColor'],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusInfo['color'],
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: statusInfo['color'].withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Número de habitación y prioridad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      room.roomNumber,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statusInfo['color'],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (statusInfo['priority'] <= 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo['color'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        RoomStatusHelper.getPriorityLabel(statusInfo['priority']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Icono de estado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(roomStatus, cleaningStatus),
                  color: statusInfo['color'],
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tipo de habitación y piso
              Text(
                '${room.roomTypeName} - Piso ${room.floor}',
                style: TextStyle(
                  fontSize: 12,
                  color: statusInfo['color'].withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // Capacidad (importante para saber cuántas camas limpiar)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bed,
                    size: 14,
                    color: statusInfo['color'].withOpacity(0.7),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${room.capacity} ${room.capacity == 1 ? 'persona' : 'personas'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusInfo['color'].withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Mensaje de estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusInfo['message'],
                  style: TextStyle(
                    fontSize: 10,
                    color: statusInfo['color'],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Indicador si es accionable
              if (statusInfo['actionable'])
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Colors.black45,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(RoomStatus roomStatus, CleaningStatus cleaningStatus) {
    if (cleaningStatus == CleaningStatus.limpiando) {
      return Icons.cleaning_services;
    }
    
    if (cleaningStatus == CleaningStatus.paraLimpiar) {
      return Icons.warning;
    }
    
    switch (roomStatus) {
      case RoomStatus.ocupado:
        return Icons.bed;
      case RoomStatus.mantenimiento:
        return Icons.build;
      case RoomStatus.libre:
        return cleaningStatus == CleaningStatus.limpio 
            ? Icons.check_circle 
            : Icons.cleaning_services;
    }
  }
}