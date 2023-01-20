import 'package:flutter/material.dart';

// Unfortunately IndexedStack does keep all children onstage for debugging:
// https://github.com/flutter/flutter/issues/111478
class IndexedStack2 extends IndexedStack {
  IndexedStack2({
    super.key,
    super.alignment,
    super.textDirection,
    super.sizing,
    super.index,
    super.children,
  });

  @override
  MultiChildRenderObjectElement createElement() {
    return _IndexedStackElement(this);
  }
}

class _IndexedStackElement extends MultiChildRenderObjectElement {
  _IndexedStackElement(IndexedStack super.widget);

  @override
  IndexedStack get widget => super.widget as IndexedStack;

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    final index = widget.index;
    if (index == null) {
      return super.debugVisitOnstageChildren(visitor);
    } else {
      final onlyOnstageChild = children.skip(index).iterator;
      if (onlyOnstageChild.moveNext()) {
        visitor(onlyOnstageChild.current);
      }
    }
  }
}
