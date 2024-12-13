## 0.0.1

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
