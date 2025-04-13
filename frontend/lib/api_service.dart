import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 
import 'dart:convert';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8080/api/firebase";  // 用於 Web
    } else {
      return "http://10.0.2.2:8080/api/firebase";  
    }
  }

  Future<List<Map<String, dynamic>>> getPlanByDate(DateTime date)async{
    final formattedDate = "${date.toLocal().toString().split(' ')[0]}";
    final response = await http.get(Uri.parse('$baseUrl/date/$formattedDate'));

    if(response.statusCode == 200){
      final decodedBody = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(json.decode(decodedBody));
    }else{
      throw Exception('Failed to load plans by date');
    }
  }

  Future<void> addPlan(Map<String, dynamic> plan)async{
    final response = await http.post(
      Uri.parse('$baseUrl/plans/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(plan),
    );

    if(response.statusCode != 200){
      throw Exception(response.body);
    }
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> updates)async{
    final response = await http.put(
      Uri.parse('$baseUrl/plans/update/$planId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if(response.statusCode != 200){
      throw Exception(response.body);
    }
  }

  Future<void> deletePlan(String id)async{
    final response  = await http.delete(Uri.parse('$baseUrl/$id'));

    if(response.statusCode != 200){
      throw Exception('Failed to delete plan');
    }
  }

  /* 暫未使用到
  Future<List<Map<String, dynamic>>> getAllPlans()async{
    final response = await http.get(Uri.parse(baseUrl));
    if(response.statusCode == 200){
      return List<Map<String, dynamic>>.from(json.decode(response.body)); 
    }else{
      throw Exception('Failed to load all plans');
    }
  } 

  Future<Map<String, dynamic>> getPlanById(String id) async{
    final response = await http.get(Uri.parse('$baseUrl/id/$id'));

    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      throw Exception('Failed to load plan by ID');
    }
  }
  */
}