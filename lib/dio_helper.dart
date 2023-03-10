import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

class DioHelper {
  static late Dio dio;

  static init() {
    dio = Dio(BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        receiveDataWhenStatusError: true));
  }

  static Future<Response> getData(
      {required String url, required Map<String, dynamic> query}) async {
    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> postData() async {
    return await dio.post('https://jsonplaceholder.typicode.com/posts',
        data: {'title': 'foo', 'body': 'bar', 'userId': 1});
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

    // Set the request headers
    final headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'http://tempuri.org/getMax_id',
    };

    // Make the request
    return await dio.post(
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
