import 'package:flutter/widgets.dart';

/// Marks every mounted element for rebuild on the next frame.
///
/// `'key'.tr()` does not depend on the locale, so after a language change
/// Flutter skips subtrees that are identical to the previous build (const
/// widgets, tabs kept alive by an `IndexedStack`) and they keep showing the
/// old language. Call this once the new translations have loaded.
void rebuildAllElements() {
  void rebuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(rebuild);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
}
