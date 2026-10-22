import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Retour en arrière sûr : dépile la route si possible,
/// sinon navigue vers [fallback] (utile quand l'écran a été
/// atteint via `context.go` et qu'il n'y a rien à dépiler).
void safePop(BuildContext context, {String fallback = '/home'}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}
