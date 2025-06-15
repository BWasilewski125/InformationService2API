import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/Styles.dart';
import '../viewModels/EventViewModel.dart';
import 'EventDay.dart';
import 'EventMoreInfo.dart';
import 'EventWeek.dart';
import 'CreateEvent.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  int _currentEventIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final model = context.read<EventViewModel>();
    model.fetchEvents();
    _startRotation();
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final events = context.read<EventViewModel>().events;
      if (events.isNotEmpty) {
        setState(() {
          _currentEventIndex = (_currentEventIndex + 1) % events.length;
        });
      }
    });
  }
  final List<Color> _eventColors = [
    const Color(0xFF3d259c),
    const Color(0xFF6d1f6f),
    const Color(0xFF514e5b),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<EventViewModel>();
    final events = model.events;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Serwis Informacyjny',
              style: TextStyle(
                fontFamily: AppTextStyles.Andada,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0033), Color(0xFF0D001A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Wybierz kategorię:',
                    style: TextStyle(
                      fontFamily: AppTextStyles.Andada,
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildActionButton(
                    context,
                    icon: Icons.calendar_today,
                    text: 'Wydarzenia z danego dnia',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventDayView())),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    icon: Icons.date_range,
                    text: 'Wydarzenia z tygodnia',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventWeek())),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    icon: Icons.info_outline,
                    text: 'Informacje o evencie',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventMoreInfo())),
                  ),
                ],
              ),
            ),
          ),
          if (events.isNotEmpty)
            Positioned(
              left: 10,
              bottom: 66,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Card(
                  color: _eventColors[_currentEventIndex % _eventColors.length].withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          events[_currentEventIndex].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppTextStyles.Andada,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(events[_currentEventIndex].date),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: AppTextStyles.Andada,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          events[_currentEventIndex].description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: AppTextStyles.Andada,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEvent()),
          );
        },
        tooltip: 'Dodaj nowe wydarzenie',
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: AppTextStyles.Andada,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
      ),
    );
  }
}
