import 'package:flutter/material.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/incidents/services/incidence_service.dart';

class IncidenceForm extends StatefulWidget {
  final int cleaningId;
  final VoidCallback onCancel;
  final Function(bool)
      onSaveComplete; // Cambiamos este callback para recibir el estado

  const IncidenceForm({
    required this.cleaningId,
    required this.onCancel,
    required this.onSaveComplete,
    super.key,
  });

  @override
  _IncidenceFormState createState() => _IncidenceFormState();
}

class _IncidenceFormState extends State<IncidenceForm> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createIncidence() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descripción vacía')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await IncidenceService.createIncidence(
        _descriptionController.text,
        widget.cleaningId,
      );

      widget.onSaveComplete(success);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidencia creada con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la incidencia')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la incidencia')),
      );
      widget.onSaveComplete(false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        // Añade esto para ajustar la altura al contenido
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Esto es crucial para que no ocupe toda la altura
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

            const SizedBox(height: 8),

            // Título
            const Text(
              'Descripción de la incidencia:',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),

            const SizedBox(height: 12),

            // Campo de texto
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              minLines: 4,
              decoration: InputDecoration(
                hintText: 'Escriba la descripción de la incidencia...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary300),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botón de guardar
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createIncidence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar Incidencia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
