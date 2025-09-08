import 'package:flutter/material.dart';

class CleaningTipsWidget extends StatelessWidget {
  const CleaningTipsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Guía Rápida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            'Rojo - URGENTE', 
            'Habitaciones libres que necesitan limpieza inmediata',
            Icons.warning,
            const Color(0xFFE53E3E),
          ),
          _buildTipItem(
            'Morado - NO MOLESTAR', 
            'Habitaciones ocupadas, respetar la privacidad del huésped',
            Icons.do_not_disturb,
            const Color(0xFF805AD5),
          ),
          _buildTipItem(
            'Amarillo - EN PROCESO', 
            'Limpieza iniciada, continuar o revisar progreso',
            Icons.cleaning_services,
            const Color(0xFFD69E2E),
          ),
          _buildTipItem(
            'Verde - LISTAS', 
            'Habitaciones limpias y disponibles para huéspedes',
            Icons.check_circle,
            const Color(0xFF38A169),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}