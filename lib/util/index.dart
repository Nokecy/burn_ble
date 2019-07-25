import 'dart:convert' show Utf8Encoder;

List<int> stringToHex(String hexString) {
  hexString = hexString.toUpperCase();
  var bytes = new List<int>((hexString.length / 2).toInt());

  for (int i = 0; i < hexString.length; i++) {
    int pos = i * 2;
    if (i < bytes.length) {
      bytes[i] = int.parse(hexString[pos] + hexString[pos + 1], radix: 16);
    }
  }
  return bytes;
}
