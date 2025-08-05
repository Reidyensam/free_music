import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

Future<Usuario?> obtenerPerfilDesdeSupabase() async {
  final supabase = Supabase.instance.client;
  final uid = supabase.auth.currentUser?.id;

  if (uid == null) return null;

  final res = await supabase
      .from('usuarios')
      .select()
      .eq('id', uid)
      .maybeSingle();

  if (res == null) return null;

  return Usuario.desdeJson(res);
}