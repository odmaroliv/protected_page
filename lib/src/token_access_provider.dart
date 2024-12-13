import 'package:protected_page/protected_page.dart';

/// Obtiene roles y permisos desde un token
class TokenAccessProvider implements AccessProvider {
  final Future<String> Function() tokenProvider;

  final Future<Map<String, dynamic>> Function(String token) decodeToken;

  TokenAccessProvider({
    required this.tokenProvider,
    required this.decodeToken,
  });

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await tokenProvider();
      return token.isNotEmpty; // Si hay token, está autenticado
    } catch (_) {
      return false; // Fallo en obtener o decodificar el token
    }
  }

  @override
  Future<List<String>> getRoles() async {
    try {
      final token = await tokenProvider();
      final decoded = await decodeToken(token);
      return List<String>.from(decoded[AccessConfig.rolesKey] ?? []);
    } catch (_) {
      return []; // Fallo en obtener roles, retorna vacío
    }
  }

  @override
  Future<List<String>> getPermissions() async {
    if (!AccessConfig.usePermissions) {
      return []; // Ignora permisos si están deshabilitados
    }
    try {
      final token = await tokenProvider();
      final decoded = await decodeToken(token);
      return List<String>.from(decoded[AccessConfig.permissionsKey] ?? []);
    } catch (_) {
      return []; // Fallo en obtener permisos, retorna vacío
    }
  }
}
