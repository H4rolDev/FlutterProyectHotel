import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/cleaning/services/room_service.dart';
import 'package:hospedaje_f1/src/cleaning/widgets/improved_room_card.dart';
import 'package:hospedaje_f1/src/cleaning/helpers/room_status_helper.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:hospedaje_f1/src/cleaning/models/room.dart';
import 'package:hospedaje_f1/src/cleaning/models/cleaning.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';
import 'package:hospedaje_f1/src/cleaning/services/cleaning_service.dart';
import 'package:intl/intl.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> with TickerProviderStateMixin {
  List<Room> allRooms = [];
  List<Cleaning> cleaningsInProcess = [];
  bool loading = true;
  String selectedFilter = 'TODOS';
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    );
    loadData();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final roomList = await RoomService.getAllRooms();
      final cleaningsList = await CleaningService.getCleaningsByFilter(
        employeeId: 1,
        status: 'EN_PROCESO',
      );
      setState(() {
        allRooms = roomList;
        cleaningsInProcess = cleaningsList;
      });
      _headerAnimationController.forward();
    } catch (e) {
      debugPrint('Error loading data: $e');
      _showErrorSnackBar('Error al cargar las habitaciones');
    } finally {
      setState(() => loading = false);
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

  List<Room> get filteredRooms {
    List<Room> filtered = List.from(allRooms);
    
    switch (selectedFilter) {
      case 'PARA_LIMPIAR':
        filtered = filtered.where((room) => 
          room.statusCleaning.toUpperCase().contains('PARA')).toList();
        break;
      case 'DISPONIBLES':
        filtered = filtered.where((room) => 
          RoomStatusHelper.canStartCleaning(room.status, room.statusCleaning)).toList();
        break;
      case 'OCUPADAS':
        filtered = filtered.where((room) => 
          room.status.toUpperCase() == 'OCUPADO').toList();
        break;
      case 'LIMPIAS':
        filtered = filtered.where((room) => 
          room.statusCleaning.toUpperCase() == 'LIMPIO').toList();
        break;
      case 'MANTENIMIENTO':
        filtered = filtered.where((room) => 
          room.status.toUpperCase() == 'MANTENIMIENTO').toList();
        break;
    }

    filtered.sort((a, b) {
      final priorityA = RoomStatusHelper.getCleaningPriority(a.status, a.statusCleaning);
      final priorityB = RoomStatusHelper.getCleaningPriority(b.status, b.statusCleaning);
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return a.roomNumber.compareTo(b.roomNumber);
    });

    return filtered;
  }

  Map<String, List<Room>> get roomsByStatus {
    final Map<String, List<Room>> grouped = {};
    
    for (final room in filteredRooms) {
      final key = RoomStatusHelper.canStartCleaning(room.status, room.statusCleaning)
          ? 'Disponibles para limpiar'
          : room.status.toUpperCase() == 'OCUPADO'
              ? 'Ocupadas - No molestar'
              : room.status.toUpperCase() == 'MANTENIMIENTO'
                  ? 'En mantenimiento'
                  : 'Otras';
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(room);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildModernHeader(),
            if (!loading && cleaningsInProcess.isNotEmpty)
              _buildCleaningsInProcess(),
            _buildModernFilters(),
            Expanded(
              child: loading 
                ? _buildLoadingState()
                : _buildRoomSections(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
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
                        'Control de Habitaciones',
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
                            Icons.hotel,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${allRooms.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          loadData();
                          _showSuccessSnackBar('Habitaciones actualizadas');
                        },
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

  Widget _buildModernFilters() {
    final filters = [
      {'key': 'TODOS', 'label': 'Todas', 'icon': Icons.home_outlined},
      {'key': 'DISPONIBLES', 'label': 'Disponibles', 'icon': Icons.cleaning_services},
      {'key': 'PARA_LIMPIAR', 'label': 'Por limpiar', 'icon': Icons.warning_amber},
      {'key': 'OCUPADAS', 'label': 'Ocupadas', 'icon': Icons.person},
      {'key': 'LIMPIAS', 'label': 'Limpias', 'icon': Icons.check_circle},
      {'key': 'MANTENIMIENTO', 'label': 'Mantenimiento', 'icon': Icons.build},
    ];

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter['key'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF1E3A8A) 
                        : const Color(0xFF1E3A8A).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1E3A8A).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF1E3A8A),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Cargando habitaciones...',
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

  Widget _buildCleaningsInProcess() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9F7AEA).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9F7AEA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Color(0xFF9F7AEA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Limpiezas en proceso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9F7AEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cleaningsInProcess.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...cleaningsInProcess.map((cleaning) => _buildCleaningInProcessCard(cleaning)),
          ],
        ),
      ),
    );
  }

  Widget _buildCleaningInProcessCard(Cleaning cleaning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.cleaningProgress,
              arguments: {
                'cleaningId': cleaning.id,
                'roomId': cleaning.roomId,
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9F7AEA).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9F7AEA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bed, color: Color(0xFF9F7AEA), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Habitación ${cleaning.roomNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Color(0xFF9F7AEA),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Iniciada: ${DateFormat('HH:mm').format(cleaning.startDate.toLocal())}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9F7AEA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomSections() {
    final roomGroups = roomsByStatus;
    
    if (roomGroups.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay habitaciones que mostrar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar el filtro seleccionado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roomGroups.length,
      itemBuilder: (context, index) {
        final sectionName = roomGroups.keys.elementAt(index);
        final rooms = roomGroups[sectionName]!;
        
        return _buildRoomSection(sectionName, rooms);
      },
    );
  }

  Widget _buildRoomSection(String title, List<Room> rooms) {
    Color sectionColor = const Color(0xFF1E3A8A);
    IconData sectionIcon = Icons.home;
    
    if (title.contains('Disponibles')) {
      sectionColor = const Color(0xFF48BB78);
      sectionIcon = Icons.cleaning_services;
    } else if (title.contains('Ocupadas')) {
      sectionColor = const Color(0xFFE53E3E);
      sectionIcon = Icons.do_not_disturb;
    } else if (title.contains('mantenimiento')) {
      sectionColor = const Color(0xFFED8936);
      sectionIcon = Icons.build;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  sectionColor,
                  sectionColor.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(sectionIcon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${rooms.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final canStartCleaning = RoomStatusHelper.canStartCleaning(room.status, room.statusCleaning);
                final hasCleaningInProcess = cleaningsInProcess.isNotEmpty;
                
                return ImprovedRoomCard(
                  room: room,
                  showDetails: true,
                  filterContext: selectedFilter,
                  onTap: canStartCleaning
                    ? () {
                        if (hasCleaningInProcess) {
                          _showCleaningInProcessDialog();
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.cleaningStart,
                            arguments: room.id,
                          );
                        }
                      }
                    : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCleaningInProcessDialog() {
    final currentCleaning = cleaningsInProcess.first;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  color: Color(0xFFE53E3E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Limpieza en curso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ya tienes una limpieza en proceso en la habitación ${currentCleaning.roomNumber}.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F6F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9F7AEA).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bed,
                          color: Color(0xFF9F7AEA),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Habitación ${currentCleaning.roomNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFF9F7AEA),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Iniciada: ${DateFormat('HH:mm').format(currentCleaning.startDate.toLocal())}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF1E3A8A),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Debes completar esta limpieza antes de iniciar una nueva.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Entendido',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  AppRoutes.cleaningProgress,
                  arguments: {
                    'cleaningId': currentCleaning.id,
                    'roomId': currentCleaning.roomId,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9F7AEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ir a limpieza',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}