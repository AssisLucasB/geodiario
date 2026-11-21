import 'package:flutter_test/flutter_test.dart';
import 'package:geodiario/main.dart';

void main() {
  testWidgets('Renderiza a tela inicial do GeoDiário', (WidgetTester tester) async {
    await tester.pumpWidget(const GeoDiarioApp());
    expect(find.text('GeoDiário'), findsOneWidget);
  });
}
