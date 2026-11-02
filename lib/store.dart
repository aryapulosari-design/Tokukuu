import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

/// Kunci penyimpanan lokal. Jangan diubah agar data toko yang sudah ada tetap
/// terbaca setelah pembaruan aplikasi.
const storageKey = 'toko_pak_irfan_v1';

/// Satuan yang paling sering dipakai toko sembako. Satuan lain tetap dibaca
/// dari data lama karena disimpan sebagai teks.
const productUnits = [
  'pcs',
  'kg',
  'gram',
  'liter',
  'ml',
  'pack',
  'dus',
  'ikat',
  'buah',
  'botol',
  'sachet',
  'bungkus',
];

String money(int value) {
  final digits = value.abs().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    groups.insert(0, digits.substring(end - 3 < 0 ? 0 : end - 3, end));
  }
  return '${value < 0 ? '-' : ''}Rp ${groups.join('.')}';
}

/// Menampilkan jumlah tanpa nol di belakang koma: 1.0 -> "1", 1.5 -> "1.5".
String quantityLabel(double value) {
  if (!value.isFinite) return '0';
  if (value == value.roundToDouble()) return value.toInt().toString();
  var text = value.toStringAsFixed(3);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  text = text.replaceFirst(RegExp(r'\.$'), '');
  return text;
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    this.unit = 'pcs',
    this.active = true,
  });
  final String id;
  String name;
  int price;
  String unit;
  bool active;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'unit': unit,
    'active': active,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toInt(),
    unit: json['unit'] as String? ?? 'pcs',
    active: json['active'] as bool? ?? true,
  );
}

/// Contoh barang bawaan untuk toko baru. Harga mengikuti kisaran harga
/// warung/sembako dan bisa langsung diubah lewat menu Barang.
List<Product> sampleProducts() => [
  Product(
    id: 'contoh-beras-premium-5kg',
    name: 'Beras Premium 5 kg',
    price: 78000,
    unit: 'pack',
  ),
  Product(
    id: 'contoh-minyak-goreng-1l',
    name: 'Minyak Goreng 1 L',
    price: 18000,
    unit: 'botol',
  ),
  Product(
    id: 'contoh-gula-pasir-1kg',
    name: 'Gula Pasir 1 kg',
    price: 17000,
    unit: 'kg',
  ),
  Product(
    id: 'contoh-telur-ayam-1kg',
    name: 'Telur Ayam 1 kg',
    price: 30000,
    unit: 'kg',
  ),
  Product(
    id: 'contoh-tepung-terigu-1kg',
    name: 'Tepung Terigu 1 kg',
    price: 12000,
    unit: 'kg',
  ),
  Product(
    id: 'contoh-mie-instan',
    name: 'Mie Instan Goreng',
    price: 3500,
    unit: 'pcs',
  ),
  Product(
    id: 'contoh-air-mineral-600ml',
    name: 'Air Mineral 600 ml',
    price: 4000,
    unit: 'botol',
  ),
  Product(
    id: 'contoh-kopi-sachet',
    name: 'Kopi Sachet',
    price: 1500,
    unit: 'sachet',
  ),
  Product(
    id: 'contoh-kecap-manis-135ml',
    name: 'Kecap Manis 135 ml',
    price: 5500,
    unit: 'botol',
  ),
  Product(
    id: 'contoh-garam-halus-500g',
    name: 'Garam Halus 500 g',
    price: 5000,
    unit: 'bungkus',
  ),
  Product(
    id: 'contoh-sabun-mandi',
    name: 'Sabun Mandi',
    price: 4500,
    unit: 'pcs',
  ),
  Product(
    id: 'contoh-deterjen-800g',
    name: 'Deterjen Bubuk 800 g',
    price: 18000,
    unit: 'bungkus',
  ),
];

class SaleLine {
  SaleLine({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.unit = 'pcs',
  });
  final String productId, name, unit;

  /// Harga satuan saat transaksi terjadi, bukan harga barang saat ini.
  final int price;
  final double quantity;

  int get total => (price * quantity).round();

  Map<String, Object?> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'unit': unit,
  };

  factory SaleLine.fromJson(Map<String, dynamic> json) => SaleLine(
    productId: json['productId'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toInt(),
    quantity: (json['quantity'] as num).toDouble(),
    unit: json['unit'] as String? ?? 'pcs',
  );
}

class Sale {
  Sale({
    required this.id,
    required this.at,
    required this.lines,
    required this.customer,
    required this.paid,
    this.discount = 0,
    this.method = 'Tunai',
    this.voidedAt,
  });
  final String id, at;
  final List<SaleLine> lines;
  String customer;

  /// Pembayaran awal saat transaksi dibuat.
  int paid;
  int discount;
  String method;

  /// Diisi saat transaksi dibatalkan. Transaksi batal tetap tersimpan sebagai
  /// arsip, tetapi tidak dihitung sebagai penjualan, uang masuk, atau hutang.
  String? voidedAt;

  bool get isVoided => voidedAt != null;

  int get subtotal => lines.fold(0, (sum, line) => sum + line.total);
  int get total => math.max(0, subtotal - discount);

  Map<String, Object?> toJson() => {
    'id': id,
    'at': at,
    'lines': lines.map((line) => line.toJson()).toList(),
    'customer': customer,
    'paid': paid,
    'discount': discount,
    'method': method,
    'voidedAt': voidedAt,
  };

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    id: json['id'] as String,
    at: json['at'] as String,
    lines: (json['lines'] as List)
        .map((line) => SaleLine.fromJson(line as Map<String, dynamic>))
        .toList(),
    customer: json['customer'] as String? ?? '',
    paid: (json['paid'] as num).toInt(),
    discount: (json['discount'] as num?)?.toInt() ?? 0,
    method: json['method'] as String? ?? 'Tunai',
    voidedAt: json['voidedAt'] as String?,
  );
}

class DebtPayment {
  DebtPayment({
    required this.id,
    required this.saleId,
    required this.at,
    required this.amount,
    this.method = 'Tunai',
  });
  final String id, saleId, at;
  final int amount;
  final String method;

  Map<String, Object?> toJson() => {
    'id': id,
    'saleId': saleId,
    'at': at,
    'amount': amount,
    'method': method,
  };

  factory DebtPayment.fromJson(Map<String, dynamic> json) => DebtPayment(
    id: json['id'] as String,
    saleId: json['saleId'] as String,
    at: json['at'] as String,
    amount: (json['amount'] as num).toInt(),
    method: json['method'] as String? ?? 'Tunai',
  );
}

class StoreData {
  StoreData({
    List<Product>? products,
    List<Sale>? sales,
    List<DebtPayment>? payments,
  }) : products = products ?? [],
       sales = sales ?? [],
       payments = payments ?? [];

  final List<Product> products;
  final List<Sale> sales;
  final List<DebtPayment> payments;

  Map<String, Object?> toJson() => {
    'version': 2,
    'products': products.map((item) => item.toJson()).toList(),
    'sales': sales.map((item) => item.toJson()).toList(),
    'payments': payments.map((item) => item.toJson()).toList(),
  };

  String encode() => jsonEncode(toJson());

  String encodeBackup() => jsonEncode({
    'app': 'tokokuu',
    'format': 2,
    'exportedAt': DateTime.now().toIso8601String(),
    'data': toJson(),
  });

  static Future<StoreData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return StoreData();
    return decode(raw);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, encode());
  }

  static StoreData decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Isi berkas bukan objek JSON.');
    }
    final wrapped = decoded['data'];
    final source = wrapped is Map<String, dynamic> ? wrapped : decoded;
    if (source['products'] is! List &&
        source['sales'] is! List &&
        source['payments'] is! List) {
      throw const FormatException('Berkas bukan cadangan Tokoku.');
    }
    return StoreData.fromJson(source);
  }

  factory StoreData.fromJson(Map<String, dynamic> json) => StoreData(
    products: (json['products'] as List? ?? const [])
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList(),
    sales: (json['sales'] as List? ?? const [])
        .map((item) => Sale.fromJson(item as Map<String, dynamic>))
        .toList(),
    payments: (json['payments'] as List? ?? const [])
        .map((item) => DebtPayment.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  int paymentsFor(Sale sale) => payments
      .where((payment) => payment.saleId == sale.id)
      .fold(0, (sum, payment) => sum + payment.amount);

  int paidFor(Sale sale) => sale.paid + paymentsFor(sale);

  int remaining(Sale sale) =>
      sale.isVoided ? 0 : math.max(0, sale.total - paidFor(sale));

  Sale addSale(
    List<SaleLine> lines, {
    required String customer,
    required int paid,
    int discount = 0,
    String method = 'Tunai',
    DateTime? at,
  }) {
    if (lines.isEmpty ||
        lines.any(
          (line) =>
              !line.quantity.isFinite || line.quantity <= 0 || line.price < 0,
        )) {
      throw ArgumentError('Keranjang tidak valid');
    }
    final moment = at ?? DateTime.now();
    final sale = Sale(
      id: moment.microsecondsSinceEpoch.toString(),
      at: moment.toIso8601String(),
      lines: List.of(lines),
      customer: customer.trim(),
      paid: paid,
      discount: discount,
      method: method,
    );
    _validateSale(sale, paid, 0);
    sales.add(sale);
    return sale;
  }

  void updateSale(
    Sale sale, {
    required String customer,
    required int paid,
    required int discount,
    required String method,
  }) {
    if (sale.isVoided) {
      throw ArgumentError('Transaksi sudah dibatalkan');
    }
    final extraPaid = paymentsFor(sale);
    final draft = Sale(
      id: sale.id,
      at: sale.at,
      lines: sale.lines,
      customer: customer.trim(),
      paid: paid,
      discount: discount,
      method: method,
      voidedAt: sale.voidedAt,
    );
    _validateSale(draft, paid, extraPaid);
    sale.customer = draft.customer;
    sale.paid = paid;
    sale.discount = discount;
    sale.method = method;
  }

  void _validateSale(Sale sale, int initialPaid, int extraPaid) {
    if (sale.discount < 0 || sale.discount > sale.subtotal) {
      throw ArgumentError('Diskon tidak valid');
    }
    final paid = initialPaid + extraPaid;
    if (initialPaid < 0 || paid > sale.total) {
      throw ArgumentError('Pembayaran atau nama pelanggan tidak valid');
    }
    if (paid < sale.total && sale.customer.isEmpty) {
      throw ArgumentError('Pembayaran atau nama pelanggan tidak valid');
    }
    if (sale.method.trim().isEmpty) {
      throw ArgumentError('Metode pembayaran tidak valid');
    }
  }

  void payDebt(Sale sale, int amount, {String method = 'Tunai'}) {
    if (sale.isVoided) {
      throw ArgumentError('Transaksi sudah dibatalkan');
    }
    if (amount <= 0 || amount > remaining(sale)) {
      throw ArgumentError('Nominal pembayaran tidak valid');
    }
    if (method.trim().isEmpty) {
      throw ArgumentError('Metode pembayaran tidak valid');
    }
    final now = DateTime.now();
    payments.add(
      DebtPayment(
        id: now.microsecondsSinceEpoch.toString(),
        saleId: sale.id,
        at: now.toIso8601String(),
        amount: amount,
        method: method,
      ),
    );
  }

  void voidSale(Sale sale) {
    if (sale.isVoided) {
      throw ArgumentError('Transaksi sudah dibatalkan');
    }
    if (paymentsFor(sale) > 0) {
      throw ArgumentError(
        'Transaksi yang sudah menerima pembayaran tidak bisa dibatalkan',
      );
    }
    sale.voidedAt = DateTime.now().toIso8601String();
  }
}
