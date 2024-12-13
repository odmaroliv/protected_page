import 'package:flutter/material.dart';
import 'route_config.dart';
import 'access_policy.dart';
import 'access_provider.dart';
import 'access_texts.dart';

class AccessConfig {
  static String rolesKey = 'roles';
  static String permissionsKey = 'permissions';
  static bool usePermissions = false;

  static final List<RouteConfig> _routes = [];
  static AccessProvider? globalProvider;
  static final Map<String, List<String>> roleGroups = {};
  static Widget Function(BuildContext context)? globalFallback;
  static AccessTexts texts = AccessTexts.defaults();

  /// Agrega rutas con su configuración
  static void addRoutes(List<RouteConfig> routes) {
    _routes.addAll(routes);
  }

  /// Valida el acceso para una ruta
  static Future<bool> canAccess(String routeName) async {
    final route = _routes.firstWhere(
      (config) => config.routeName == routeName,
      orElse: () => const RouteConfig(
        routeName: '',
        policy: AccessPolicy(),
        child: Scaffold(body: Center(child: Text("No page defined"))),
      ),
    );

    final provider = globalProvider;
    if (provider == null) {
      debugPrint('AccessConfig: globalProvider is not set. Denying access.');
      return false;
    }

    return route.policy.validate(provider);
  }

  /// Obtiene el fallback para una ruta
  static Widget getFallback(String routeName, BuildContext context) {
    final route = _routes.firstWhere(
      (config) => config.routeName == routeName,
      orElse: () => const RouteConfig(
        routeName: '',
        policy: AccessPolicy(),
        child: Scaffold(body: Center(child: Text("No page defined"))),
      ),
    );

    return route.fallback ??
        globalFallback?.call(context) ??
        Scaffold(body: Center(child: Text(texts.accessDenied)));
  }

  /// Configura claves para roles y permisos
  static void setKeys({String? rolesKey, String? permissionsKey}) {
    if (rolesKey != null && rolesKey.isNotEmpty) {
      AccessConfig.rolesKey = rolesKey;
    } else {
      throw ArgumentError('rolesKey must not be empty.');
    }

    if (permissionsKey != null && permissionsKey.isNotEmpty) {
      AccessConfig.permissionsKey = permissionsKey;
    } else {
      throw ArgumentError('permissionsKey must not be empty.');
    }
  }

  /// Configura si se usan permisos
  static void setUsePermissions(bool value) {
    AccessConfig.usePermissions = value;
  }

  /// Registra un grupo de roles
  static void registerRoleGroup(String groupName, List<String> roles) {
    roleGroups[groupName] = roles;
  }

  /// Obtiene los roles de un grupo
  static List<String> getRolesFromGroup(String groupName) {
    return roleGroups[groupName] ?? [];
  }

  /// Configura fallback global
  static void setGlobalFallback(
      Widget Function(BuildContext context) fallback) {
    globalFallback = fallback;
  }
}
