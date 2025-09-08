import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/auth/services/employee_service.dart';

class RegisterEmployeeScreen extends StatefulWidget {
  const RegisterEmployeeScreen({super.key});

  @override
  _RegisterEmployeeScreenState createState() => _RegisterEmployeeScreenState();
}

class _RegisterEmployeeScreenState extends State<RegisterEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _documentType;
  final _documentNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  final _documentTypes = ['DNI', 'PASAPORTE', 'OTRO'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await EmployeeService.createEmployee(
      documentType: _documentType!,
      documentNumber: _documentNumberController.text,
      name: _nameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
    );

    if (result['status'] == 200 || result['status'] == 201) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = result['message'] ?? 'Error al registrar';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Completar Registro')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _documentType,
                decoration: InputDecoration(labelText: 'Tipo de documento'),
                items: _documentTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _documentType = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _documentNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Número de documento'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (!RegExp(r'^\d+$').hasMatch(value)) return 'Solo números';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Apellido'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (!RegExp(r'^\d+$').hasMatch(value)) return 'Solo números';
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Registrar'),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
