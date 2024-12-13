import 'package:flutter/material.dart';
import 'access_policy.dart';

class RouteConfig {
  final String routeName;
  final AccessPolicy policy;
  final Widget child;
  final Widget? fallback;

  const RouteConfig({
    required this.routeName,
    required this.policy,
    required this.child,
    this.fallback,
  });
}
