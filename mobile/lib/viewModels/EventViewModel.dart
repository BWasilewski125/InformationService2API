import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../models/EventDTO.dart';
import '../models/event.dart';
import '../services/EventService.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<Event> events = [];
  Event? selectedEvent;


  Future<void> fetchEvents() async {
    events = await _eventService.getEvents();
    notifyListeners();
  }
  Future<void> fetchEventsByDay(DateTime date) async {
    events = await _eventService.getEventsByDay(date);
    notifyListeners();
  }

  Future<void> fetchEventsByWeek(int week) async {
    events = await _eventService.getEventsByWeek(week);
    notifyListeners();
  }

  Future<void> fetchEventById(int id) async {
    selectedEvent = await _eventService.getEvent(id);
    notifyListeners();
  }
  Future<bool> deleteEvent(int id) async {
    await _eventService.deleteEvent(id);
    selectedEvent = null;
    notifyListeners();
    return true;
  }

  Future<void> addEvent(Event event) async {
    await _eventService.addEvent(event);
    await fetchEventsByDay(event.date);
  }

  Future<void> updateEvent(Event event) async {
    final dto = EventDto(
      name: event.name,
      type: event.type,
      date: event.date,
      description: event.description,
    );
    await _eventService.updateEvent(event.id, dto);
    await fetchEventById(event.id);
  }

  Future<void> downloadPdf(BuildContext context) async {
    try {
      final bytes = await _eventService.downloadPdfSummary();

      if (bytes.isEmpty) {
        throw Exception("Pusty plik PDF");
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/events_summary.pdf';

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF pobrany i zapisany')),
      );

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się otworzyć PDF: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: ${e.toString()}')),
      );
    }
  }
}
