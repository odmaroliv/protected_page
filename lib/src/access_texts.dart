class AccessTexts {
  final String accessDenied;
  final String loading;

  AccessTexts({
    this.accessDenied = "Access denied",
    this.loading = "Loading...",
  });

  static AccessTexts defaults() {
    return AccessTexts();
  }
}
