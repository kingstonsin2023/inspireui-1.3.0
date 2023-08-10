import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../base/common_library.dart';
import '../utils.dart';
import '../utils/secure_storage.dart';

/// enable network proxy
const debugNetworkProxy = false;

class HttpBase extends http.BaseClient {
  final http.Client _client = http.Client();
  HttpBase();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    initProxyClient(request.url);
    return _client.send(request);
  }
}

/// The default http GET that support Logging
Future<http.Response> httpGet(
  Uri url, {
  Map<String, String>? headers,
  bool enableDio = false,
  String kWebProxy = '',
}) async {
  final startTime = DateTime.now();
  initProxyClient(url);
  if (enableDio) {
    try {
      final res = await Dio().get(url.toString(), options: Options(headers: headers, responseType: ResponseType.plain));
      printLog('GET:$url', startTime);
      final response = http.Response(res.toString(), res.statusCode!);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        final response = http.Response(e.response.toString(), e.response!.statusCode!);
        return response;
      } else {
        // ignore: only_throw_errors
        throw e.message;
      }
    }
  } else {
    // ignore: prefer_typing_uninitialized_variables
    var response;
    var uri = url;
    if (foundation.kIsWeb) {
      final proxyURL = '$url';
      uri = Uri.parse(proxyURL);
    }

    response = await http.get(uri, headers: headers);
    printLog('♻️ GET:$url', startTime);

    return response;
  }
}

/// The default http POST that support Logging
Future<http.Response> httpPost(Uri url, {Map<String, String>? headers, Object? body, bool enableDio = false}) async {
  final startTime = DateTime.now();
  initProxyClient(url);
  if (enableDio) {
    try {
      final res = await Dio().post(url.toString(), options: Options(headers: headers, responseType: ResponseType.plain), data: body);
      printLog('🔼 POST:$url', startTime);
      final response = http.Response(res.toString(), res.statusCode!);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        final response = http.Response(e.response.toString(), e.response!.statusCode!);
        return response;
      } else {
        // ignore: only_throw_errors
        throw e.message;
      }
    }
  } else {
    final response = await http.post(url, headers: headers, body: body);
    printLog('🔼 POST:$url', startTime);
    return response;
  }
}

/// The default http PUT that support Logging
Future<http.Response> httpPut(Uri url, {Map<String, String>? headers, Object? body, bool enableDio = false}) async {
  final startTime = DateTime.now();
  initProxyClient(url);
  if (enableDio) {
    try {
      final res = await Dio().put(url.toString(), options: Options(headers: headers, responseType: ResponseType.plain), data: body);
      printLog('🔼 PUT:$url', startTime);
      final response = http.Response(res.toString(), res.statusCode!);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        final response = http.Response(e.response.toString(), e.response!.statusCode!);
        return response;
      } else {
        // ignore: only_throw_errors
        throw e.message;
      }
    }
  } else {
    final response = await http.put(url, headers: headers, body: body);
    printLog('🔼 PUT:$url', startTime);
    return response;
  }
}

/// The default http PUT that support Logging
Future<http.Response> httpDelete(Uri url, {Map<String, String>? headers, Object? body, bool enableDio = false}) async {
  final startTime = DateTime.now();
  initProxyClient(url);
  if (enableDio) {
    try {
      final res = await Dio().delete(url.toString(), options: Options(headers: headers, responseType: ResponseType.plain), data: body);
      printLog('DELETE:$url', startTime);
      final response = http.Response(res.toString(), res.statusCode!);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        final response = http.Response(e.response.toString(), e.response!.statusCode!);
        return response;
      } else {
        // ignore: only_throw_errors
        throw e.message;
      }
    }
  } else {
    final response = await http.delete(url, headers: headers, body: body);
    printLog('DELETE:$url', startTime);
    return response;
  }
}

/// The default http PATCH that support Logging
Future<http.Response> httpPatch(Uri url, {Map<String, String>? headers, Object? body, bool enableDio = false}) async {
  final startTime = DateTime.now();
  initProxyClient(url);
  if (enableDio) {
    try {
      final res = await Dio().patch(url.toString(), options: Options(headers: headers, responseType: ResponseType.plain), data: body);
      printLog('PATCH:$url', startTime);
      final response = http.Response(res.toString(), res.statusCode!);
      return response;
    } on DioError catch (e) {
      if (e.response != null) {
        final response = http.Response(e.response.toString(), e.response!.statusCode!);
        return response;
      } else {
        // ignore: only_throw_errors
        throw e.message;
      }
    }
  } else {
    final response = await http.patch(url, headers: headers, body: body);
    printLog('PATCH:$url', startTime);
    return response;
  }
}

void initProxyClient(Uri url) {
  return;
}

String _combineUrl(proxyUrl, httpClient) {
  return '$proxyUrl$httpClient';
}

void _handleError() {
  final msg = EncodeUtils.decode(
    'Cgp8IHwgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0gfCB8CnwgfCDimqDvuI8gUGxlYXNlIHByb3ZpZGUgeW91ciBwdXJjaGFzZSBjb2RlIGluIGNvbmZpZ3MvZW52LnByb3BlcnRpZXMgfCB8CnwgfCA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PSB8IHwKCg==',
  );
  throw ProxyException(msg);
}

class ProxyException implements Exception {
  final String message;

  ProxyException(this.message);
}
