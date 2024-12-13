abstract class AccessProvider {
  Future<bool> isAuthenticated();
  Future<List<String>> getRoles();
  Future<List<String>> getPermissions();
}
