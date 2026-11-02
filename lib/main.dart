import 'package:flutter/material.dart';

import 'data_io.dart';
import 'export.dart';
import 'store.dart';

void main() => runApp(const TokokuApp());

const ink = Color(0xFF18332C);
const green = Color(0xFF275A46);
const cream = Color(0xFFF7F5EE);
const muted = Color(0xFF64766B);
const line = Color(0xFFE1E6DD);
const accent = Color(0xFFE9C66B);

class TokokuApp extends StatelessWidget {
  const TokokuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tokoku · Toko Pak Irfan',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: green, surface: cream),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    home: const StorePage(),
  );
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  StoreData? data;
  String? loadError;
  int page = 0;
  final cart = <String, double>{};
  final search = TextEditingController();
  final cashierSearch = TextEditingController();
  final debtSearch = TextEditingController();
  String query = '';
  String cashierQuery = '';
  String debtQuery = '';
  bool showInactive = false;

  @override
  void initState() {
    super.initState();
    _load();
    search.addListener(
      () => setState(() => query = search.text.toLowerCase().trim()),
    );
    cashierSearch.addListener(
      () => setState(
        () => cashierQuery = cashierSearch.text.toLowerCase().trim(),
      ),
    );
    debtSearch.addListener(
      () => setState(() => debtQuery = debtSearch.text.toLowerCase().trim()),
    );
  }

  @override
  void dispose() {
    search.dispose();
    cashierSearch.dispose();
    debtSearch.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final loaded = await StoreData.load();
      // Toko baru langsung diberi contoh barang supaya bisa dicoba.
      if (loaded.products.isEmpty &&
          loaded.sales.isEmpty &&
          loaded.payments.isEmpty) {
        loaded.products.addAll(sampleProducts());
        await loaded.save();
      }
      if (mounted) setState(() => data = loaded);
    } catch (_) {
      if (mounted) {
        setState(
          () => loadError = 'Data toko tidak bisa dibaca. Jangan hapus data aplikasi; periksa penyimpanan perangkat.',
        );
      }
    }
  }

  Future<void> _save() async {
    try {
      await data!.save();
    } catch (_) {
      _notice(
        'Gagal menyimpan. Periksa penyimpanan perangkat sebelum menutup aplikasi.',
      );
    }
  }

  void _notice(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _productForm([Product? product]) async {
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(text: product?.price.toString() ?? '');
    var unit = product?.unit ?? 'pcs';
    final result = await showDialog<(String, int, String)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(product == null ? 'Tambah barang' : 'Ubah barang'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    autofocus: true,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama barang',
                      hintText: 'Contoh: Beras 5 kg',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga jual per satuan (Rp)',
                      hintText: 'Contoh: 75000',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: productUnits.contains(unit) ? unit : 'pcs',
                    decoration: const InputDecoration(labelText: 'Satuan'),
                    items: [
                      for (final option in productUnits)
                        DropdownMenuItem(value: option, child: Text(option)),
                    ],
                    onChanged: (value) => update(() => unit = value ?? 'pcs'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final label = name.text.trim();
                final amount = int.tryParse(price.text.trim());
                if (label.isEmpty ||
                    amount == null ||
                    amount < 0 ||
                    data!.products.any(
                      (item) =>
                          item.id != product?.id &&
                          item.name.toLowerCase() == label.toLowerCase(),
                    )) {
                  _notice('Isi nama unik dan harga bulat minimal Rp 0.');
                  return;
                }
                Navigator.pop(context, (label, amount, unit));
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    price.dispose();
    if (result == null) return;
    setState(() {
      if (product == null) {
        data!.products.add(
          Product(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: result.$1,
            price: result.$2,
            unit: result.$3,
          ),
        );
      } else {
        product.name = result.$1;
        product.price = result.$2;
        product.unit = result.$3;
      }
    });
    await _save();
  }

  Future<bool> _confirm(
    String title,
    String message, {
    String confirmLabel = 'Ya',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _toggleProduct(Product product) async {
    final next = !product.active;
    if (!next) {
      final confirmed = await _confirm(
        'Nonaktifkan ${product.name}?',
        'Barang tidak akan muncul di Kasir. Riwayat penjualannya tetap tersimpan dan bisa diaktifkan lagi kapan saja.',
        confirmLabel: 'Nonaktifkan',
      );
      if (!confirmed) return;
    }
    setState(() {
      product.active = next;
      if (!next) cart.remove(product.id);
    });
    await _save();
    _notice(next ? 'Barang diaktifkan.' : 'Barang dinonaktifkan.');
  }

  void _quantity(Product product, double delta) {
    setState(() {
      final next = (cart[product.id] ?? 0) + delta;
      if (next <= 0) {
        cart.remove(product.id);
      } else {
        cart[product.id] = next;
      }
    });
  }

  Future<void> _setQuantity(Product product) async {
    final ctrl = TextEditingController(
      text: quantityLabel(cart[product.id] ?? 0),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Jumlah ${product.name}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Jumlah (${product.unit})',
            hintText: 'Contoh: 1.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Hapus'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.trim().replaceAll(',', '.'));
              if (v == null || v < 0) {
                _notice('Masukkan angka yang valid.');
                return;
              }
              Navigator.pop(context, v);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null) return;
    setState(() {
      if (result <= 0) {
        cart.remove(product.id);
      } else {
        cart[product.id] = result;
      }
    });
  }

  List<SaleLine> get _cartLines => [
    for (final item in data!.products)
      if (cart.containsKey(item.id))
        SaleLine(
          productId: item.id,
          name: item.name,
          price: item.price,
          quantity: cart[item.id]!,
          unit: item.unit,
        ),
  ];
  int get _cartTotal =>
      _cartLines.fold<int>(0, (sum, item) => sum + item.total);

  static const _payMethods = ['Tunai', 'QRIS', 'Transfer'];

  Future<void> _checkout() async {
    final lines = _cartLines;
    if (lines.isEmpty) return;
    final subtotal = _cartTotal;
    final discCtrl = TextEditingController(text: '0');
    final customerCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    var credit = false;
    var method = 'Tunai';

    final result =
        await showDialog<
          ({String customer, int paid, int discount, String method})
        >(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, update) {
              int disc() => int.tryParse(discCtrl.text.trim()) ?? 0;
              int total() => subtotal - disc().clamp(0, subtotal);
              int paidAmt() =>
                  credit ? (int.tryParse(paidCtrl.text.trim()) ?? 0) : total();
              int change() => (paidAmt() - total()).clamp(0, 9999999999);

              return AlertDialog(
                title: const Text('Selesaikan transaksi'),
                content: SizedBox(
                  width: 440,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ringkasan keranjang
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${lines.length} jenis barang',
                                style: const TextStyle(color: muted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                money(subtotal),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Diskon
                        TextField(
                          controller: discCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => update(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Diskon (Rp)',
                            hintText: '0',
                            prefixIcon: Icon(Icons.discount_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Metode pembayaran
                        DropdownButtonFormField<String>(
                          initialValue: method,
                          decoration: const InputDecoration(
                            labelText: 'Metode pembayaran',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          items: [
                            for (final m in _payMethods)
                              DropdownMenuItem(value: m, child: Text(m)),
                          ],
                          onChanged: (v) => update(() => method = v ?? 'Tunai'),
                        ),
                        const SizedBox(height: 16),
                        // Lunas / Hutang
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('Lunas')),
                            ButtonSegment(value: true, label: Text('Hutang')),
                          ],
                          selected: {credit},
                          onSelectionChanged: (v) => update(() {
                            credit = v.first;
                            if (!credit) paidCtrl.clear();
                          }),
                        ),
                        if (!credit) ...[
                          const SizedBox(height: 14),
                          // Uang diterima + kembalian
                          TextField(
                            controller: paidCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => update(() {}),
                            decoration: InputDecoration(
                              labelText: 'Uang diterima (Rp)',
                              hintText: money(total()),
                              prefixIcon: const Icon(Icons.payments_outlined),
                            ),
                          ),
                          if (paidCtrl.text.isNotEmpty &&
                              (int.tryParse(paidCtrl.text.trim()) ?? 0) >=
                                  total()) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Kembalian',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  money(change()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: green,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                        if (credit) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: customerCtrl,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 80,
                            decoration: const InputDecoration(
                              labelText: 'Nama pelanggan',
                              hintText: 'Contoh: Bu Siti',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: paidCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => update(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Dibayar sekarang (Rp)',
                              hintText: '0 jika belum bayar sama sekali',
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sisa tagihan akan masuk daftar hutang.',
                            style: TextStyle(color: muted, fontSize: 13),
                          ),
                        ],
                        // Baris total akhir
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total setelah diskon',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              money(total()),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final d = disc().clamp(0, subtotal);
                      final t = subtotal - d;
                      final rawPaid = int.tryParse(paidCtrl.text.trim());
                      // Lunas: uang diterima boleh kosong (dianggap pas),
                      // yang penting >= total
                      final paidAmount = credit
                          ? (rawPaid ?? 0)
                          : (rawPaid ?? t);
                      if (credit) {
                        if (customerCtrl.text.trim().isEmpty) {
                          _notice('Isi nama pelanggan untuk transaksi hutang.');
                          return;
                        }
                        if (paidAmount < 0 || paidAmount >= t) {
                          _notice(
                            'Pembayaran awal hutang harus lebih kecil dari total.',
                          );
                          return;
                        }
                      } else {
                        if (rawPaid != null && paidAmount < t) {
                          _notice('Uang diterima kurang dari total.');
                          return;
                        }
                      }
                      Navigator.pop(context, (
                        customer: credit ? customerCtrl.text.trim() : '',
                        paid: credit ? paidAmount : t,
                        discount: d,
                        method: method,
                      ));
                    },
                    child: const Text('Simpan transaksi'),
                  ),
                ],
              );
            },
          ),
        );
    discCtrl.dispose();
    customerCtrl.dispose();
    paidCtrl.dispose();
    if (result == null) return;
    try {
      setState(() {
        data!.addSale(
          lines,
          customer: result.customer,
          paid: result.paid,
          discount: result.discount,
          method: result.method,
        );
        cart.clear();
        page = 0;
      });
      await _save();
      _notice('Transaksi tersimpan.');
    } on ArgumentError catch (e) {
      _notice(e.message?.toString() ?? 'Transaksi tidak valid.');
    }
  }

  Future<void> _pay(Sale sale) async {
    final remaining = data!.remaining(sale);
    final input = TextEditingController();
    var method = 'Tunai';
    final result = await showDialog<(int, String)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text('Bayar hutang · ${sale.customer}'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _card(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sisa tagihan',
                        style: TextStyle(color: muted),
                      ),
                      Text(
                        money(remaining),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  color: const Color(0xFFFFF7DF),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: input,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal pembayaran (Rp)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(
                    labelText: 'Metode',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                  ),
                  items: [
                    for (final m in _payMethods)
                      DropdownMenuItem(value: m, child: Text(m)),
                  ],
                  onChanged: (v) => update(() => method = v ?? 'Tunai'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(input.text.trim());
                if (value == null || value <= 0 || value > remaining) {
                  _notice(
                    'Nominal harus lebih dari Rp 0 dan tidak melebihi sisa.',
                  );
                  return;
                }
                Navigator.pop(context, (value, method));
              },
              child: const Text('Catat pembayaran'),
            ),
          ],
        ),
      ),
    );
    input.dispose();
    if (result == null) return;
    setState(() => data!.payDebt(sale, result.$1, method: result.$2));
    await _save();
    _notice('Pembayaran hutang tercatat.');
  }

  Future<void> _voidSale(Sale sale) async {
    if (data!.paymentsFor(sale) > 0) {
      _notice('Transaksi yang sudah menerima cicilan tidak bisa dibatalkan.');
      return;
    }
    final confirmed = await _confirm(
      'Batalkan transaksi ini?',
      'Transaksi tetap tersimpan sebagai arsip tapi tidak dihitung sebagai '
          'penjualan atau hutang. Tindakan ini tidak dapat diurungkan.',
      confirmLabel: 'Batalkan transaksi',
    );
    if (!confirmed) return;
    setState(() => data!.voidSale(sale));
    await _save();
    _notice('Transaksi dibatalkan.');
  }

  Future<void> _exportCsv() async {
    final csv = salesCsv(data!);
    final stamp = fileStamp(DateTime.now());
    final saved = await saveTextFile(
      fileName: 'tokoku-penjualan-$stamp.csv',
      content: csv,
      withBom: true,
    );
    if (saved) _notice('CSV berhasil disimpan.');
  }

  Future<void> _backup() async {
    final stamp = fileStamp(DateTime.now());
    final saved = await saveTextFile(
      fileName: 'tokoku-cadangan-$stamp.json',
      content: data!.encodeBackup(),
    );
    if (saved) _notice('Cadangan berhasil disimpan.');
  }

  Future<void> _restore() async {
    final confirmed = await _confirm(
      'Pulihkan data dari cadangan?',
      'Data toko saat ini akan diganti sepenuhnya dengan isi berkas cadangan. '
          'Simpan cadangan data sekarang sebelum melanjutkan.',
      confirmLabel: 'Lanjutkan',
    );
    if (!confirmed) return;
    final raw = await pickTextFile(extensions: ['json']);
    if (raw == null) return;
    try {
      final restored = StoreData.decode(raw);
      setState(() {
        data = restored;
        cart.clear();
      });
      await _save();
      _notice('Data berhasil dipulihkan dari cadangan.');
    } on FormatException catch (e) {
      _notice('Gagal membaca berkas: ${e.message}');
    } catch (_) {
      _notice('Berkas cadangan tidak valid atau rusak.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    const labels = ['Beranda', 'Barang', 'Kasir', 'Hutang', 'Riwayat'];
    const icons = [
      Icons.grid_view_rounded,
      Icons.inventory_2_outlined,
      Icons.point_of_sale_rounded,
      Icons.receipt_long_outlined,
      Icons.history_rounded,
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        toolbarHeight: 72,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'T',
                style: TextStyle(
                  color: ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOKOKU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Toko Pak Irfan',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD7E5D8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (data != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Lainnya',
              onSelected: (value) async {
                switch (value) {
                  case 'backup':
                    await _backup();
                  case 'restore':
                    await _restore();
                  case 'csv':
                    await _exportCsv();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'backup',
                  child: ListTile(
                    leading: Icon(Icons.save_outlined),
                    title: Text('Simpan cadangan'),
                    subtitle: Text('Ekspor data ke file JSON'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'restore',
                  child: ListTile(
                    leading: Icon(Icons.restore_outlined),
                    title: Text('Pulihkan cadangan'),
                    subtitle: Text('Impor dari file JSON'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'csv',
                  child: ListTile(
                    leading: Icon(Icons.table_chart_outlined),
                    title: Text('Ekspor penjualan CSV'),
                    subtitle: Text('Buka di Excel / Spreadsheet'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              height: 76,
              selectedIndex: page,
              onDestinationSelected: (index) => setState(() => page = index),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
              ],
            ),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: 210,
              child: Material(
                color: ink,
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    for (var i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          selected: page == i,
                          selectedTileColor: accent,
                          selectedColor: ink,
                          iconColor: Colors.white70,
                          textColor: Colors.white,
                          leading: Icon(icons[i]),
                          title: Text(labels[i]),
                          onTap: () => setState(() => page = i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(loadError!),
                    ),
                  )
                : data == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: _currentPage(wide),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _currentPage(bool wide) => switch (page) {
    0 => _home(wide),
    1 => _products(),
    2 => _cashier(wide),
    3 => _debts(),
    _ => _history(),
  };

  Widget _page(
    String eyebrow,
    String title,
    String subtitle,
    List<Widget> children, {
    Widget? action,
    Widget? search,
  }) {
    final header = <Widget>[
      Text(
        eyebrow.toUpperCase(),
        style: const TextStyle(
          color: green,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 7),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          ?action,
        ],
      ),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(color: muted, fontSize: 15)),
    ];

    if (search == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        children: [...header, const SizedBox(height: 26), ...children],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: header,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
          decoration: const BoxDecoration(
            color: cream,
            border: Border(bottom: BorderSide(color: line)),
          ),
          child: search,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _card(Widget child, {Color color = Colors.white}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: line),
    ),
    child: child,
  );

  Widget _empty(IconData icon, String title, String text, {Widget? action}) =>
      _card(
        Column(
          children: [
            Icon(icon, size: 42, color: green),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted),
            ),
            if (action != null) ...[const SizedBox(height: 18), action],
          ],
        ),
      );

  Widget _home(bool wide) {
    final now = DateTime.now();
    final todaySales = data!.sales.where((sale) {
      if (sale.isVoided) return false;
      final at = DateTime.parse(sale.at);
      return at.year == now.year && at.month == now.month && at.day == now.day;
    }).toList();
    final revenue = todaySales.fold<int>(0, (sum, sale) => sum + sale.total);
    final received =
        todaySales.fold<int>(0, (sum, sale) => sum + sale.paid) +
        data!.payments
            .where((payment) {
              final at = DateTime.parse(payment.at);
              return at.year == now.year &&
                  at.month == now.month &&
                  at.day == now.day;
            })
            .fold<int>(0, (sum, payment) => sum + payment.amount);
    final debt = data!.sales.fold(
      0,
      (sum, sale) => sum + data!.remaining(sale),
    );
    final activeProducts = data!.products.where((p) => p.active).length;
    return _page(
      'Catatan toko',
      'Selamat datang, Pak Irfan',
      'Harga barang, penjualan, dan hutang tersusun di satu tempat.',
      [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PENJUALAN HARI INI',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Semua transaksi hari ini',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Text(
                money(revenue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: wide ? 260 : double.infinity,
              child: _metric(
                'Uang masuk hari ini',
                money(received),
                Icons.payments_outlined,
              ),
            ),
            SizedBox(
              width: wide ? 260 : double.infinity,
              child: _metric(
                'Hutang belum lunas',
                money(debt),
                Icons.account_balance_wallet_outlined,
              ),
            ),
            SizedBox(
              width: wide ? 260 : double.infinity,
              child: _metric(
                'Barang aktif',
                '$activeProducts barang',
                Icons.inventory_2_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Mulai bekerja',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => setState(() => page = 2),
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Buka kasir'),
            ),
            OutlinedButton.icon(
              onPressed: () => _productForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah barang'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaksi terbaru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setState(() => page = 4),
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        if (data!.sales.isEmpty)
          _empty(
            Icons.receipt_long_outlined,
            'Belum ada transaksi',
            'Tambahkan barang, lalu catat penjualan pertama di Kasir.',
          )
        else
          ...data!.sales.reversed
              .where((s) => !s.isVoided)
              .take(4)
              .map(_saleTile),
      ],
    );
  }

  Widget _metric(String label, String value, IconData icon) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: green),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: muted)),
      ],
    ),
  );

  Widget _products() {
    final all = data!.products.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final filtered = all
        .where(
          (item) =>
              (showInactive || item.active) &&
              item.name.toLowerCase().contains(query),
        )
        .toList();
    final hasInactive = all.any((p) => !p.active);
    return _page(
      'Daftar harga',
      'Barang dagangan',
      'Lihat, ubah harga, dan kelola barang aktif.',
      [
        if (data!.products.isEmpty)
          _empty(
            Icons.inventory_2_outlined,
            'Belum ada barang',
            'Masukkan nama dan harga barang yang dijual.',
            action: FilledButton.icon(
              onPressed: () => _productForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah barang'),
            ),
          )
        else if (filtered.isEmpty)
          _empty(
            Icons.search_off,
            'Barang tidak ditemukan',
            'Coba kata pencarian lain atau aktifkan tampilkan nonaktif.',
          )
        else
          ...filtered.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Opacity(
                opacity: item.active ? 1.0 : 0.55,
                child: _card(
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: item.active ? cream : line,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: item.active ? green : muted,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: item.active
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      '${money(item.price)} / ${item.unit}'
                      '${item.active ? '' : ' · Nonaktif'}',
                      style: TextStyle(
                        color: item.active ? muted : muted.withAlpha(160),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: item.active ? 'Nonaktifkan' : 'Aktifkan',
                          icon: Icon(
                            item.active
                                ? Icons.toggle_on_outlined
                                : Icons.toggle_off_outlined,
                            color: item.active ? green : muted,
                          ),
                          onPressed: () => _toggleProduct(item),
                        ),
                        IconButton(
                          tooltip: 'Ubah',
                          icon: const Icon(Icons.edit_outlined, color: green),
                          onPressed: () => _productForm(item),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
      action: FilledButton.icon(
        onPressed: () => _productForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah barang'),
      ),
      search: Row(
        children: [
          Expanded(
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari nama barang',
                suffixIcon: search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Bersihkan pencarian',
                        onPressed: search.clear,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          if (hasInactive) ...[
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Nonaktif'),
              selected: showInactive,
              onSelected: (v) => setState(() => showInactive = v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cashier(bool wide) {
    final allProducts = data!.products.where((p) => p.active).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final products = allProducts
        .where((p) => p.name.toLowerCase().contains(cashierQuery))
        .toList();
    final catalog = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pilih barang',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (allProducts.isEmpty)
          _empty(
            Icons.inventory_2_outlined,
            'Belum ada barang aktif',
            'Tambah barang dan harga sebelum mencatat transaksi.',
            action: FilledButton(
              onPressed: () => setState(() => page = 1),
              child: const Text('Ke halaman Barang'),
            ),
          )
        else if (products.isEmpty)
          _empty(
            Icons.search_off,
            'Barang tidak ditemukan',
            'Coba kata pencarian lain.',
          )
        else
          ...products.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _card(
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${money(item.price)} / ${item.unit}',
                            style: const TextStyle(color: muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kurangi ${item.name}',
                      onPressed: (cart[item.id] ?? 0) > 0
                          ? () => _quantity(item, -1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    GestureDetector(
                      onTap: () => _setQuantity(item),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 36),
                        alignment: Alignment.center,
                        child: Text(
                          quantityLabel(cart[item.id] ?? 0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tambah ${item.name}',
                      onPressed: () => _quantity(item, 1),
                      icon: const Icon(Icons.add_circle, color: green),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
    final summary = _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Keranjang',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (cart.isEmpty)
            const Text(
              'Belum ada barang dipilih.',
              style: TextStyle(color: muted),
            )
          else
            ..._cartLines.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${quantityLabel(item.quantity)} ${item.unit} × ${item.name}',
                      ),
                    ),
                    Text(
                      money(item.total),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                money(_cartTotal),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: cart.isEmpty ? null : _checkout,
            child: const Text('Selesaikan transaksi'),
          ),
          if (cart.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => setState(() => cart.clear()),
              child: const Text('Kosongkan keranjang'),
            ),
          ],
        ],
      ),
    );
    return _page(
      'Penjualan',
      'Kasir',
      'Pilih barang, tentukan jumlah, lalu simpan pembayaran.',
      [
        wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: catalog),
                  const SizedBox(width: 18),
                  Expanded(child: summary),
                ],
              )
            : Column(children: [catalog, const SizedBox(height: 14), summary]),
      ],
      search: TextField(
        controller: cashierSearch,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Cari barang untuk dijual',
          suffixIcon: cashierSearch.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Bersihkan pencarian',
                  onPressed: cashierSearch.clear,
                  icon: const Icon(Icons.close),
                ),
        ),
      ),
    );
  }

  Widget _debts() {
    final allDue = data!.sales
        .where((sale) => data!.remaining(sale) > 0)
        .toList()
        .reversed
        .toList();

    // Kelompokkan per pelanggan
    final Map<String, List<Sale>> byCustomer = {};
    for (final sale in allDue) {
      final name = sale.customer.isEmpty ? '(tanpa nama)' : sale.customer;
      byCustomer.putIfAbsent(name, () => []).add(sale);
    }

    final filteredCustomers =
        byCustomer.entries
            .where(
              (entry) =>
                  debtQuery.isEmpty ||
                  entry.key.toLowerCase().contains(debtQuery),
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final total = allDue.fold<int>(
      0,
      (sum, sale) => sum + data!.remaining(sale),
    );

    return _page(
      'Catatan pelanggan',
      'Hutang',
      'Setiap pembayaran mengurangi sisa tagihan.',
      [
        _card(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total belum lunas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${byCustomer.length} pelanggan · ${allDue.length} transaksi',
                    style: const TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
              Text(
                money(total),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          color: const Color(0xFFFFF7DF),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: debtSearch,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Cari nama pelanggan',
          ),
        ),
        const SizedBox(height: 18),
        if (allDue.isEmpty)
          _empty(
            Icons.check_circle_outline,
            'Tidak ada hutang aktif',
            'Transaksi hutang akan muncul di sini.',
          )
        else if (filteredCustomers.isEmpty)
          _empty(
            Icons.search_off,
            'Pelanggan tidak ditemukan',
            'Coba kata pencarian lain.',
          )
        else
          ...filteredCustomers.map((entry) {
            final customerName = entry.key;
            final sales = entry.value;
            final customerTotal = sales.fold<int>(
              0,
              (sum, sale) => sum + data!.remaining(sale),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header pelanggan
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: cream,
                          child: Icon(Icons.person_outline, color: green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${sales.length} transaksi belum lunas',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          money(customerTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22),
                    // Daftar transaksi milik pelanggan ini
                    ...sales.map(
                      (sale) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _date(sale.at),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Sisa ${money(data!.remaining(sale))}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total ${money(sale.total)} · Dibayar ${money(data!.paidFor(sale))} · ${sale.method}',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                ),
                              ),
                              // Riwayat cicilan
                              ...data!.payments
                                  .where((p) => p.saleId == sale.id)
                                  .map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            size: 14,
                                            color: green,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_date(p.at)} ${money(p.amount)} (${p.method})',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () => _pay(sale),
                                icon: const Icon(
                                  Icons.payments_outlined,
                                  size: 18,
                                ),
                                label: const Text('Catat pembayaran'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _history() => _page(
    'Arsip penjualan',
    'Riwayat transaksi',
    'Harga di sini adalah harga saat transaksi disimpan.',
    [
      if (data!.sales.isEmpty)
        _empty(
          Icons.receipt_long_outlined,
          'Belum ada transaksi',
          'Transaksi yang disimpan di Kasir akan muncul di sini.',
        )
      else
        ...data!.sales.reversed.map(_saleTile),
    ],
  );

  Widget _saleTile(Sale sale) {
    final isVoid = sale.isVoided;
    final statusText = isVoid
        ? 'Dibatalkan'
        : sale.customer.isEmpty
        ? 'Lunas'
        : data!.remaining(sale) == 0
        ? '${sale.customer} · Lunas'
        : '${sale.customer} · Sisa ${money(data!.remaining(sale))}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: isVoid ? 0.5 : 1.0,
        child: _card(
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_date(sale.at)} · ${money(sale.total)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isVoid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (!isVoid && sale.method.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sale.method,
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              statusText,
              style: TextStyle(
                color: isVoid ? muted : null,
                fontStyle: isVoid ? FontStyle.italic : null,
              ),
            ),
            children: [
              for (final item in sale.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${quantityLabel(item.quantity)} ${item.unit} × ${item.name} @ ${money(item.price)}',
                        ),
                      ),
                      Text(money(item.total)),
                    ],
                  ),
                ),
              if (sale.discount > 0) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text(money(sale.subtotal)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Diskon', style: TextStyle(color: muted)),
                    Text(
                      '- ${money(sale.discount)}',
                      style: const TextStyle(color: muted),
                    ),
                  ],
                ),
              ],
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text(
                    money(sale.total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dibayar ${money(data!.paidFor(sale))}',
                  style: const TextStyle(color: muted),
                ),
              ),
              if (!isVoid &&
                  data!.paymentsFor(sale) == 0 &&
                  data!.remaining(sale) > 0) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _voidSale(sale),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Batalkan transaksi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _date(String value) {
    final date = DateTime.parse(value);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
