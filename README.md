Índice
Cómo Configurar la Librería
Configuración básica.
Configuración de roles, permisos y fallback global.
Proteger Widgets con AccessGuard
Proteger Rutas con GetX
Validación Asíncrona
Casos de Uso Avanzados
Mapa de Pasos para Implementación
1. Cómo Configurar la Librería
Configuración Básica
Primero, importa la librería y configura AccessConfig con los parámetros básicos.

dart
Copiar código
void main() {
  runApp(const MyApp());

  // Configuración global para roles y permisos
  AccessConfig.setKeys(rolesKey: 'user_roles', permissionsKey: 'user_permissions');
  AccessConfig.setUsePermissions(true);

  // Configura un proveedor global (ejemplo con tokens)
  AccessConfig.globalProvider = TokenAccessProvider(
    tokenProvider: () async => "TOKEN_JWT",
    decodeToken: (token) async => {
      'user_roles': ['admin'],
      'user_permissions': ['write', 'read']
    },
  );

  // Configura un fallback global
  AccessConfig.setGlobalFallback(
    (context) => Scaffold(
      body: Center(child: Text('Access Denied.')),
    ),
  );
}
Configuración de Roles y Permisos
Puedes registrar grupos de roles para simplificar las políticas.

dart
Copiar código
AccessConfig.registerRoleGroup('admins', ['admin', 'superadmin']);
AccessConfig.registerRoleGroup('editors', ['editor', 'content_manager']);
Agregar Rutas y Políticas
Define las rutas de tu aplicación y las políticas asociadas:

dart
Copiar código
AccessConfig.addRoutes([
  RouteConfig(
    routeName: '/dashboard',
    policy: AccessPolicy(roles: ['admin']),
    child: const DashboardPage(),
    fallback: Scaffold(body: Text('Access Denied')),
  ),
  RouteConfig(
    routeName: '/settings',
    policy: AccessPolicy(permissions: ['write']),
    child: const SettingsPage(),
  ),
]);
2. Proteger Widgets con AccessGuard
Uso Básico
Usa AccessGuard para proteger un widget en particular.

dart
Copiar código
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AccessGuard(
        routeName: '/dashboard',
        child: const DashboardPage(),
      ),
    );
  }
}
Si el usuario no cumple con la política, se mostrará el fallback correspondiente.

3. Proteger Rutas con GetX
Definición de Rutas con GetX
En GetX, puedes usar AccessGuard directamente en la lista de rutas:

dart
Copiar código
final List<GetPage> appRoutes = [
  GetPage(
    name: '/dashboard',
    page: () => AccessGuard(
      routeName: '/dashboard',
      child: const DashboardPage(),
    ),
  ),
  GetPage(
    name: '/settings',
    page: () => AccessGuard(
      routeName: '/settings',
      child: const SettingsPage(),
    ),
  ),
];
Middleware para Validación
Si prefieres usar middlewares en GetX:

dart
Copiar código
class AccessMiddleware extends GetMiddleware {
  final String routeName;

  AccessMiddleware(this.routeName);

  @override
  RouteSettings? redirect(String? route) {
    if (!AccessConfig.canAccess(routeName)) {
      return const RouteSettings(name: '/access-denied');
    }
    return null;
  }
}

final List<GetPage> appRoutes = [
  GetPage(
    name: '/dashboard',
    page: () => const DashboardPage(),
    middlewares: [AccessMiddleware('/dashboard')],
  ),
];
4. Validación Asíncrona
Si las políticas incluyen validaciones asíncronas, como llamadas a una API, el FutureBuilder manejará automáticamente la espera. Puedes combinar roles y validadores personalizados:

dart
Copiar código
AccessConfig.addRoutes([
  RouteConfig(
    routeName: '/profile',
    policy: AccessPolicy(
      roles: ['user'],
      customValidator: () async {
        // Simula una validación externa
        await Future.delayed(const Duration(seconds: 2));
        return true;
      },
    ),
    child: const ProfilePage(),
  ),
]);
5. Casos de Uso Avanzados
Caso 1: Fallback Global Dinámico
Puedes mostrar un fallback dinámico basado en el estado del usuario.

dart
Copiar código
AccessConfig.setGlobalFallback(
  (context) {
    final userRoles = AccessConfig.globalProvider?.getRoles();
    if (userRoles?.contains('guest') ?? false) {
      return Scaffold(body: Text('Login Required.'));
    }
    return Scaffold(body: Text('Access Denied.'));
  },
);
Caso 2: Manejo de Grandes Listas de Roles
La librería maneja listas grandes de roles y permisos de forma eficiente.

dart
Copiar código
final roles = List.generate(10000, (index) => 'role_$index');
AccessConfig.globalProvider = MockAccessProvider(
  isAuthenticated: true,
  roles: roles,
  permissions: [],
);
Caso 3: Validación Simultánea de Múltiples Usuarios
Puedes ejecutar validaciones simultáneas en distintas políticas.

dart
Copiar código
final results = await Future.wait([
  AccessConfig.canAccess('/dashboard'),
  AccessConfig.canAccess('/settings'),
]);
6. Mapa de Pasos para Implementación
1. Configurar AccessConfig
Define las claves (rolesKey, permissionsKey).
Configura un proveedor global.
Establece un fallback global.
2. Registrar Rutas
Usa AccessConfig.addRoutes() para registrar las rutas con sus políticas.
3. Usar AccessGuard
Protege widgets individuales con AccessGuard.
4. Integrar con GetX (Opcional)
Usa AccessGuard en GetPage o implementa middlewares.
