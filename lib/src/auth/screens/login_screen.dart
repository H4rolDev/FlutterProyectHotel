import 'package:flutter/material.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/auth/services/auth_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  final AuthService _authService = AuthService();

  void _login(BuildContext context) async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    if (!EmailValidator.validate(email)) {
      setState(() {
        _errorMessage = 'Por favor ingrese un correo electrónico válido';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6 || password.length > 50) {
      setState(() {
        _errorMessage = 'La contraseña debe tener entre 6 y 50 caracteres';
        _isLoading = false;
      });
      return;
    }

    var result = await _authService.login(email, password);

    print("DEBUG login result: $result");

    if (result['status'] == 200) {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getInt('employeeId');

      if (employeeId != null && employeeId > 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else if (result['status'] == 401) {
      setState(() {
        _errorMessage = 'Correo o contraseña incorrectos';
        _isLoading = false;
      });
    } else if (result['status'] == 500) {
      setState(() {
        _errorMessage = 'Error en el servidor: ${result['body']}';
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            'Error desconocido [${result['status']}]: ${result['body']}';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? employeeId = prefs.getInt('employeeId');

    if (token != null) {
      if (employeeId != null && employeeId > 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: AppColors.secondary500),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 17.0, bottom: 8.0),
                        child: Text(
                          'Usuario',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primary100,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Ingrese su correo electrónico',
                          prefixIcon: Icon(
                            Icons.person,
                            color: AppColors.primary100,
                          ),
                          contentPadding: EdgeInsets.all(20),
                          filled: true,
                          fillColor: AppColors.secondary100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.secondary500,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.secondary500,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 17.0, bottom: 8.0),
                        child: Text(
                          'Contraseña',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primary100,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Ingrese su contraseña',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: AppColors.primary300,
                          ),
                          contentPadding: EdgeInsets.all(20),
                          filled: true,
                          fillColor: AppColors.secondary100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.secondary500,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.secondary500,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.primary300,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _login(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        backgroundColor: _isLoading
                            ? AppColors.primary300
                            : AppColors.primary500,
                        disabledBackgroundColor: AppColors.primary300,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? AppColors.primary300
                              : AppColors.primary500,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Center(
                            child: Text(
                              _isLoading ? 'Iniciando' : 'Ingresar',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white.withOpacity(
                                  _isLoading ? 0.7 : 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 20),
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                    ],
                    SizedBox(height: 25),
                    Text(
                      '@ Hospedaje Formula 1',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: AppColors.primary700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
