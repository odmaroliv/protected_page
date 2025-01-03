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

  static void addRoutes(List<RouteConfig> routes) {
    _routes.addAll(routes);
  }

  /// Configura el acceso a una ruta de forma protegida
  static Widget protect(String routeName, BuildContext context) {
    final route = _routes.firstWhere(
      (config) => config.routeName == routeName,
      orElse: () => RouteConfig(
        routeName: '',
        policy: AccessPolicy(),
        childBuilder: (_) => Scaffold(
            body: Center(child: Text("No page defined"))), // Usamos builder
      ),
    );

    final provider = globalProvider;
    if (provider == null) {
      return route.fallback ??
          globalFallback?.call(context) ??
          Scaffold(body: Center(child: Text(texts.accessDenied)));
    }

    return FutureBuilder<bool>(
      future: route.policy.validate(provider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(texts.loading));
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return route.fallback ??
              globalFallback?.call(context) ??
              Scaffold(body: Center(child: Text(texts.accessDenied)));
        }

        // Usamos el builder para crear el widget solo cuando sea necesario
        return route.childBuilder(context);
      },
    );
  }
}
