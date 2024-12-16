# 0.0.2

## Breaking Changes

Replaced child with childBuilder in RouteConfig and AccessGuard:

- Widgets are now constructed only when necessary, improving performance.
- Instead of passing a widget directly, provide a childBuilder method that returns a widget.

### Fixes

- Fixed an issue causing widget creation in protected routes during registration.
- Improved security and stability of access validations.
- Better handling of unmatched routes.

### Features

- Global Redirection: Configure a custom redirect route when access is denied (setRedirectRoute).
- Global Fallback: Set a default fallback for unauthorized routes (setGlobalFallback).
- Enhanced Async Validation: customValidator now takes precedence over roles and permissions in AccessPolicy.

### Performance

Widget Construction Optimization:

- Protected widgets are created only when accessing the corresponding route.
- Significant performance improvement for applications with multiple protected routes.

### Concurrent Validations:

- Improved handling of multiple access policies in parallel.

### Migration Example

```dart
// Before
RouteConfig(
  routeName: '/dashboard',
  child: DashboardPage(),
  policy: AccessPolicy(roles: ['admin'])
)

// After
RouteConfig(
  routeName: '/dashboard',
  childBuilder: (context) => DashboardPage(),
  policy: AccessPolicy(roles: ['admin'])
)
```

_This version maintains the core features of 0.0.1 while introducing improvements in performance, flexibility, and access control._

## 0.0.1

- Initial release of `protected_page` library.
- Provides a robust solution for managing access to protected routes in Flutter applications.
- Features:
  - Role- and permission-based access control via `AccessPolicy`.
  - Global fallback and route-specific fallback widgets for unauthorized access.
  - Integration with custom `AccessProvider` for flexible authentication and authorization logic.
  - Support for role groups to simplify complex role hierarchies.
  - Easy integration with `AccessGuard` widget for route protection.
  - Redirection support to login or custom routes when access is denied.
  - Custom validation logic via `customValidator` in `AccessPolicy`.
  - Performance optimized for large numbers of roles and permissions.
  - Handles concurrent access validations seamlessly.
  - Global loader configuration to control loading states during access validation.
