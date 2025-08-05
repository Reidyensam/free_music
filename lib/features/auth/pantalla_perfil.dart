import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/tema_provider.dart';
import '../../core/tema.dart';
import '../../services/servicio_supabase.dart';

class PantallaPerfil extends ConsumerStatefulWidget {
  const PantallaPerfil({super.key});

  @override
  ConsumerState<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends ConsumerState<PantallaPerfil> {
  late Color colorSeleccionado;
  bool esModoOscuroForzado = false;

  @override
  void initState() {
    super.initState();
    final usuario = ref.read(usuarioProvider);
    final color = colorDesdeHex(usuario?.temaVisual) ?? Colors.teal;
    colorSeleccionado = color;

    // ✅ Cargamos la preferencia persistida desde Supabase
    esModoOscuroForzado = usuario?.modoOscuro ?? false;

    // 🧠 Aplicamos el tema inicial respetando ese estado
    Future.microtask(() {
      ref.read(temaProvider.notifier).state = generarTemaDesdeColor(
        colorSeleccionado,
        forzarModoOscuro: esModoOscuroForzado,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioProvider);
    final theme = Theme.of(context);

    final coloresDisponibles = [
      ...Colors.primaries.expand((base) => [
            base.shade300,
            base.shade500,
            base.shade700,
          ]),
    ];

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('No hay sesión activa')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Personaliza tu estilo'),
        actions: [
          IconButton(
            icon: Icon(
              esModoOscuroForzado
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
              color: Colors.white,
            ),
            tooltip: esModoOscuroForzado ? 'Modo claro' : 'Modo oscuro',
            onPressed: () {
              setState(() {
                esModoOscuroForzado = !esModoOscuroForzado;

              });

              ref.read(temaProvider.notifier).state = generarTemaDesdeColor(
                colorSeleccionado,
                forzarModoOscuro: esModoOscuroForzado,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              Text(
                'Hola, ${usuario.nombreUsuario}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text('Colores Rápidos:'),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: coloresDisponibles.map((color) {
                  final esSeleccionado =
                      color.value == colorSeleccionado.value;

                  return GestureDetector(
                    onTap: () {
                      setState(() => colorSeleccionado = color);
                      ref.read(temaProvider.notifier).state =
                          generarTemaDesdeColor(
                        color,
                        forzarModoOscuro: esModoOscuroForzado,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: esSeleccionado
                              ? Colors.black87
                              : Colors.grey.shade300,
                          width: esSeleccionado ? 3 : 1,
                        ),
                        boxShadow: [
                          if (esSeleccionado)
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                        ],
                      ),
                      child: esSeleccionado
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                icon: const Icon(Icons.palette_outlined),
                label: const Text('Elegir Color Personalizado'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Color Personalizado'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: colorSeleccionado,
                          onColorChanged: (color) {
                            setState(() => colorSeleccionado = color);
                            ref.read(temaProvider.notifier).state =
                                generarTemaDesdeColor(
                              color,
                              forzarModoOscuro: esModoOscuroForzado,
                            );
                          },
                          enableAlpha: false,
                          displayThumbColor: true,
                          showLabel: true,
                          portraitOnly: true,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Aplicar y Volver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorSeleccionado,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final nuevoTema = generarTemaDesdeColor(
                    colorSeleccionado,
                    forzarModoOscuro: esModoOscuroForzado,
                  );
                  ref.read(temaProvider.notifier).state = nuevoTema;

                  final hex = colorAHex(colorSeleccionado);
                  final nuevoUsuario = usuario.copyWith(
                    temaVisual: hex,
                    modoOscuro: esModoOscuroForzado,
                  );
                  ref.read(usuarioProvider.notifier).state = nuevoUsuario;

                  try {
                    await ServicioSupabase.cliente
                        .from('usuarios')
                        .update({
                          'tema_visual': hex,
                          'modo_oscuro': esModoOscuroForzado,
                        })
                        .eq('id', usuario.id);
                  } catch (e) {
                    debugPrint('❌ Error actualizando tema: $e');
                  }

                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}