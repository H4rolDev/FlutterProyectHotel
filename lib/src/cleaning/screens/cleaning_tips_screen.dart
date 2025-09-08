import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';
import 'package:hospedaje_f1/src/layout/layout.dart';

class CleaningTipsScreen extends StatefulWidget {
  const CleaningTipsScreen({super.key});

  @override
  _CleaningTipsScreenState createState() => _CleaningTipsScreenState();
}

class _CleaningTipsScreenState extends State<CleaningTipsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5DC), // Color beige de fondo
        body: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralTipsTab(),
                  _buildChecklistTab(),
                  _buildProductsTab(),
                  _buildSafetyTab(),
                  _buildTroubleshootingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8B4513).withOpacity(0.8), // Marrón
            const Color(0xFFD2B48C), // Tan/beige más oscuro
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guía de Limpieza',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tips y consejos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cleaning_services,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFDDD0B8), // Beige más oscuro para la barra de tabs
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF8B4513),
        indicatorWeight: 3,
        labelColor: const Color(0xFF8B4513),
        unselectedLabelColor: const Color(0xFF8B4513).withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.tips_and_updates, size: 20),
            text: 'Tips',
          ),
          Tab(
            icon: Icon(Icons.checklist, size: 20),
            text: 'Lista',
          ),
          Tab(
            icon: Icon(Icons.inventory, size: 20),
            text: 'Productos',
          ),
          Tab(
            icon: Icon(Icons.security, size: 20),
            text: 'Seguridad',
          ),
          Tab(
            icon: Icon(Icons.help, size: 20),
            text: 'Problemas',
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTipsTab() {
    final tips = [
      {
        'title': '🏃‍♀️ Orden de limpieza',
        'description': 'Siempre limpia de arriba hacia abajo',
        'details': 'Comienza por techos, luces y ventiladores, luego superficies altas, muebles y finalmente el piso.',
        'icon': Icons.arrow_downward,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': '🧽 Técnica correcta',
        'description': 'Movimientos en forma de "S" para mayor eficiencia',
        'details': 'Evita movimientos circulares que pueden esparcir la suciedad. Usa movimientos lineales o en "S".',
        'icon': Icons.gesture,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': '⏰ Tiempo de contacto',
        'description': 'Deja actuar los productos de limpieza',
        'details': 'Los desinfectantes necesitan tiempo para ser efectivos. Léelos instrucciones del producto.',
        'icon': Icons.timer,
        'color': const Color(0xFF9C27B0),
      },
      {
        'title': '🌟 Menos es más',
        'description': 'No uses exceso de producto',
        'details': 'Mucho producto puede dejar residuos y ser contraproducente. Sigue las diluciones recomendadas.',
        'icon': Icons.water_drop,
        'color': const Color(0xFF00BCD4),
      },
      {
        'title': '🧹 Herramientas limpias',
        'description': 'Lava tus herramientas regularmente',
        'details': 'Trapos sucios esparcen gérmenes. Cambia el agua frecuentemente y usa trapos diferentes por área.',
        'icon': Icons.cleaning_services,
        'color': const Color(0xFFFF9800),
      },
      {
        'title': '🚿 Baños primero húmedo, luego seco',
        'description': 'Aplica productos, deja actuar, luego limpia',
        'details': 'Rocía toda la superficie, espera 5-10 minutos para que actúe, luego limpia sistemáticamente.',
        'icon': Icons.bathtub,
        'color': const Color(0xFF607D8B),
      },
    ];

    return Container(
      color: const Color(0xFFF5F5DC), // Fondo beige
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (tip['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tip['icon'] as IconData,
                  color: tip['color'] as Color,
                  size: 24,
                ),
              ),
              title: Text(
                tip['title'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              subtitle: Text(
                tip['description'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8B4513).withOpacity(0.7),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tip['details'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5D4037),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

  Widget _buildChecklistTab() {
    return Container(
      color: const Color(0xFFF5F5DC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChecklistSection(
              'Baño Completo',
              Icons.bathtub,
              const Color(0xFF2196F3),
              [
                'Recoger toallas y artículos personales',
                'Aplicar desinfectante en inodoro y ducha',
                'Limpiar espejos y superficies',
                'Restregar inodoro por dentro y fuera',
                'Limpiar ducha/bañera con productos específicos',
                'Trapear piso con desinfectante',
                'Reponer papel higiénico y toallas limpias',
                'Verificar que todo funcione correctamente',
              ],
            ),
            const SizedBox(height: 20),
            _buildChecklistSection(
              'Habitación Principal',
              Icons.bed,
              const Color(0xFF4CAF50),
              [
                'Recoger objetos personales del huésped',
                'Deshacer cama y separar ropa sucia',
                'Aspirar colchón y voltear si es necesario',
                'Cambiar sábanas y fundas completamente',
                'Hacer cama con técnica hotelera',
                'Limpiar mesitas de noche y lámparas',
                'Aspirar/trapear piso según tipo',
                'Revisar closet y reponer amenidades',
              ],
            ),
            const SizedBox(height: 20),
            _buildChecklistSection(
              'Áreas Comunes',
              Icons.weekend,
              const Color(0xFF9C27B0),
              [
                'Aspirar sofás y cojines',
                'Limpiar mesas y superficies',
                'Lavar ventanas si es necesario',
                'Ordenar revistas y decoración',
                'Aspirar alfombras completamente',
                'Trapear pisos duros',
                'Revisar iluminación y controles',
                'Reponer agua y snacks si aplica',
              ],
            ),
            const SizedBox(height: 20),
            _buildChecklistSection(
              'Inspección Final',
              Icons.fact_check,
              const Color(0xFFFF9800),
              [
                'Revisar que todo esté funcionando',
                'Verificar temperatura ambiente',
                'Comprobar limpieza de superficies',
                'Revisar suministros completos',
                'Verificar orden general',
                'Tomar fotos si es requerido',
                'Marcar habitación como lista',
                'Reportar cualquier daño encontrado',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection(String title, IconData icon, Color color, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B4513).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.check, color: color, size: 16),
                ),
                title: Text(
                  items[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final products = [
      {
        'category': 'Desinfectantes',
        'items': [
          {'name': 'Alcohol 70%', 'use': 'Superficies y objetos pequeños', 'tip': 'Deja secar al aire'},
          {'name': 'Cloro diluido', 'use': 'Baños y pisos', 'tip': '1:10 con agua para uso general'},
          {'name': 'Amonio cuaternario', 'use': 'Muebles y tapicería', 'tip': 'No requiere enjuague'},
        ],
        'color': const Color(0xFFE91E63),
        'icon': Icons.sanitizer,
      },
      {
        'category': 'Limpiadores',
        'items': [
          {'name': 'Detergente neutro', 'use': 'Pisos y superficies generales', 'tip': 'Biodegradable preferible'},
          {'name': 'Limpiador de vidrios', 'use': 'Ventanas y espejos', 'tip': 'Usar papel periódico para brillar'},
          {'name': 'Quitamanchas', 'use': 'Textiles y alfombras', 'tip': 'Probar en área pequeña primero'},
        ],
        'color': const Color(0xFF3F51B5),
        'icon': Icons.local_laundry_service,
      },
      {
        'category': 'Especializados',
        'items': [
          {'name': 'Limpiador de baños', 'use': 'Azulejos y sanitarios', 'tip': 'No mezclar con otros productos'},
          {'name': 'Cera para pisos', 'use': 'Pisos de madera/laminados', 'tip': 'Aplicar en capas delgadas'},
          {'name': 'Ambientador', 'use': 'Neutralizar olores', 'tip': 'Usar con moderación'},
        ],
        'color': const Color(0xFF4CAF50),
        'icon': Icons.auto_fix_high,
      },
    ];

    return Container(
      color: const Color(0xFFF5F5DC),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final category = products[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category['category'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: category['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
                ...(category['items'] as List<Map<String, String>>).map((item) {
                  return ListTile(
                    title: Text(
                      item['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uso: ${item['use']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '💡 ${item['tip']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: (category['color'] as Color),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSafetyTab() {
    return Container(
      color: const Color(0xFFF5F5DC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSafetyCard(
              'Equipo de Protección Personal',
              Icons.health_and_safety,
              const Color(0xFFE53935),
              [
                '🧤 Usar guantes resistentes a químicos',
                '😷 Mascarilla en áreas mal ventiladas',
                '👕 Ropa que cubra brazos y piernas',
                '👟 Zapatos antideslizantes cerrados',
                '👓 Gafas de protección si es necesario',
              ],
            ),
            const SizedBox(height: 16),
            _buildSafetyCard(
              'Manejo de Químicos',
              Icons.warning,
              const Color(0xFFFF9800),
              [
                '📖 Leer etiquetas antes de usar',
                '🚫 NUNCA mezclar productos diferentes',
                '🌬️ Ventilar áreas durante el uso',
                '🧴 Usar productos en envases originales',
                '🚿 Tener agua cerca para emergencias',
              ],
            ),
            const SizedBox(height: 16),
            _buildSafetyCard(
              'Prevención de Accidentes',
              Icons.security,
              const Color(0xFF43A047),
              [
                '🚧 Colocar señales de "piso mojado"',
                '🔌 Verificar cables y enchufes',
                '📱 Mantener teléfono de emergencia',
                '👥 No trabajar solo en áreas aisladas',
                '🚪 Mantener salidas despejadas',
              ],
            ),
            const SizedBox(height: 16),
            _buildSafetyCard(
              'Ergonomía y Postura',
              Icons.accessibility,
              const Color(0xFF8E24AA),
              [
                '🏋️ Doblar rodillas al levantar peso',
                '🔄 Alternar tareas para evitar repetición',
                '⏰ Tomar descansos cada 2 horas',
                '🪑 Usar escaleras apropiadas',
                '💪 Mantener espalda recta siempre',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard(String title, IconData icon, Color color, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5D4037),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingTab() {
    final problems = [
      {
        'problem': '🦠 Manchas difíciles en baño',
        'solutions': [
          'Aplicar bicarbonato + vinagre, dejar 15 min',
          'Usar cepillo de dientes viejo para rincones',
          'Para cal: limón + sal, frotar suavemente',
          'Enjuagar abundantemente después',
        ],
        'color': const Color(0xFF2196F3),
      },
      {
        'problem': '🛏️ Olores en textiles',
        'solutions': [
          'Rociar con solución de vinagre diluido',
          'Dejar ventilar al aire libre si es posible',
          'Usar bicarbonato, dejar toda la noche',
          'Aspirar residuos por la mañana',
        ],
        'color': const Color(0xFF4CAF50),
      },
      {
        'problem': '🪟 Rayas en ventanas',
        'solutions': [
          'Limpiar en días nublados o temprano',
          'Usar papel periódico en lugar de trapo',
          'Aplicar producto en movimientos verticales',
          'Secar inmediatamente con trapo seco',
        ],
        'color': const Color(0xFFFF9800),
      },
      {
        'problem': '🚿 Moho en juntas',
        'solutions': [
          'Aplicar cloro puro con brocha pequeña',
          'Dejar actuar 30 minutos',
          'Cepillar suavemente con cepillo viejo',
          'Enjuagar y ventilar bien el área',
        ],
        'color': const Color(0xFF9C27B0),
      },
      {
        'problem': '🏠 Pisos que se ven opacos',
        'solutions': [
          'Verificar exceso de producto anterior',
          'Limpiar con agua tibia solamente',
          'Secar completamente antes de encerar',
          'Aplicar cera en capas muy delgadas',
        ],
        'color': const Color(0xFF795548),
      },
    ];

    return Container(
      color: const Color(0xFFF5F5DC),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: problems.length,
        itemBuilder: (context, index) {
          final problem = problems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (problem['color'] as Color).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (problem['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline,
                  color: problem['color'] as Color,
                  size: 24,
                ),
              ),
              title: Text(
                problem['problem'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: problem['color'] as Color,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soluciones:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: problem['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(problem['solutions'] as List<String>).asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: problem['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5D4037),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }