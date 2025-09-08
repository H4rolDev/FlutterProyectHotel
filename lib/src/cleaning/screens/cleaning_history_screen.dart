import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:hospedaje_f1/src/cleaning/services/cleaning_service.dart';
import 'package:hospedaje_f1/src/cleaning/models/cleaning.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospedaje_f1/core/colors.dart';

class CleaningHistoryScreen extends StatefulWidget {
  const CleaningHistoryScreen({super.key});

  @override
  _CleaningHistoryScreenState createState() => _CleaningHistoryScreenState();
}

class _CleaningHistoryScreenState extends State<CleaningHistoryScreen> {
  int _currentPage = 0;
  int _itemsPerPage = 10;
  int _totalItems = 0;
  int _totalPages = 0;
  bool _isLoading = false;
  List<Cleaning> _cleanings = [];
  int? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployeeIdAndCleanings();
  }

  Future<void> _loadEmployeeIdAndCleanings() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('employeeId');
    if (id == null) {
      _showErrorSnackBar('Empleado no encontrado.');
      return;
    }
    setState(() => _employeeId = id);
    _loadCleanings();
  }

  Future<void> _loadCleanings() async {
    if (_employeeId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await CleaningService.getCleaningsByEmployeeId(
        _employeeId!,
        page: _currentPage,
        size: _itemsPerPage,
        sort: 'id,desc',
      );
      setState(() {
        _cleanings = (response['content'] as List)
            .map((e) => Cleaning.fromJson(e))
            .toList();
        _totalItems = response['totalElements'];
        _totalPages = response['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar limpiezas: $e');
    }
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

  List<int> _getPaginationOptions() {
    if (_totalItems <= 25) {
      return [];
    } else if (_totalItems <= 50) {
      return [10, 25];
    } else if (_totalItems <= 100) {
      return [10, 25, 50];
    } else {
      return [10, 25, 50, 100];
    }
  }

  void _changeItemsPerPage(int? newSize) {
    if (newSize != null && newSize != _itemsPerPage) {
      setState(() {
        _itemsPerPage = newSize;
        _currentPage = 0;
      });
      _loadCleanings();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERMINADO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      case 'EN PROCESO':
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
      case 'EN PROCESO':
      case 'LIMPIANDO':
        return 'En Proceso';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERMINADO':
        return Icons.check_circle;
      case 'CANCELADO':
        return Icons.cancel;
      case 'EN PROCESO':
      case 'LIMPIANDO':
        return Icons.hourglass_empty;
      default:
        return Icons.cleaning_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (_getPaginationOptions().isNotEmpty) _buildItemsPerPageSelector(),
                    const SizedBox(height: 16),
                    _isLoading
                        ? _buildLoadingState()
                        : _cleanings.isEmpty
                            ? _buildEmptyState()
                            : _buildCleaningsList(),
                    if (_totalItems > _itemsPerPage) _buildPaginationControls(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Historial de Limpiezas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalItems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsPerPageSelector() {
    final options = _getPaginationOptions();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.view_list,
            color: Color(0xFF1E3A8A),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'Mostrar',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF1E3A8A).withOpacity(0.3),
              ),
            ),
            child: DropdownButton<int>(
              value: _itemsPerPage,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1E3A8A)),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
              ),
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: _changeItemsPerPage,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'limpiezas',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: Color(0xFF1E3A8A),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Cargando historial...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay limpiezas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las limpiezas realizadas aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleaningsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _cleanings.length,
      itemBuilder: (context, index) {
        final cleaning = _cleanings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.cleaningHistoryView,
                arguments: cleaning.id,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icono de estado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(cleaning.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(cleaning.status),
                        color: _getStatusColor(cleaning.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Información de la limpieza
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fecha y hora
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF1E3A8A),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${cleaning.startDate.day.toString().padLeft(2, '0')}/${cleaning.startDate.month.toString().padLeft(2, '0')}/${cleaning.startDate.year.toString().substring(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF1E3A8A),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${cleaning.startDate.hour.toString().padLeft(2, '0')}:${cleaning.startDate.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Estado
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF1E3A8A),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Estado:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Badge de estado
                              if (cleaning.status == 'En Proceso')
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.cleaningProgress,
                                    arguments: {
                                      'cleaningId': cleaning.id,
                                      'roomId': cleaning.roomId,
                                    },
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(cleaning.status),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getStatusColor(cleaning.status).withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Continuar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
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
                        ],
                      ),
                    ),
                    
                    // Flecha indicadora
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF1E3A8A),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(
            icon: Icons.chevron_left,
            enabled: _currentPage > 0,
            onPressed: () {
              setState(() => _currentPage--);
              _loadCleanings();
            },
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Página ${_currentPage + 1} de $_totalPages',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          const SizedBox(width: 24),
          _buildPaginationButton(
            icon: Icons.chevron_right,
            enabled: _currentPage < _totalPages - 1,
            onPressed: () {
              setState(() => _currentPage++);
              _loadCleanings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF1E3A8A) : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey[500],
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}