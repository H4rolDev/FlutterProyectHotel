import 'package:flutter/material.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? 'usuario@hotel.com';
  }

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> menuItems = [
      _MenuItem(
        label: 'Realizar Limpieza',
        icon: Icons.cleaning_services,
        route: AppRoutes.roomList,
      ),
      _MenuItem(
        label: 'Mis Limpiezas',
        icon: Icons.list_alt,
        route: AppRoutes.cleaningHistory,
      ),
      _MenuItem(
        label: 'Consejos de Limpieza',
        icon: Icons.tips_and_updates,
        route: AppRoutes.cleaningTips,
      ),
    ];

    const double horizontalMargin = 16; // margen a los lados

    return Layout(
      child: Scaffold(
        backgroundColor: AppColors.secondary100,
        body: SafeArea(
          child: FutureBuilder<String>(
            future: _getUserEmail(),
            builder: (context, snapshot) {
              String email = snapshot.data ?? 'usuario@hotel.com';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen con filtro oscuro y elementos encima
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 270,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.jpg'),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter, // parte superior de la imagen
                          ),
                        ),
                      ),
                      // Overlay oscuro para oscurecer la imagen y mejorar lectura
                      Container(
                        height: 270,
                        color: Colors.black.withOpacity(0.4),
                      ),

                      // Icono y email encima, con algo de padding
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.primary700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Texto "Bienvenido" sobresaliendo por debajo
                     // Texto "HOTEL FORMULA 1" sobresaliendo por debajo
                      Positioned(
                        bottom: -30,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white, // fondo blanco
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Text(
                              'HOTEL FORMULA 1',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary700, // color del texto
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ),

                  const SizedBox(height: 48),

                  // Menús debajo, con margen lateral igual que "Bienvenido"
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: menuItems.map((item) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6), // pequeño espacio entre menús
                            child: _MenuCard(item: item),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final String route;

  _MenuItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 50,
              color: AppColors.primary500,
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
