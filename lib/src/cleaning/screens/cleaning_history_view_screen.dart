import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/cleaning/services/cleaning_service.dart';
import 'package:hospedaje_f1/src/cleaning/models/cleaning.dart';
import 'package:hospedaje_f1/src/cleaning/services/room_service.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:intl/intl.dart';

class CleaningHistoryViewScreen extends StatefulWidget {
  const CleaningHistoryViewScreen({super.key});

  @override
  _CleaningHistoryViewScreenState createState() =>
      _CleaningHistoryViewScreenState();
}

class _CleaningHistoryViewScreenState extends State<CleaningHistoryViewScreen> {
  late Future<Cleaning?> _cleaning;
  late Future<Room?> _room;
  final DateFormat dateFormatter = DateFormat("dd/MM/yyyy HH:mm");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cleaningId = ModalRoute.of(context)!.settings.arguments as int;
    _cleaning = CleaningService.getCleaningById(cleaningId);
    _loadRoom(cleaningId);
  }

  Future<void> _loadRoom(int cleaningId) async {
    final cleaning = await CleaningService.getCleaningById(cleaningId);
    if (cleaning != null) {
      setState(() {
        _room = RoomService.getRoomById(cleaning.roomId);
      });
    }
  }

  Future<void> _refreshCleaning() async {
    final cleaningId = ModalRoute.of(context)!.settings.arguments as int;
    setState(() {
      _cleaning = CleaningService.getCleaningById(cleaningId);
      _loadRoom(cleaningId);
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERMINADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      case 'EN_PROGRESO':
      case 'LIMPIANDO':
        return Colors.orange;
      default:
        return const Color(0xFF1E3A8A);
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'TERMINADO':
        return 'Completado';
      case 'CANCELADO':
        return 'Cancelado';
      case 'EN_PROGRESO':
      case 'LIMPIANDO':
        return 'En Progreso';
      default:
        return status;
    }
  }

  Widget _buildPhotoGallery(List<dynamic> photos) {
    if (photos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1E3A8A).withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay fotos de esta incidencia',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.photo_camera,
              color: Color(0xFF1E3A8A),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Evidencia Fotográfica',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${photos.length} ${photos.length == 1 ? 'foto' : 'fotos'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: photos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;

                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF1E3A8A).withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.network(
                            photo.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF8F6F0),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1E3A8A),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Error\nal cargar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Número de foto
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<Cleaning?>(
          future: _cleaning,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1E3A8A),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text('No se encontró la limpieza.'),
                  ],
                ),
              );
            } else {
              final cleaning = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refreshCleaning,
                color: const Color(0xFF1E3A8A),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Cabecera moderna
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1E3A8A),
                              const Color(0xFF1E40AF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Detalles de Limpieza',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Detalles de la limpieza y habitación
                      FutureBuilder<Room?>(
                        future: _room,
                        builder: (context, roomSnapshot) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              children: [
                                // Información de la habitación
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E3A8A).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.bed,
                                              color: Color(0xFF1E3A8A),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            roomSnapshot.hasData && roomSnapshot.data != null
                                                ? 'Habitación ${roomSnapshot.data!.roomNumber}'
                                                : 'Habitación ${cleaning.roomId}',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E3A8A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (roomSnapshot.hasData && roomSnapshot.data != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          roomSnapshot.data!.description,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Información de la limpieza
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(cleaning.status).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.cleaning_services,
                                              color: _getStatusColor(cleaning.status),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Estado de Limpieza',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Estado
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Color(0xFF1E3A8A),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Estado:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(cleaning.status),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getStatusText(cleaning.status),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      
                                      // Fecha de inicio
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.play_arrow,
                                            color: Color(0xFF1E3A8A),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Inicio:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            dateFormatter.format(cleaning.startDate),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF1E3A8A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Fecha de finalización
                                      if (cleaning.endDate != null) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Finalización:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              dateFormatter.format(cleaning.endDate!),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      
                                      // Fecha de cancelación
                                      if (cleaning.cancellationDate != null) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Cancelación:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              dateFormatter.format(cleaning.cancellationDate!),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Sección de incidencias
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.report_problem,
                                              color: Colors.orange,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Incidencias',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Mostrar incidencias
                                      if (cleaning.incidents != null && cleaning.incidents!.isNotEmpty)
                                        ...cleaning.incidents!.map((incident) {
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8F6F0),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF1E3A8A).withOpacity(0.2),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.description,
                                                      color: Color(0xFF1E3A8A),
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Descripción:',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  incident.description,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                
                                                // Galería de fotos
                                                _buildPhotoGallery(incident.incidentPhotos ?? []),
                                              ],
                                            ),
                                          );
                                        })
                                      else
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8F6F0),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFF1E3A8A).withOpacity(0.2),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.grey[400],
                                                size: 40,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'No hay incidencias registradas',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}