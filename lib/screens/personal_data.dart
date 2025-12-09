import 'dart:io';
import 'package:desctop_app_origen/core/app_colors.dart';
import 'package:desctop_app_origen/core/buttons_style.dart';
import 'package:desctop_app_origen/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalDataScreen extends StatefulWidget {
  final String userId;
  final String? nombre;

  const PersonalDataScreen({super.key, required this.userId, this.nombre});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final supabase = Supabase.instance.client;
  Key _streamKey = UniqueKey();
  bool _isRefreshing = false;

  String? totalHorasMes; // 👈 guardamos el texto formateado

  @override
  void initState() {
    super.initState();
    _fetchTotalHorasMes();
  }

  Future<void> _fetchTotalHorasMes() async {
    final response = await supabase.rpc('total_horas_mes', params: {
      'uid': widget.userId,
    });

    if (mounted) {
      if (response != null) {
        final parts = response.toString().split(':');
        if (parts.length >= 2) {
          final horas = int.tryParse(parts[0]) ?? 0;
          final minutos = int.tryParse(parts[1]) ?? 0;
          setState(() {
            totalHorasMes = "${horas}h ${minutos}m";
          });
        } else {
          setState(() {
            totalHorasMes = response.toString();
          });
        }
      } else {
        setState(() {
          totalHorasMes = "0h 0m";
        });
      }
    }
  }

  /// 👉 Función para exportar a CSV
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
    final filePath =
        '${downloadsDir.path}/fichajes_${widget.nombre ?? "usuario"}_$formattedDate.csv';

    final buffer = StringBuffer();
    buffer.writeln('Nombre,Apellidos,Día,Entrada,Salida,Horas Trabajadas');

    for (var f in fichajes) {
      buffer.writeln(
        [
          f['nombre'] ?? '',
          f['apellidos'] ?? '',
          f['dia'] ?? '',
          f['hora_entrada'] ?? '',
          f['hora_salida'] ?? '',
          f['horas_trabajadas'] ?? '',
        ].map((e) => '"$e"').join(','),
      );
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ CSV guardado en: $filePath')),
    );

    if (Platform.isWindows) {
      await Process.run('explorer', [filePath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [filePath]);
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
          title: Text(
            widget.nombre ?? "Datos del Usuario",
            style: TextStyles.titleText,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
                          _streamKey = UniqueKey();
                        });
                        _fetchTotalHorasMes();
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
        body: Center(
          child: Container(
            color: const Color.fromARGB(255, 110, 179, 240),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              key: _streamKey,
              stream: supabase
                  .from('fichajes')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', widget.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final fichajes = snapshot.data!;

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(28.0.w),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Apellidos')),
                              DataColumn(label: Text('Día')),
                              DataColumn(label: Text('Entrada')),
                              DataColumn(label: Text('Salida')),
                              DataColumn(label: Text('Horas Trabajadas')),
                            ],
                            rows: fichajes.map((f) {
                              return DataRow(cells: [
                                DataCell(Text(f['nombre'] ?? '')),
                                DataCell(Text(f['apellidos'] ?? '')),
                                DataCell(Text(f['dia'] ?? '')),
                                DataCell(Text(f['hora_entrada'] ?? '')),
                                DataCell(Text(f['hora_salida'] ?? '')),
                                DataCell(Text(f['horas_trabajadas'] ?? '')),
                              ]);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          totalHorasMes == null
                              ? "Calculando horas totales..."
                              : "Horas totales trabajadas este mes: $totalHorasMes",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => exportToCSV(fichajes),
                          style: BTNStyles.botonCSV,
                          child: const Text("Exportar a CSV"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
