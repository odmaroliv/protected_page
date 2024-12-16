import 'package:flutter/material.dart';
import 'route_config.dart';
import 'access_policy.dart';
import 'access_provider.dart';
import 'access_texts.dart';

class AccessConfig {
  static String rolesKey = 'roles';
  static String permissionsKey = 'permissions';
  static bool usePermissions = false;
  static bool globalShowLoader = true;

  static final List<RouteConfig> _routes = [];
  static AccessProvider? globalProvider;
  static final Map<String, List<String>> roleGroups = {};
  static Widget Function(BuildContext context)? globalFallback;
  static AccessTexts texts = AccessTexts.defaults();
  static String? redirectRoute;

  /// Registra rutas protegidas
  static void addRoutes(List<RouteConfig> routes) {
    _routes.addAll(routes);
  }

  /// Valida el acceso a una ruta
  static Future<bool> canAccess(String routeName) async {
    final route = _findRoute(routeName);
    if (route == null) return false;

    final provider = globalProvider;
    if (provider == null) {
      debugPrint('AccessConfig: globalProvider is not set. Denying access.');
      return false;
    }

    return route.policy.validate(provider);
  }

  /// Encuentra una ruta registrada
  static RouteConfig? _findRoute(String routeName) {
    return _routes.cast<RouteConfig?>().firstWhere(
          (config) => config?.routeName == routeName,
          orElse: () => null, // Devuelve null si no encuentra la ruta
        );
  }

  /// Obtiene el fallback para una ruta protegida
  static Widget getFallback(String routeName, BuildContext context) {
    final route = _findRoute(routeName);

    return route?.fallback ??
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

  /// Registra un grupo de roles
  static void registerRoleGroup(String groupName, List<String> roles) {
    roleGroups[groupName] = roles;
  }

  /// Configura fallback global
  static void setGlobalFallback(
      Widget Function(BuildContext context) fallback) {
    globalFallback = fallback;
  }

  static void setRedirectRoute(String route) {
    redirectRoute = route;
  }

  static void setGlobalLoader(bool value) {
    globalShowLoader = value;
  }

  static List<String> getRolesFromGroup(String groupName) {
    return roleGroups[groupName] ?? [];
  }

  /// Configura si se usan permisos en las políticas de acceso
  static void setUsePermissions(bool value) {
    AccessConfig.usePermissions = value;
  }
}
