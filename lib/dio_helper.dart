import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:dio/dio.dart';

class DioHelper {
  static late Dio _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio();
    }
    return _dio;
  }

  static Future<String> getMaxId() async {
    const url = 'http://www.optimaljo.com/optimaluploader.asmx';
    const requestBody = '''
      <?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <getMax_id xmlns="http://www.optimaljo.com/">
            <password>OptimalPass</password>
            <TableName>Table_Test</TableName>
          </getMax_id>
        </soap:Body>
      </soap:Envelope>
    ''';

    try {
      final response = await dio.post(
        url,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': 'http://www.optimaljo.com/getMax_id',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        // Parse the XML response and extract the value of the getMax_idResult element
        final startIndex = responseBody.indexOf('<getMax_idResult>') +
            '<getMax_idResult>'.length;
        final endIndex = responseBody.indexOf('</getMax_idResult>');
        final result = responseBody.substring(startIndex, endIndex);
        return result;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  static init() {
    _dio = Dio(BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        receiveDataWhenStatusError: true));
  }

  static Future<Response> getData(
      {required String url, required Map<String, dynamic> query}) async {
    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> x() async {
    // Create the XML request body
    const requestBody = '''
    <?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <getMax_id xmlns="http://tempuri.org/">
          <op>getMax_id</op>
          <password>OptimalPass</password>
          <TableName>Table_Test</TableName>
        </getMax_id>
      </soap:Body>
    </soap:Envelope>
  ''';
    /*http://www.optimaljo.com/optimaluploader.asmx
op :   getMax_id
password : " OptimalPass"
TableName : "Table_Test"
 */

    // Set the request headers
    final headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'http://tempuri.org/getMax_id',
    };

    // Make the request
    return await dio.get(
      'http://www.optimaljo.com/optimaluploader.asmx',
      data: requestBody,
      options: Options(headers: headers),
    );
  }

  static Future<Response> xx() async {
    const String baseUrl = 'https://www.kanf.org.kw/kanfwebservice.asmx';
    final Dio dio = Dio();

    // Create the SOAP envelope with the required parameters
    String envelope = '''
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:xsd="http://www.w3.org/2001/XMLSchema"
          xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <GetDonation xmlns="http://tempuri.org/">
              <ID>${1.toString()}</ID>
            </GetDonation>
          </soap:Body>
        </soap:Envelope>
      ''';

    // Set the headers
    Map<String, String> headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'http://tempuri.org/GetDonation',
    };

    // Make the request
    return await dio.post(
      baseUrl,
      data: envelope,
      options: Options(
        headers: headers,
      ),
    );

    // Parse the response
  }
}
