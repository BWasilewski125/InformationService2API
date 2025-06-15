import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as storage;
import 'package:intl/intl.dart';
import 'package:rsi_rest/services/AccountService.dart';
import '../constants/Constants.dart';
import '../models/EventDTO.dart';
import '../models/event.dart';

class EventService {
  final String baseUrl = Constants.baseUrl;

  Future<List<Event>> getEvents() async {
    final uri = Uri.parse('$baseUrl/api/events');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events (${response.statusCode})');
    }
  }


  Future<List<Event>> getEventsByDay(DateTime day) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(day);
    final url = Uri.parse('$baseUrl/api/events/date/$formattedDate');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => Event.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
  }

  Future<List<Event>> getEventsByWeek(int weekNumber) async {
    final uri = Uri.parse('$baseUrl/api/events/week/$weekNumber');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load events for week $weekNumber '
            '(status code: ${response.statusCode})',
      );
    }
  }

  Future<Event> getEvent(int id) async {
    final uri = Uri.parse('$baseUrl/api/events/$id');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap =
      json.decode(response.body) as Map<String, dynamic>;
      return Event.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to load event with id $id '
            '(status code: ${response.statusCode})',
      );
    }
  }

  Future<Event> addEvent(Event event) async {
    final uri = Uri.parse('$baseUrl/api/events');

    final payload = {
      'name':        event.name,
      'type':        event.type,
      'date':        event.date.toIso8601String(),
      'description': event.description,
    };

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonMap =
      json.decode(response.body) as Map<String, dynamic>;
      return Event.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to add event (status code: ${response.statusCode})',
      );
    }
  }

  Future<void> updateEvent(int id, EventDto dto) async {
    final uri = Uri.parse('$baseUrl/api/events/$id'); // => .../api/events/1
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(dto.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to update event with id $id '
            '(status code: ${response.statusCode})',
      );
    }
  }
  Future<void> deleteEvent(int id) async {
    final uri = Uri.parse('$baseUrl/api/events/$id');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete event with id $id '
            '(status code: ${response.statusCode})',
      );
    }
  }

  Future<Uint8List> downloadPdfSummary() async {

    final response = await http.get(
      Uri.parse('$baseUrl/api/events/report/pdf'),
      headers: {
        'Authorization': 'Bearer ${AccountService.token}',
        'Accept': 'application/pdf',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Błąd pobierania PDF: ${response.statusCode}');
    }
  }
}
