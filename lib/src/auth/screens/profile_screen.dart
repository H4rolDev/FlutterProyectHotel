import 'package:flutter/material.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospedaje_f1/src/auth/services/employee_service.dart';
import 'package:hospedaje_f1/src/auth/models/employee.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorUI(context, 'Error al cargar datos');
          }

          final userData = snapshot.data!;

          return FutureBuilder<Employee?>(
            future: EmployeeService.getEmployeeDetails(userData['employeeId']),
            builder: (context, employeeSnapshot) {
              if (employeeSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

            
              final employeeData = employeeSnapshot.data;
              String errorEmployeeMessage = '';
              if (employeeSnapshot.hasError) {
                errorEmployeeMessage = 'Hubo un problema al obtener la información. Por favor, intente más tarde.';
              } else if (employeeData == null) {
                errorEmployeeMessage = 'Empleado no encontrado';
              }

              String role = userData['roles'].contains('ROLE_CLEANER')
                  ? 'Limpieza'
                  : userData['roles'].join(', ');

              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary300,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.home);
                                },
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Mi Cuenta',
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
                      if (errorEmployeeMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            errorEmployeeMessage,
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondary300,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.primary300,
                                  child: Icon(Icons.account_circle, size: 60, color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 30),
                              _buildTextField('Correo electrónico', userData['email']),
                              SizedBox(height: 20),
                              _buildTextField('Rol', role),
                              SizedBox(height: 20),
                              _buildTextField(
                                'Tipo de documento',
                                employeeData?.documentType ?? 'No disponible',
                              ),
                              SizedBox(height: 20),
                              _buildTextField(
                                'Número de documento',
                                employeeData?.documentNumber ?? 'No disponible',
                              ),
                              SizedBox(height: 20),
                              _buildTextField('Nombre', employeeData?.name ?? 'No disponible'),
                              SizedBox(height: 20),
                              _buildTextField('Apellido', employeeData?.lastName ?? 'No disponible'),
                              SizedBox(height: 20),
                              _buildTextField('Teléfono', employeeData?.phone ?? 'No disponible'),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  await _authService.logout();
                                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tertiary500,
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    color: AppColors.secondary100,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final roles = prefs.getStringList('roles') ?? [];
    final id = prefs.getInt('id') ?? 0;
    final employeeId = prefs.getInt('employeeId') ?? 0;

    return {
      'email': email,
      'roles': roles,
      'id': id,
      'employeeId': employeeId,
    };
  }

  Widget _buildTextField(String label, String value) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      readOnly: true,
    );
  }

  Widget _buildErrorUI(BuildContext context, String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: TextStyle(color: Colors.red, fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService.logout();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary500,
                minimumSize: Size(150, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
