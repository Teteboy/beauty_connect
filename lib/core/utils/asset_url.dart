import '../services/api_service.dart';

/// Normalizes backend-provided asset URLs to absolute URLs.
///
/// Newer uploads are stored as `/uploads/...` paths; this helper
/// prepends the API server origin so `CachedNetworkImage` can load them.
String? resolveAssetUrl(String? url) => ApiService.resolveImageUrl(url);
