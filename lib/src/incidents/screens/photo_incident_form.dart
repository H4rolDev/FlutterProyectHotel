import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/incidents/services/incidence_photo_service.dart';
import 'package:image_picker/image_picker.dart';

class PhotoIncidentForm extends StatefulWidget {
  final int incidentId;
  final VoidCallback onCancel;
  final Function(bool) onUploadComplete;

  const PhotoIncidentForm({
    super.key,
    required this.incidentId,
    required this.onCancel,
    required this.onUploadComplete,
  });

  @override
  _PhotoIncidentFormState createState() => _PhotoIncidentFormState();
}

class _PhotoIncidentFormState extends State<PhotoIncidentForm> {
  String? _fileName;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  Future<void> _pickFile() async {
  final ImagePicker picker = ImagePicker();
  
  final option = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Seleccionar imagen'),
      content: const Text('¿Cómo deseas obtener la imagen?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.camera),
          child: const Text('Tomar foto'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
          child: const Text('Galería'),
        ),
      ],
    ),
  );

  if (option == null) return;

  try {
    final XFile? file = await picker.pickImage(
      source: option,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _fileName = file.name; // Añade esta línea
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al obtener la imagen: ${e.toString()}')),
    );
  }
}


  void _cancelImage() {
    setState(() {
      _fileName = null;
      _imageBytes = null;
    });
  }

  Future<void> _uploadImage() async {
  if (_imageBytes == null) return; // Elimina la condición de _fileName

  setState(() {
    _isLoading = true;
  });

  try {
    final success = await IncidentPhotoService.uploadIncidentPhoto(
      incidentId: widget.incidentId,
      imageBytes: _imageBytes!,
      fileName: _fileName ?? 'incidencia_${widget.incidentId}.jpg', // Proporciona un nombre por defecto
    );

    widget.onUploadComplete(success);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success 
          ? 'Foto subida con éxito' 
          : 'Error al subir la foto'),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al subir la foto: ${e.toString()}')), // Muestra el error real
    );
    widget.onUploadComplete(false);
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono de cerrar
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
                color: AppColors.primary300,
                iconSize: 30,
              ),
            ),

            const SizedBox(height: 0),

            // Título
            const Text(
              'Agregar foto a la incidencia',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),

            const SizedBox(height: 20),

            // Contenido
            Center(
              child: _imageBytes == null
                  ? GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: AppColors.primary500,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Seleccionar foto',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _isLoading ? null : _uploadImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary500,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Subir'),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: _isLoading ? null : _cancelImage,
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
