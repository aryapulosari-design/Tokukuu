import 'package:flutter_test/flutter_test.dart';
import 'package:tokokuu/store.dart';

void main() {
  // ── helper ─────────────────────────────────────────────────────────────────
  SaleLine line(Product p, {double qty = 1}) => SaleLine(
        productId: p.id,
        name: p.name,
        price: p.price,
        quantity: qty,
        unit: p.unit,
      );

  Product beras() =>
      Product(id: 'beras', name: 'Beras 5 kg', price: 75000, unit: 'kg');
  Product gula() =>
      Product(id: 'gula', name: 'Gula', price: 15000, unit: 'kg');

  // ── harga historis ─────────────────────────────────────────────────────────
  test('harga transaksi tetap walau harga barang berubah', () {
    final data = StoreData();
    final product = beras();
    data.products.add(product);
    final sale = data.addSale(
      [line(product, qty: 2)],
      customer: 'Bu Siti',
      paid: 50000,
    );
    product.price = 80000;
    expect(sale.subtotal, 150000);
    expect(sale.total, 150000); // tanpa diskon
    expect(data.remaining(sale), 100000);
    data.payDebt(sale, 40000);
    expect(data.remaining(sale), 60000);
    expect(() => data.payDebt(sale, 60001), throwsArgumentError);
  });

  // ── validasi hutang ────────────────────────────────────────────────────────
  test('hutang wajib punya nama dan pembayaran tidak boleh melebihi total', () {
    final data = StoreData();
    final lines = [line(gula())];
    expect(
      () => data.addSale(lines, customer: '', paid: 0),
      throwsArgumentError,
    );
    expect(
      () => data.addSale(lines, customer: '', paid: 16000),
      throwsArgumentError,
    );
    expect(money(1234567), 'Rp 1.234.567');
  });

  // ── diskon ─────────────────────────────────────────────────────────────────
  test('diskon mengurangi total dan sisa hutang', () {
    final data = StoreData();
    final sale = data.addSale(
      [line(gula(), qty: 2)], // subtotal = 30000
      customer: 'Pak Ari',
      paid: 20000,
      discount: 5000, // total = 25000
    );
    expect(sale.subtotal, 30000);
    expect(sale.total, 25000);
    expect(data.remaining(sale), 5000);
  });

  test('diskon tidak boleh melebihi subtotal', () {
    final data = StoreData();
    expect(
      () => data.addSale(
        [line(gula())],
        customer: '',
        paid: 0,
        discount: 99999,
      ),
      throwsArgumentError,
    );
  });

  // ── jumlah desimal ─────────────────────────────────────────────────────────
  test('jumlah desimal dihitung benar', () {
    final data = StoreData();
    final p = Product(id: 'minyak', name: 'Minyak', price: 20000, unit: 'liter');
    final sale = data.addSale(
      [SaleLine(productId: p.id, name: p.name, price: p.price, quantity: 1.5, unit: p.unit)],
      customer: '',
      paid: 30000,
    );
    expect(sale.total, 30000); // 20000 * 1.5 = 30000
  });

  // ── void transaksi ─────────────────────────────────────────────────────────
  test('transaksi yang divoid tidak masuk sisa hutang', () {
    final data = StoreData();
    final product = beras();
    data.products.add(product);
    final sale = data.addSale(
      [line(product)],
      customer: 'Bu Ani',
      paid: 0,
    );
    expect(data.remaining(sale), 75000);
    data.voidSale(sale);
    expect(sale.isVoided, isTrue);
    expect(data.remaining(sale), 0);
  });

  test('transaksi yang sudah menerima cicilan tidak bisa divoid', () {
    final data = StoreData();
    final product = beras();
    data.products.add(product);
    final sale = data.addSale(
      [line(product)],
      customer: 'Bu Siti',
      paid: 10000,
    );
    data.payDebt(sale, 5000);
    expect(() => data.voidSale(sale), throwsArgumentError);
  });

  // ── metode pembayaran ──────────────────────────────────────────────────────
  test('metode pembayaran tersimpan di transaksi dan cicilan', () {
    final data = StoreData();
    final product = gula();
    data.products.add(product);
    final sale = data.addSale(
      [line(product)],
      customer: 'Bu Rina',
      paid: 5000,
      method: 'QRIS',
    );
    expect(sale.method, 'QRIS');
    data.payDebt(sale, 5000, method: 'Transfer');
    expect(data.payments.last.method, 'Transfer');
    expect(data.remaining(sale), 5000);
  });

  // ── backup/restore JSON ────────────────────────────────────────────────────
  test('encode-decode cadangan mempertahankan semua data', () {
    final original = StoreData();
    final p = beras();
    original.products.add(p);
    original.addSale([line(p)], customer: '', paid: 75000, method: 'Tunai');
    final json = original.encodeBackup();
    final restored = StoreData.decode(json);
    expect(restored.products.length, 1);
    expect(restored.sales.length, 1);
    expect(restored.sales.first.total, 75000);
  });

  test('decode JSON biasa (bukan backup) juga berhasil', () {
    final original = StoreData();
    original.products.add(gula());
    final json = original.encode();
    final restored = StoreData.decode(json);
    expect(restored.products.length, 1);
  });

  // ── quantityLabel ──────────────────────────────────────────────────────────
  test('quantityLabel membuang nol tak perlu', () {
    expect(quantityLabel(1.0), '1');
    expect(quantityLabel(1.5), '1.5');
    expect(quantityLabel(1.50), '1.5');
    expect(quantityLabel(2.0), '2');
  });

  // ── barang nonaktif ────────────────────────────────────────────────────────
  test('barang nonaktif tidak mempengaruhi riwayat transaksi lama', () {
    final data = StoreData();
    final p = beras();
    data.products.add(p);
    final sale = data.addSale([line(p)], customer: '', paid: 75000);
    p.active = false;
    // harga historis tetap tersimpan di sale.lines
    expect(sale.lines.first.price, 75000);
    expect(sale.total, 75000);
  });
}
