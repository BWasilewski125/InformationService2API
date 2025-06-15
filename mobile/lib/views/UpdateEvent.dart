import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/EventDto.dart';
import '../viewModels/EventViewModel.dart';
import '../models/Styles.dart';

class UpdateEventPage extends StatefulWidget {
  final Event event;

  const UpdateEventPage({Key? key, required this.event}) : super(key: key);

  @override
  _UpdateEventPageState createState() => _UpdateEventPageState();
}

class _UpdateEventPageState extends State<UpdateEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _nameController = TextEditingController(text: e.name);
    _typeController = TextEditingController(text: e.type);
    _selectedDate = e.date;
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm').format(e.date.toLocal()),
    );
    _descriptionController = TextEditingController(text: e.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _dateController.text =
          DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<EventViewModel>();

    return Scaffold(
      backgroundColor: AppColors.theDarkest,
      appBar: AppBar(
        title: const Text('Edytuj wydarzenie'),
        backgroundColor: AppColors.theDarkest,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nazwa wydarzenia',
                validator: (v) => v == null || v.isEmpty ? 'Podaj nazwę' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _typeController,
                label: 'Typ wydarzenia',
                validator: (v) => v == null || v.isEmpty ? 'Podaj typ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDateTime,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Data i godzina',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (_) => _selectedDate == null ? 'Wybierz datę' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Opis',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Podaj opis' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final updatedEvent = Event(
                    id: widget.event.id,
                    name: _nameController.text,
                    type: _typeController.text,
                    date: _selectedDate!,
                    description: _descriptionController.text, links: [],
                  );
                  try {
                    await viewModel.updateEvent(updatedEvent);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wydarzenie zostało zaktualizowane'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Błąd: \$e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Zapisz zmiany',
                  style: TextStyle(
                    fontFamily: AppTextStyles.Andada,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
