import 'package:flutter/widgets.dart';
import 'package:protected_page/protected_page.dart';

class AccessPolicy {
  final List<String>? roles;
  final List<String>? permissions;
  final Future<bool> Function()? customValidator;

  const AccessPolicy({this.roles, this.permissions, this.customValidator});

  /// Valida la política con un proveedor
  Future<bool> validate(AccessProvider provider) async {
    try {
      final isAuthenticated = await provider.isAuthenticated();
      if (!isAuthenticated) {
        debugPrint('AccessPolicy: User is not authenticated.');
        return false;
      }

      // Validador personalizado tiene prioridad
      if (customValidator != null) {
        final isValid = await customValidator!();
        debugPrint('AccessPolicy: Custom validator result = $isValid');
        return isValid;
      }

      // Validación de roles
      if (roles != null && roles!.isNotEmpty) {
        final expandedRoles = _expandRoles(roles!);
        final userRoles = await provider.getRoles();
        if (!expandedRoles.any(userRoles.contains)) {
          debugPrint('AccessPolicy: User roles do not match required roles.');
          return false;
        }
      }

      // Validación de permisos
      if (permissions != null && permissions!.isNotEmpty) {
        final userPermissions = await provider.getPermissions();
        if (!permissions!.any(userPermissions.contains)) {
          debugPrint(
              'AccessPolicy: User permissions do not match required permissions.');
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('AccessPolicy: Error during validation: $e');
      return false;
    }
  }

  /// Expande los grupos de roles en una lista completa de roles
  List<String> _expandRoles(List<String> roles) {
    final expandedRoles = <String>[];
    for (final role in roles) {
      if (AccessConfig.roleGroups.containsKey(role)) {
        expandedRoles.addAll(AccessConfig.getRolesFromGroup(role));
      } else {
        expandedRoles.add(role);
      }
    }
    return expandedRoles.toSet().toList(); // Evita duplicados
  }
}
