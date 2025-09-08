import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:hospedaje_f1/src/cleaning/models/room_status.dart';

class RoomStatsWidget extends StatelessWidget {
  final List<Room> rooms;

  const RoomStatsWidget({Key? key, required this.rooms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de Habitaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Necesitan Limpieza',
                  '${stats['needCleaning']}',
                  Icons.warning,
                  const Color(0xFFE53E3E),
                  const Color(0xFFFED7D7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'En Limpieza',
                  '${stats['cleaning']}',
                  Icons.cleaning_services,
                  const Color(0xFFD69E2E),
                  const Color(0xFFFEF5E7),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Ocupadas',
                  '${stats['occupied']}',
                  Icons.bed,
                  const Color(0xFF805AD5),
                  const Color(0xFFF7FAFC),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Listas',
                  '${stats['ready']}',
                  Icons.check_circle,
                  const Color(0xFF38A169),
                  const Color(0xFFF0FFF4),
                ),
              ),
            ],
          ),
          
          // if (stats['needCleaning'] > 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFED7D7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE53E3E), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.priority_high,
                    color: Color(0xFFE53E3E),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '¡Atención! ${stats['needCleaning']} habitaciones necesitan limpieza urgente',
                    style: const TextStyle(
                      color: Color(0xFFE53E3E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStats() {
    int needCleaning = 0;
    int cleaning = 0;
    int occupied = 0;
    int ready = 0;

    for (final room in rooms) {
      final roomStatus = RoomStatus.fromString(room.status);
      final cleaningStatus = CleaningStatus.fromString(room.statusCleaning);

      if (cleaningStatus == CleaningStatus.paraLimpiar && roomStatus == RoomStatus.libre) {
        needCleaning++;
      } else if (cleaningStatus == CleaningStatus.limpiando) {
        cleaning++;
      } else if (roomStatus == RoomStatus.ocupado) {
        occupied++;
      } else if (roomStatus == RoomStatus.libre && cleaningStatus == CleaningStatus.limpio) {
        ready++;
      }
    }

    return {
      'needCleaning': needCleaning,
      'cleaning': cleaning,
      'occupied': occupied,
      'ready': ready,
    };
  }
}