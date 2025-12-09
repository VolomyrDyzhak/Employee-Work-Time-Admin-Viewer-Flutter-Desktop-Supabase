import 'dart:io';
import 'package:desctop_app_origen/core/buttons_style.dart';
import 'package:desctop_app_origen/screens/personal_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:desctop_app_origen/core/app_colors.dart';
import 'package:desctop_app_origen/core/text_styles.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final supabase = Supabase.instance.client;
  Key _streamKey = UniqueKey(); // Clave para refrescar el StreamBuilder
  bool _isRefreshing = false;

  Future<void> exportToCSV(List<Map<String, dynamic>> fichajes) async {
    final downloadsDir = await getDownloadsDirectory();
    if (!mounted || downloadsDir == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se pudo acceder a la carpeta de descargas'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final filePath = '${downloadsDir.path}/fichajes_$formattedDate.csv';

    final buffer = StringBuffer();
    // 💡 AÑADIDO: 'IP' al encabezado del CSV
    buffer.writeln('ID,Nombre,Apellidos,Día,Entrada,Salida,Horas Trabajadas,IP');

    for (var f in fichajes) {
      buffer.writeln(
        [
          f['id'],
          f['nombre'] ?? '',
          f['apellidos'] ?? '',
          f['dia'] ?? '',
          f['hora_entrada'] ?? '',
          f['hora_salida'] ?? '',
          f['horas_trabajadas'] ?? '',
          // 💡 AÑADIDO: Valor de la IP
          f['ip_address'] ?? '', 
        ].map((e) => '"$e"').join(','),
      );
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ CSV guardado en: $filePath')));

    if (Platform.isWindows) {
      await Process.run('explorer', [filePath]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.complementary],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 160.h,
          automaticallyImplyLeading: true,
          title: Image.asset(
            "assets/images/FormacionOrigen.jpeg",
            height: 120.h,
          ),
          backgroundColor: AppColors.primary,
          actions: [
            Padding(
              padding: EdgeInsets.all(28.0.w),
              child: IconButton(
                icon: _isRefreshing
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.refresh, size: 30.w, color: Colors.white),
                onPressed: _isRefreshing
                    ? null
                    : () {
                        setState(() {
                          _isRefreshing = true;
                          _streamKey =
                              UniqueKey(); // 🔁 Refresca el StreamBuilder
                        });

                        // Simula un pequeño delay para mostrar la animación
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            setState(() {
                              _isRefreshing = false;
                            });
                          }
                        });
                      },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(28.0.w),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary,
                    AppColors.yellow,
                    AppColors.complementary,
                  ],
                ),
              ),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(top: 50.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Registros de Entradas y Salidas",
                        style: TextStyles.mainText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        key: _streamKey,
                        stream: supabase
                            .from('fichajes')
                            .stream(primaryKey: ['id']),
                        builder: (context, snapshot) {
                          // 1. 💡 CORRECCIÓN: Manejo de errores del Stream
                          if (snapshot.hasError) {
                            debugPrint('Error en el Stream de fichajes: ${snapshot.error}');
                            return Center(
                              child: Text(
                                '❌ Error al cargar. Revise la consola y el esquema de la BD.',
                                style: TextStyles.errorText.copyWith(color: Colors.red),
                              ),
                            );
                          }
                          
                          // Manejo de carga
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final fichajes = snapshot.data!
                            ..sort((a, b) => a['id'].compareTo(b['id']));

                          return Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: [
                                    DataColumn(
                                      label: Text(
                                        'ID',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Nombre',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Apellidos',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Día',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Entrada',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Salida',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Horas Trabajadas',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                    // 2. 💡 AÑADIDO: Columna IP
                                    DataColumn(
                                      label: Text(
                                        'IP',
                                        style: TextStyles.mainText,
                                      ),
                                    ),
                                  ],
                                  rows: fichajes.map((f) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            f['id'].toString(),
                                            style: TextStyles.formText,
                                          ),
                                        ),
                                        DataCell(
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PersonalDataScreen(
                                                        userId:
                                                            f['user_id'], // 👈 pasa el id real del usuario
                                                        nombre: f['nombre'],
                                                      ), // <-- El widget/página a la que quieres ir
                                                ),
                                              );
                                            },
                                            child: Text(
                                              f['nombre'] ?? '',
                                              style: TextStyles.nameText,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            f['apellidos'] ?? '',
                                            style: TextStyles.formText,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            f['dia'] ?? '',
                                            style: TextStyles.formText,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            f['hora_entrada'] ?? '',
                                            style: TextStyles.formText,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            f['hora_salida'] ?? '',
                                            style: TextStyles.formText,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            f['horas_trabajadas'] ?? '',
                                            style: TextStyles.formText,
                                          ),
                                        ),
                                        // 3. 💡 AÑADIDO: Celda IP
                                        DataCell(
                                          Text(
                                            f['ip_address'] ?? 'N/A',
                                            style: TextStyles.formText,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => exportToCSV(fichajes),
                                style: BTNStyles.botonFinal,
                                child: Text(
                                  "Exportar a CSV",
                                  style: TextStyles.btnText,
                                ),
                              ),
                            ],
                          );
                        },
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

  // Las funciones _buildTextField y _buildPasswordField no están aquí, 
  // ya que esta es la clase RootPage, pero se entiende que existen en RegisterPage.
}