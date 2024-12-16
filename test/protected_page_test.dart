import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protected_page/protected_page.dart';

void main() {
  group('AccessConfig and AccessPolicy Tests', () {
    setUp(() {
      AccessConfig.roleGroups.clear();
      AccessConfig.addRoutes([]);
      AccessConfig.globalProvider = null;
      AccessConfig.setGlobalFallback(
          (context) => const Scaffold(body: Text('Global Fallback')));
    });
    testWidgets('AccessConfig denies access when permissions do not match',
        (tester) async {
      AccessConfig.globalProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: [],
        permissions: ['read'],
      );

      AccessConfig.addRoutes([
        RouteConfig(
          routeName: '/settings',
          policy: AccessPolicy(permissions: ['write']),
          childBuilder: (_) => Scaffold(body: Text('Settings Page')),
          fallback: Scaffold(body: Text('Access Denied')),
        ),
      ]);

      await tester.pumpWidget(MaterialApp(
        home: AccessGuard(
          routeName: '/settings',
          childBuilder: (_) => Text('Settings Page'),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Access Denied"), findsOneWidget);
    });

    test('AccessPolicy allows access when no roles or permissions are defined',
        () async {
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: [],
        permissions: [],
      );

      const policy = AccessPolicy();

      final result = await policy.validate(mockProvider);

      expect(result, isTrue); // Sin restricciones, se permite el acceso
    });
    test('AccessPolicy denies access with malicious roles', () async {
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: ['<script>alert("hack")</script>'],
        permissions: [],
      );

      const policy = AccessPolicy(roles: ['admin']);

      final result = await policy.validate(mockProvider);

      expect(result, isFalse); // Acceso denegado por roles no coincidentes
    });
    testWidgets('AccessConfig denies access if globalProvider is missing',
        (tester) async {
      AccessConfig.globalProvider = null;

      AccessConfig.addRoutes([
        RouteConfig(
          routeName: '/secure',
          policy: AccessPolicy(roles: ['admin']),
          childBuilder: (_) => Scaffold(body: Text('Secure Page')),
          fallback: Scaffold(body: Text('Access Denied')),
        ),
      ]);

      await tester.pumpWidget(MaterialApp(
        home: AccessGuard(
          routeName: '/secure',
          childBuilder: (_) => Text('Secure Page'),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Access Denied"), findsOneWidget);
    });
    testWidgets('AccessConfig uses fallback when no fallback is set for route',
        (tester) async {
      AccessConfig.setGlobalFallback(
          (context) => const Scaffold(body: Text('Global Fallback')));

      AccessConfig.addRoutes([
        RouteConfig(
          routeName: '/no-fallback',
          policy: AccessPolicy(roles: ['admin']),
          childBuilder: (_) => Scaffold(body: Text('Protected Page')),
        ),
      ]);

      await tester.pumpWidget(MaterialApp(
        home: AccessGuard(
          routeName: '/no-fallback',
          childBuilder: (_) => Text('Protected Page'),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Global Fallback"), findsOneWidget);
    });
    test('AccessPolicy validates correctly with a large number of roles',
        () async {
      final roles = List.generate(5000, (index) => 'role_$index');
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: roles,
        permissions: [],
      );

      const policy = AccessPolicy(
        roles: ['role_4999'], // Último rol en la lista
      );

      final result = await policy.validate(mockProvider);

      expect(result, isTrue); // Asegura que la validación es correcta
    });
    test('AccessPolicy validates correctly with a large number of permissions',
        () async {
      final permissions = List.generate(5000, (index) => 'permission_$index');
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: [],
        permissions: permissions,
      );

      const policy = AccessPolicy(
        permissions: ['permission_4999'], // Último permiso en la lista
      );

      final result = await policy.validate(mockProvider);

      expect(result, isTrue); // Asegura que la validación es correcta
    });

    test('AccessPolicy handles concurrent validations correctly', () async {
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: ['role_1', 'role_2'],
        permissions: ['permission_1', 'permission_2'],
      );

      const policy1 = AccessPolicy(
        roles: ['role_1'],
        permissions: ['permission_1'],
      );

      const policy2 = AccessPolicy(
        roles: ['role_2'],
        permissions: ['permission_2'],
      );

      // Ejecuta validaciones concurrentes
      final results = await Future.wait([
        policy1.validate(mockProvider),
        policy2.validate(mockProvider),
      ]);

      expect(results[0], isTrue); // Primera validación debe ser true
      expect(results[1], isTrue); // Segunda validación debe ser true
    });
    test('AccessPolicy handles conflicting concurrent validations', () async {
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: ['role_1'],
        permissions: ['permission_1'],
      );

      const policy1 = AccessPolicy(
        roles: ['role_1'],
        permissions: ['permission_1'],
      );

      const policy2 = AccessPolicy(
        roles: ['role_2'], // Este rol no está presente
        permissions: ['permission_2'], // Este permiso no está presente
      );

      // Ejecuta validaciones concurrentes
      final results = await Future.wait([
        policy1.validate(mockProvider),
        policy2.validate(mockProvider),
      ]);

      expect(results[0], isTrue); // Primera validación debe ser true
      expect(results[1], isFalse); // Segunda validación debe ser false
    });
    test('AccessPolicy handles multiple users and policies concurrently',
        () async {
      final mockProvider1 = MockAccessProvider(
        isAuthenticated: true,
        roles: ['role_user1'],
        permissions: ['permission_user1'],
      );

      final mockProvider2 = MockAccessProvider(
        isAuthenticated: true,
        roles: ['role_user2'],
        permissions: ['permission_user2'],
      );

      const policy1 = AccessPolicy(
        roles: ['role_user1'],
        permissions: ['permission_user1'],
      );

      const policy2 = AccessPolicy(
        roles: ['role_user2'],
        permissions: ['permission_user2'],
      );

      // Ejecuta validaciones concurrentes
      final results = await Future.wait([
        policy1.validate(mockProvider1),
        policy2.validate(mockProvider2),
      ]);

      expect(results[0], isTrue); // Usuario 1 pasa la validación
      expect(results[1], isTrue); // Usuario 2 pasa la validación
    });
    test('AccessConfig allows setting and retrieving keys', () {
      AccessConfig.setKeys(
          rolesKey: 'user_roles', permissionsKey: 'user_permissions');

      expect(AccessConfig.rolesKey, 'user_roles');
      expect(AccessConfig.permissionsKey, 'user_permissions');
    });

    testWidgets('AccessConfig uses global fallback when provider is not set',
        (tester) async {
      AccessConfig.globalProvider = null;
      AccessConfig.setGlobalFallback(
          (context) => const Scaffold(body: Text('Global Fallback')));

      await tester.pumpWidget(MaterialApp(
        home: AccessGuard(
          routeName: '/undefined',
          childBuilder: (_) => Scaffold(body: Text("Should not appear")),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Global Fallback"), findsOneWidget);
    });

    testWidgets('AccessConfig denies access when roles do not match',
        (tester) async {
      AccessConfig.globalProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: ['user'],
        permissions: [],
      );

      AccessConfig.addRoutes([
        RouteConfig(
          routeName: '/dashboard',
          policy: AccessPolicy(roles: ['admin']),
          childBuilder: (_) => Scaffold(body: Text('Dashboard')),
          fallback: const Scaffold(body: Text('Access Denied')),
        ),
      ]);

      await tester.pumpWidget(MaterialApp(
        home: AccessGuard(
          routeName: '/dashboard',
          childBuilder: (_) => const Scaffold(body: Text('Dashboard')),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Access Denied"), findsOneWidget);
    });

    testWidgets('AccessConfig allows access when user belongs to a role group',
        (tester) async {
      AccessConfig.registerRoleGroup('admins', ['admin', 'superadmin']);
      AccessConfig.globalProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: ['superadmin'],
        permissions: [],
      );

      AccessConfig.addRoutes([
        RouteConfig(
          routeName: '/admin-area',
          policy: AccessPolicy(roles: ['admins']),
          childBuilder: (_) => const Scaffold(body: Text('Admin Area')),
        ),
      ]);

      await tester.pumpWidget(MaterialApp(
        home: AccessGuard(
          routeName: '/admin-area',
          childBuilder: (_) => const Scaffold(body: Text('Admin Area')),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Admin Area"), findsOneWidget);
    });

    test('AccessPolicy custom validator overrides roles and permissions',
        () async {
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: ['user'],
        permissions: [],
      );

      final policy = AccessPolicy(
        roles: ['admin'],
        customValidator: () async {
          debugPrint('Custom validator executed.');
          return true;
        },
      );

      final result = await policy.validate(mockProvider);

      expect(result, isTrue);
    });

    test('AccessPolicy denies access when validator fails', () async {
      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: ['admin'],
        permissions: ['view_dashboard'],
      );

      final policy = AccessPolicy(
        customValidator: () async {
          throw Exception('Validator failed');
        },
      );

      final result = await policy.validate(mockProvider);

      expect(result, isFalse);
    });

    test('AccessPolicy handles large number of roles and permissions',
        () async {
      final roles = List.generate(1000, (index) => 'role_$index');
      final permissions = List.generate(1000, (index) => 'permission_$index');

      final mockProvider = MockAccessProvider(
        isAuthenticated: true,
        roles: roles,
        permissions: permissions,
      );

      const policy = AccessPolicy(
        roles: ['role_999'],
        permissions: ['permission_999'],
      );

      final result = await policy.validate(mockProvider);

      expect(result, isTrue);
    });
  });

  testWidgets('AccessGuard shows fallback when no redirectRoute is set',
      (tester) async {
    AccessConfig.globalProvider = MockAccessProvider(
      isAuthenticated: false,
      roles: [],
      permissions: [],
    );

    AccessConfig.addRoutes([
      RouteConfig(
        routeName: '/dashboard',
        policy: AccessPolicy(roles: ['admin']),
        childBuilder: (_) => const Scaffold(body: Text('Dashboard')),
        fallback: const Scaffold(body: Text('Access Denied')),
      ),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: AccessGuard(
        routeName: '/dashboard',
        childBuilder: (_) => const Text('Dashboard'),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text("Access Denied"), findsOneWidget);
  });

  testWidgets('AccessGuard redirects to redirectRoute when set',
      (tester) async {
    AccessConfig.setRedirectRoute('/login');
    AccessConfig.globalProvider = MockAccessProvider(
      isAuthenticated: false,
      roles: [],
      permissions: [],
    );

    AccessConfig.addRoutes([
      RouteConfig(
        routeName: '/dashboard',
        policy: AccessPolicy(roles: ['admin']),
        childBuilder: (_) => const Scaffold(body: Text('Dashboard')),
      ),
    ]);

    await tester.pumpWidget(MaterialApp(
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => AccessGuard(
              routeName: '/dashboard',
              childBuilder: (_) => const Scaffold(body: Text('Dashboard')),
            ),
        '/login': (context) => const Scaffold(body: Text('Login Page')),
      },
    ));

    await tester.pumpAndSettle();

    expect(find.text("Login Page"), findsOneWidget);
  });

  testWidgets('Global loader configuration is respected', (tester) async {
    AccessConfig.setGlobalLoader(false); // Desactiva el loader globalmente
    AccessConfig.globalProvider = MockAccessProvider(
      isAuthenticated: false, // Simula que no está autenticado
      roles: [],
      permissions: [],
    );

    AccessConfig.addRoutes([
      RouteConfig(
        routeName: '/protected',
        policy: const AccessPolicy(roles: ['admin']),
        childBuilder: (_) => Scaffold(body: Text('Protected Content')),
        fallback: const Scaffold(body: Text('Access Denied')),
      ),
    ]);

    // Define las rutas necesarias en el MaterialApp
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/protected',
      routes: {
        '/protected': (context) => AccessGuard(
              routeName: '/protected',
              childBuilder: (_) => const Text('Protected Content'),
            ),
        '/login': (context) => const Scaffold(body: Text('Login Page')),
      },
    ));

    await tester.pumpAndSettle();

    // Verifica que se redirige correctamente
    expect(find.text("Login Page"), findsOneWidget);
  });
}

/// Mock de AccessProvider para pruebas
class MockAccessProvider implements AccessProvider {
  final bool _isAuthenticated;
  final List<String> roles;
  final List<String> permissions;

  MockAccessProvider({
    required bool isAuthenticated,
    required this.roles,
    required this.permissions,
  }) : _isAuthenticated = isAuthenticated;

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  @override
  Future<List<String>> getRoles() async {
    return roles;
  }

  @override
  Future<List<String>> getPermissions() async {
    return permissions;
  }
}
