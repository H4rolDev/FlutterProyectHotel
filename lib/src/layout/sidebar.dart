import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';

class Sidebar extends StatefulWidget {
  final Function toggleMenu;

  const Sidebar({super.key, required this.toggleMenu});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String _selectedRoute = AppRoutes.home;

  void _updateSelectedRoute(String route) {
    setState(() {
      _selectedRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary500,
      width: 250,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildMenuItem(AppRoutes.home, 'Inicio'),
                  const SizedBox(height: 16),
                  _buildMenuItem(AppRoutes.roomList, 'Limpieza'),
                  const SizedBox(height: 16),
                  _buildMenuItem(AppRoutes.cleaningHistory, 'Mis Limpiezas'),
                  const SizedBox(height: 16),
                  _buildMenuItem(AppRoutes.profile, 'Mi Cuenta'),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.secondary100),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String route, String title) {
    bool isSelected = _selectedRoute == route;

    return MouseRegion(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Material(
          color: isSelected ? AppColors.secondary700 : AppColors.secondary100,
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(context, route);
              widget.toggleMenu();
              _updateSelectedRoute(route);
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary700
                      : AppColors.primary500,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Modificación del método _buildLogoutButton
  Widget _buildLogoutButton() {
    return MouseRegion(
      child: Container(
        margin: const EdgeInsets.only(top: 24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Material(
          color: AppColors.tertiary500,
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            onTap: () async {
              // Llamar al método logout del AuthService
              await AuthService().logout();
              // Navegar a la pantalla de login
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            borderRadius: BorderRadius.circular(8.0),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: AppColors.secondary100,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
