import 'dart:typed_data';

class ApiResponse {
  final int code;
  final String message;
  String content;
  final Map<String, String>? headers;
  final Uint8List? bytes;

  ApiResponse(
      {required this.code,
      this.message = "",
      this.content = "",
      this.headers,
      this.bytes});

  bool get isSuccess => code >= 200 && code < 300;

  @override
  String toString() {
    return "ApiResponse => Status: $code, Message: $message";
  }
}
