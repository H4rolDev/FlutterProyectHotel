import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/incidents/services/incidence_photo_service.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:hospedaje_f1/src/cleaning/services/cleaning_service.dart';
import 'package:hospedaje_f1/src/cleaning/services/room_service.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:hospedaje_f1/src/incidents/screens/incidence_form.dart';
import 'package:hospedaje_f1/src/cleaning/models/cleaning.dart';
import 'package:image_picker/image_picker.dart';

class CleaningProgressScreen extends StatefulWidget {
  final int cleaningId;
  final int roomId;

  const CleaningProgressScreen({
    super.key,
    required this.cleaningId,
    required this.roomId,
  });

  @override
  _CleaningProgressScreenState createState() => _CleaningProgressScreenState();
}

class _CleaningProgressScreenState extends State<CleaningProgressScreen> {
  bool _isLoading = false;
  String _roomStatus = 'Limpiando';
  Cleaning? _cleaning;
  late Future<Room?> _roomFuture;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _roomFuture = RoomService.getRoomById(widget.roomId);
    _getCleaningDetails();
  }

  Future<void> _getCleaningDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Cleaning? cleaning = await CleaningService.getCleaningById(
        widget.cleaningId,
      );
      setState(() {
        _cleaning = cleaning;
      });
    } catch (e) {
      setState(() {
        _cleaning = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _finishCleaning() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await CleaningService.updateCleaningStatus(
        widget.cleaningId,
        'TERMINADO',
      );
      setState(() {
        _roomStatus = 'Limpieza terminada';
      });

      Navigator.pushReplacementNamed(context, AppRoutes.roomList);
    } catch (e) {
      setState(() {
        _roomStatus = 'Error al terminar la limpieza';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelCleaning() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await CleaningService.updateCleaningStatus(
        widget.cleaningId,
        'CANCELADO',
      );
      setState(() {
        _roomStatus = 'Limpieza cancelada';
      });

      Navigator.pushReplacementNamed(context, AppRoutes.roomList);
    } catch (e) {
      setState(() {
        _roomStatus = 'Error al cancelar la limpieza';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showIncidenceModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.secondary300,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: IncidenceForm(
                cleaningId: widget.cleaningId,
                onCancel: () => Navigator.of(context).pop(),
                onSaveComplete: (success) async {
                  if (success) {
                    Navigator.of(context).pop();
                    await _getCleaningDetails();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Métodos para gestión de fotos mejorados
  Future<void> _showPhotoSourceModal(int incidentId) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F6F0), // Color beige
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Agregar Imagen a la Incidencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona una opción para documentar la incidencia',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoSourceOption(
                    icon: Icons.photo_camera,
                    title: 'Tomar Foto',
                    subtitle: 'Usar cámara',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.camera, incidentId);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoSourceOption(
                    icon: Icons.photo_library,
                    title: 'Galería',
                    subtitle: 'Elegir existente',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.gallery, incidentId);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF1E3A8A).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source, int incidentId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice:
            CameraDevice.rear, // Especifica la cámara trasera
      );

      if (image != null) {
        setState(() {
          _isUploadingPhoto = true;
        });

        final bytes = await image.readAsBytes();
        final fileName = image.name;

        final result = await IncidentPhotoService.uploadIncidentPhoto(
          incidentId: incidentId,
          imageBytes: bytes,
          fileName: fileName,
        );

        if (result) {
          _showSuccessSnackBar('Foto agregada correctamente');
          await _getCleaningDetails();
        } else {
          _showErrorSnackBar('Error al agregar la foto');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar imagen: ${e.toString()}');
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final confirm = await _showDeleteConfirmDialog();
    if (!confirm) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final success = await IncidentPhotoService.deleteIncidentPhoto(photoId);

      if (success) {
        _showSuccessSnackBar('Foto eliminada correctamente');
        await _getCleaningDetails();
      } else {
        _showErrorSnackBar('Error al eliminar la foto');
      }
    } catch (e) {
      _showErrorSnackBar('Error al eliminar la foto: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFF8F6F0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Eliminar Foto',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              '¿Está seguro de que desea eliminar esta foto de la incidencia?',
              style: TextStyle(color: Color(0xFF1E3A8A)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPhotoSection(dynamic incident) {
    final photos = incident.incidentPhotos ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_camera, color: Color(0xFF1E3A8A), size: 16),
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
              children: [
                // Botón para agregar foto mejorado
                GestureDetector(
                  onTap: _isUploadingPhoto
                      ? null
                      : () => _showPhotoSourceModal(incident.id),
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isUploadingPhoto
                            ? Colors.grey.withOpacity(0.5)
                            : const Color(0xFF1E3A8A),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isUploadingPhoto)
                          const CircularProgressIndicator(
                            color: Color(0xFF1E3A8A),
                            strokeWidth: 3,
                          )
                        else
                          const Icon(
                            Icons.add_a_photo,
                            size: 32,
                            color: Color(0xFF1E3A8A),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          _isUploadingPhoto ? 'Subiendo...' : 'Agregar\nImagen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isUploadingPhoto
                                ? Colors.grey
                                : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fotos existentes con mejor diseño
                ...photos.asMap().entries.map((entry) {
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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

                        // Botón de eliminar mejorado
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _deletePhoto(photo.id),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),

                        // Número de foto con mejor diseño
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                }),
              ],
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)],
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Limpieza en Proceso',
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
              FutureBuilder<Room?>(
                future: _roomFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar la habitación.'),
                    );
                  }

                  final room = snapshot.data;

                  if (room == null) {
                    return const Center(
                      child: Text('Habitación no encontrada.'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        // Contenedor detalles habitación
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
                                      color: const Color(
                                        0xFF1E3A8A,
                                      ).withOpacity(0.1),
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
                                    'Habitación ${room.roomNumber}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                room.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              if (room.roomProductAssignments.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory_2,
                                      color: Color(0xFF1E3A8A),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Productos necesarios',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F6F0),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF1E3A8A,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        room.roomProductAssignments.length,
                                    itemBuilder: (context, index) {
                                      final product =
                                          room.roomProductAssignments[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF1E3A8A),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                product.productName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF1E3A8A,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'x${product.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E3A8A),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Contenedor de incidencias con sistema integrado de fotos
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      onPressed: _showIncidenceModal,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      iconSize: 20,
                                      tooltip: 'Agregar Incidencia',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Mostrar incidencias con el sistema integrado de fotos
                              if (_cleaning != null &&
                                  _cleaning!.incidents != null &&
                                  _cleaning!.incidents!.isNotEmpty)
                                ..._cleaning!.incidents!.map((incident) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F6F0),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF1E3A8A,
                                        ).withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                                        // Sistema de gestión de fotos integrado
                                        _buildPhotoSection(incident),
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
                                      color: const Color(
                                        0xFF1E3A8A,
                                      ).withOpacity(0.2),
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
                                      const SizedBox(height: 4),
                                      Text(
                                        'Presiona + para agregar una incidencia',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Botones de acción mejorados
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _finishCleaning,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isLoading)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isLoading
                                            ? 'Terminando...'
                                            : 'Terminar Limpieza',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _cancelCleaning,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isLoading)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isLoading
                                            ? 'Cancelando...'
                                            : 'Cancelar Limpieza',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}
