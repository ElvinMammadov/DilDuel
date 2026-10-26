import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/utils/rebuild_all_elements.dart';
import 'package:flutter_test/flutter_test.dart';

String _label = 'before';

class _ConstLabel extends StatelessWidget {
  const _ConstLabel();

  @override
  Widget build(BuildContext context) => Text(_label);
}

void main() {
  testWidgets('refreshes const widgets that a parent rebuild skips', (
    WidgetTester tester,
  ) async {
    _label = 'before';
    late StateSetter rebuildParent;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            rebuildParent = setState;
            return const _ConstLabel();
          },
        ),
      ),
    );

    _label = 'after';
    rebuildParent(() {});
    await tester.pump();
    check(find.text('before').evaluate()).isNotEmpty();

    rebuildAllElements();
    await tester.pump();
    check(find.text('after').evaluate()).isNotEmpty();
    check(find.text('before').evaluate()).isEmpty();
  });
}
