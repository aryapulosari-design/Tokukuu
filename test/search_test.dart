import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokokuu/main.dart';
import 'package:tokokuu/store.dart';

void main() {
  testWidgets('pencarian barang di kasir memfilter daftar', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      storageKey: StoreData(products: sampleProducts()).encode(),
    });

    await tester.pumpWidget(const TokokuApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Kasir'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih barang'), findsOneWidget);

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Cari barang untuk dijual',
    );
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'tidakada');
    await tester.pump();
    expect(find.text('Barang tidak ditemukan'), findsOneWidget);

    await tester.enterText(searchField, 'beras');
    await tester.pump();
    expect(find.text('Beras Premium 5 kg'), findsOneWidget);
    expect(find.text('Barang tidak ditemukan'), findsNothing);
  });
}
