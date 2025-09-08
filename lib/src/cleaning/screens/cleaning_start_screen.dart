import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:hospedaje_f1/src/cleaning/services/cleaning_service.dart';
import 'package:hospedaje_f1/src/cleaning/services/room_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';

class CleaningStartScreen extends StatefulWidget {
  final int roomId;

  const CleaningStartScreen({super.key, required this.roomId});

  @override
  _CleaningStartScreenState createState() => _CleaningStartScreenState();
}

class _CleaningStartScreenState extends State<CleaningStartScreen> {
  bool isLoading = false;
  String? errorMessage;
  late Future<Room?> roomFuture;

  @override
  void initState() {
    super.initState();
    roomFuture = RoomService.getRoomById(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Scaffold(
        backgroundColor: AppColors.secondary300,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context),
              FutureBuilder<Room?>(
                future: roomFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildError('Error al cargar la habitación.');
                  }

                  final room = snapshot.data;

                  if (room == null) {
                    return _buildError('Habitación no encontrada.');
                  }

                  return _buildRoomDetails(room);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              color: Colors.black,
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Detalles de la Limpieza',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildRoomDetails(Room room) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habitación ${room.roomNumber}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              room.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (room.roomProductAssignments.isNotEmpty) ...[
              const Text(
                'Productos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: room.roomProductAssignments.length,
                itemBuilder: (context, index) {
                  final product = room.roomProductAssignments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'x${product.quantity}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _startCleaning(room.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary300,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLoading ? 'Iniciando limpieza...' : 'Iniciar Limpieza',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startCleaning(int roomId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getInt('employeeId');

      if (employeeId == null) {
        setState(() {
          errorMessage = 'Empleado no encontrado';
          isLoading = false;
        });
        return;
      }

      final cleaning = await CleaningService.startCleaning(roomId, employeeId);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.cleaningProgress,
        arguments: {
          'cleaningId': cleaning.id,
          'roomId': roomId,
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error al iniciar la limpieza.';
        isLoading = false;
      });
    }
  }
}
