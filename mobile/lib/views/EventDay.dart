import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/Styles.dart';
import '../viewModels/EventViewModel.dart';
import '../models/event.dart';

class EventDayView extends StatefulWidget {
  const EventDayView({super.key});

  @override
  State<EventDayView> createState() => _EventDayViewState();
}

class _EventDayViewState extends State<EventDayView> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // pobierz od razu wydarzenia z dzisiaj
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventViewModel>().fetchEventsByDay(selectedDate);
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) =>
          Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.purple,
                onPrimary: Colors.white,
                surface: AppColors.darkest,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: AppColors.theDarkest,
            ),
            child: child!,
          ),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      context.read<EventViewModel>().fetchEventsByDay(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final events = context
        .watch<EventViewModel>()
        .events;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Wydarzenia z dnia',
          style: TextStyle(
            fontFamily: AppTextStyles.Andada,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A0033), // ciemny fiolet
              Color(0xFF0D001A), // bardzo ciemny
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.Andada,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: events.isEmpty
                    ? const Center(
                  child: Text(
                    'Brak wydarzeń dla wybranej daty.',
                    style: TextStyle(
                      fontFamily: AppTextStyles.Andada,
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ev = events[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          ev.name,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.Andada,
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            ev.description ?? '',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.Andada,
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        trailing: Text(
                          DateFormat('HH:mm').format(ev.date),
                          style: const TextStyle(
                            fontFamily: AppTextStyles.Andada,
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          // Tu można dodać nawigację do szczegółów wydarzenia
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
