import 'package:flutter/material.dart';
import 'access_config.dart';

class AccessGuard extends StatelessWidget {
  final String routeName;
  final Widget child;
  final bool? showLoader; // Permite sobrescribir la configuración global

  const AccessGuard({
    required this.routeName,
    required this.child,
    this.showLoader, // Si no se especifica, se usa la configuración global
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loaderEnabled = showLoader ?? AccessConfig.globalShowLoader;

    return FutureBuilder<bool>(
      future: AccessConfig.canAccess(routeName),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loaderEnabled
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          debugPrint('AccessGuard: Access denied for route $routeName.');

          if (AccessConfig.redirectRoute != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(
                  context, AccessConfig.redirectRoute!);
            });
          } else {
            return AccessConfig.getFallback(routeName, context);
          }

          return const SizedBox.shrink();
        }

        return child;
      },
    );
  }
}
