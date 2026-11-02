import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Menyimpan teks ke berkas lokal yang dipilih pengguna. Tidak memakai
/// jaringan: berkas ditulis langsung oleh dialog simpan bawaan perangkat.
///
/// Mengembalikan `true` bila pengguna benar-benar menyimpan berkas.
Future<bool> saveTextFile({
  required String fileName,
  required String content,
  bool withBom = false,
}) async {
  final bytes = Uint8List.fromList([
    if (withBom) ...const [0xEF, 0xBB, 0xBF],
    ...utf8.encode(content),
  ]);
  final uri = await FilePicker.saveFile(
    dialogTitle: 'Pilih lokasi simpan',
    fileName: fileName,
    bytes: bytes,
    mimeType: withBom ? 'text/csv' : 'application/json',
  );
  return uri != null;
}

/// Membuka berkas teks lokal pilihan pengguna. Tidak mengunggah apa pun.
Future<String?> pickTextFile({List<String> extensions = const ['json']}) async {
  final file = await FilePicker.pickFile(
    dialogTitle: 'Pilih berkas',
    type: FileType.custom,
    allowedExtensions: extensions,
  );
  if (file == null) return null;
  return utf8.decode(await file.readAsBytes());
}

String fileStamp(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}${two(value.month)}${two(value.day)}-'
      '${two(value.hour)}${two(value.minute)}';
}
