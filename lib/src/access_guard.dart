import 'package:flutter/material.dart';
import 'access_config.dart';

class AccessGuard extends StatelessWidget {
  final String routeName;
  final Widget child;

  const AccessGuard({
    required this.routeName,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AccessConfig.canAccess(routeName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(AccessConfig.texts.loading));
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
        }

        return child;
      },
    );
  }
}
