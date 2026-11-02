import 'store.dart';

/// Membuat CSV penjualan (satu baris per barang). Pemisah memakai titik koma
/// agar cocok dibuka di Excel dengan pengaturan Indonesia.
///
/// Kolom tingkat transaksi hanya diisi pada baris pertama setiap transaksi,
/// sehingga penjumlahan kolom "Total Transaksi" tidak terhitung berulang.
String salesCsv(StoreData data) {
  final buffer = StringBuffer();
  const headers = [
    'Tanggal',
    'Jam',
    'ID Transaksi',
    'Pelanggan',
    'Metode',
    'Status',
    'Barang',
    'Jumlah',
    'Satuan',
    'Harga Satuan',
    'Subtotal Baris',
    'Diskon',
    'Total Transaksi',
    'Total Dibayar',
    'Sisa',
  ];
  buffer.writeln(headers.map(_cell).join(';'));

  for (final sale in data.sales) {
    final at = DateTime.parse(sale.at);
    final status = sale.isVoided
        ? 'Dibatalkan'
        : data.remaining(sale) > 0
        ? 'Hutang'
        : 'Lunas';
    final saleColumns = [
      _date(at),
      _time(at),
      sale.id,
      sale.customer.isEmpty ? '-' : sale.customer,
      sale.method,
      status,
    ];
    for (var index = 0; index < sale.lines.length; index++) {
      final line = sale.lines[index];
      final row = <String>[
        ...saleColumns,
        line.name,
        quantityLabel(line.quantity),
        line.unit,
        line.price.toString(),
        line.total.toString(),
        if (index == 0)
          ...[
            sale.discount.toString(),
            sale.total.toString(),
            data.paidFor(sale).toString(),
            data.remaining(sale).toString(),
          ]
        else
          ...const ['', '', '', ''],
      ];
      buffer.writeln(row.map(_cell).join(';'));
    }
  }
  return buffer.toString();
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _cell(String value) {
  if (value.contains(';') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
