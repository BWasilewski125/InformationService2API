import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/Styles.dart';
import '../viewModels/EventViewModel.dart';
import 'UpdateEvent.dart';

class EventMoreInfo extends StatefulWidget {
  const EventMoreInfo({super.key});

  @override
  State<EventMoreInfo> createState() => _EventMoreInfoState();
}

class _EventMoreInfoState extends State<EventMoreInfo> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<EventViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await context.read<EventViewModel>().fetchEvents();
            Navigator.pop(context);
          },

          tooltip: 'Wróć',
        ),
        centerTitle: true,
        title: const Text(
          'Szczegóły wydarzenia',
          style: TextStyle(
            fontFamily: AppTextStyles.Andada,
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
              Color(0xFF0D001A), // prawie czarny
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _idController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'ID wydarzenia',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.purple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Podaj ID';
                      if (int.tryParse(value) == null)
                        return 'ID musi być liczbą';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final id = int.parse(_idController.text);
                        await model.fetchEventById(id);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Pokaż szczegóły',
                      style: TextStyle(
                        fontFamily: AppTextStyles.Andada,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (model.selectedEvent != null) ...[
                    Card(
                      color: AppColors.darkest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Nazwa: ${model.selectedEvent!.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: AppTextStyles.Andada,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Id: ${model.selectedEvent!.id}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: AppTextStyles.Andada,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Typ: ${model.selectedEvent!.type}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: AppTextStyles.Andada,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data: ${DateFormat('dd.MM.yyyy HH:mm').format(
                                  model.selectedEvent!.date.toLocal())}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: AppTextStyles.Andada,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Opis: ${model.selectedEvent!.description}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontFamily: AppTextStyles.Andada,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdateEventPage(
                                    event: model.selectedEvent!),
                              ),
                            );
                          },
                          icon: const Icon(
                              Icons.edit, color: Colors.white, size: 18),
                          label: const Text(
                            'EDYTUJ',
                            style: TextStyle(
                              fontFamily: AppTextStyles.Andada,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final success = await context.read<EventViewModel>()
                                .deleteEvent(model.selectedEvent!.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Wydarzenie usunięte'
                                    : 'Błąd podczas usuwania'),
                              ),
                            );
                          },
                          icon: const Icon(
                              Icons.delete, color: Colors.white, size: 18),
                          label: const Text(
                            'USUŃ',
                            style: TextStyle(
                              fontFamily: AppTextStyles.Andada,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dark,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<EventViewModel>().downloadPdf(context);
                    },
                    icon: const Icon(
                        Icons.picture_as_pdf, color: Colors.white, size: 18),
                    label: const Text(
                      'POBIERZ PDF',
                      style: TextStyle(
                        fontFamily: AppTextStyles.Andada,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
