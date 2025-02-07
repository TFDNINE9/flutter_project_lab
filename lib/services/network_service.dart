import 'package:flutter_project_lab/configurations/constants/const.dart';
import 'package:flutter_project_lab/models/api_response.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  Future<ApiResponse> get(String path) async {
    var uri = Uri(host: apiHost, path: path, scheme: 'https');
    var response = await http.get(uri);

    return ApiResponse(code: response.statusCode, content: response.body);
  }

  Future<ApiResponse> postJson(String path, String json) async {
    var uri = Uri(host: apiHost, path: path, scheme: 'https');
    var headers = {"Content-Type": "application/json"};
    var res = await http.post(
      uri,
      body: json,
      headers: headers,
    );
    return ApiResponse(
      code: res.statusCode,
      content: res.body,
    );
  }

  Future<ApiResponse> putJson(String path, String json) async {
    var uri = Uri(host: apiHost, path: path, scheme: 'https');
    var headers = {"Content-Type": "application/json"};
    var res = await http.put(
      uri,
      body: json,
      headers: headers,
    );
    return ApiResponse(
      code: res.statusCode,
      content: res.body,
    );
  }

  Future<ApiResponse> delete(String path) async {
    var uri = Uri(host: apiHost, path: path, scheme: 'https');
    var response = await http.delete(uri);
    var apiResponse = ApiResponse(
      code: response.statusCode,
    );

    return apiResponse;
  }
}
