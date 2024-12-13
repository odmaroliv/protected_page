# Protected Page: Flutter Access Control and Permission Management Library

## 📋 Table of Contents

- [Protected Page: Flutter Access Control and Permission Management Library](#protected-page-flutter-access-control-and-permission-management-library)
  - [📋 Table of Contents](#-table-of-contents)
  - [🚀 How to Configure the Library](#-how-to-configure-the-library)
    - [Basic Configuration](#basic-configuration)
    - [Roles and Permissions Configuration](#roles-and-permissions-configuration)
    - [Adding Routes and Policies](#adding-routes-and-policies)
  - [🛡️ Protecting Widgets with AccessGuard](#️-protecting-widgets-with-accessguard)
  - [🔒 Protecting Routes with GetX](#-protecting-routes-with-getx)
  - [🔄 Asynchronous Validation](#-asynchronous-validation)
  - [🆕 New Features](#-new-features)
    - [Redirect to Login or Fallback Route](#redirect-to-login-or-fallback-route)
    - [Configuration](#configuration)
    - [Global Loader Configuration](#global-loader-configuration)
    - [Enable or Disable the Loader](#enable-or-disable-the-loader)
    - [Customize the Global Loader](#customize-the-global-loader)
    - [Example](#example)
  - [🚧 Advanced Use Cases](#-advanced-use-cases)
    - [Dynamic Global Fallback](#dynamic-global-fallback)
  - [📦 Installation](#-installation)
  - [🤝 Contributing](#-contributing)
    - [Contribution Guidelines](#contribution-guidelines)
  - [📄 License](#-license)
  - [📬 Contact](#-contact)

## 🚀 How to Configure the Library

### Basic Configuration

```dart
void main() {
  runApp(const MyApp());

  // Global configuration for roles and permissions
  AccessConfig.setKeys(rolesKey: 'user_roles', permissionsKey: 'user_permissions');
  AccessConfig.setUsePermissions(true);

  // Configure a global provider (example with tokens)
  AccessConfig.globalProvider = TokenAccessProvider(
    tokenProvider: () async => "TOKEN_JWT",
    decodeToken: (token) async => {
      'user_roles': ['admin'],
      'user_permissions': ['write', 'read']
    },
  );

  // Configure a global fallback
  AccessConfig.setGlobalFallback(
    (context) => Scaffold(
      body: Center(child: Text('Access Denied.')),
    ),
  );
}
```

### Roles and Permissions Configuration

```dart
AccessConfig.registerRoleGroup('admins', ['admin', 'superadmin']);
AccessConfig.registerRoleGroup('editors', ['editor', 'content_manager']);
```

### Adding Routes and Policies

```dart
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
```

## 🛡️ Protecting Widgets with AccessGuard

```dart
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
```

## 🔒 Protecting Routes with GetX

```dart
final List appRoutes = [
  GetPage(
    name: '/dashboard',
    page: () => AccessGuard(
      routeName: '/dashboard',
      child: const DashboardPage(),
    ),
  ),
  // More routes...
];
```

## 🔄 Asynchronous Validation

```dart
AccessConfig.addRoutes([
  RouteConfig(
    routeName: '/profile',
    policy: AccessPolicy(
      roles: ['user'],
      customValidator: () async {
        // Simulate external validation
        await Future.delayed(const Duration(seconds: 2));
        return true;
      },
    ),
    child: const ProfilePage(),
  ),
]);
```

## 🆕 New Features

### Redirect to Login or Fallback Route

If the user is not authenticated, you can configure a `redirectRoute` to send them to a login page or any other fallback route.

### Configuration

```dart
AccessConfig.setRedirectRoute('/login');

MaterialApp(
  initialRoute: '/dashboard',
  routes: {
    '/dashboard': (context) => AccessGuard(
          routeName: '/dashboard',
          child: const DashboardPage(),
        ),
    '/login': (context) => const Scaffold(body: Text('Login Page')),
  },
);
```

If the user is not authenticated, they will automatically be redirected to /login.

**Behavior without** `redirectRoute`
If redirectRoute is not set, the system will fall back to:

The route-specific fallback, if provided.
The global fallback, if no route-specific fallback is defined.

### Global Loader Configuration

\
You can now control whether a loader is displayed globally during access validation. Use the `AccessConfig.setGlobalLoader` method to enable or disable this behavior.

By default, the loader is enabled and shows a simple placeholder widget `(Center(child: CircularProgressIndicator()))`. You can disable it or provide a custom global loader widget.

### Enable or Disable the Loader

```dart
// Enable the global loader (default behavior)
AccessConfig.setGlobalLoader(true);

// Disable the global loader
AccessConfig.setGlobalLoader(false);
```

### Customize the Global Loader

You can provide a custom global loader widget to override the default behavior.

```dart
// Set a custom loader globally
AccessConfig.setGlobalLoaderWidget((context) => Center(child: Text('Loading, please wait...')));
```

### Example

Here’s an example showing how to use the global loader feature:

```dart
void main() {
  AccessConfig.setGlobalLoader(true); // Enable the loader globally
  AccessConfig.setGlobalLoaderWidget((context) => Center(child: CircularProgressIndicator()));

  AccessConfig.setRedirectRoute('/login');
  AccessConfig.globalProvider = MockAccessProvider(
    isAuthenticated: false,
    roles: [],
    permissions: [],
  );

  AccessConfig.addRoutes([
    const RouteConfig(
      routeName: '/dashboard',
      policy: AccessPolicy(roles: ['admin']),
      child: Scaffold(body: Text('Dashboard Page')),
      fallback: Scaffold(body: Text('Access Denied')),
    ),
  ]);

  runApp(MaterialApp(
    initialRoute: '/dashboard',
    routes: {
      '/dashboard': (context) => AccessGuard(
            routeName: '/dashboard',
            child: Scaffold(body: Text('Dashboard Page')),
          ),
      '/login': (context) => const Scaffold(body: Text('Login Page')),
    },
  ));
}

```

## 🚧 Advanced Use Cases

### Dynamic Global Fallback

```dart
AccessConfig.setGlobalFallback(
  (context) {
    final userRoles = AccessConfig.globalProvider?.getRoles();
    if (userRoles?.contains('guest') ?? false) {
      return Scaffold(body: Text('Login Required.'));
    }
    return Scaffold(body: Text('Access Denied.'));
  },
);
```

## 📦 Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  access_guard: ^latest_version
```

Then run:

```bash
flutter pub get
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/new-feature`)
3. Make your changes and commit (`git commit -m 'Add new feature'`)
4. Push your changes (`git push origin feature/new-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Keep code clean and readable
- Add tests for new features
- Document changes in the documentation
- Follow project style conventions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

```
MIT License

Copyright (c) [year] [full name or organization name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 📬 Contact

If you have questions or suggestions, please open an issue on GitHub.
