import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEventView extends StatefulWidget {
  const AddEventView({super.key});

  @override
  State<AddEventView> createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _hostedByController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _hostedByController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hours = picked.hour.toString().padLeft(2, '0');
      final minutes = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      _timeController.text = '$hours:$minutes $period';
    }
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      // In a real app, this would save to Firestore
      Get.back(); // Go back to events list
      Get.snackbar(
        'Success',
        'Event "${_eventNameController.text}" created!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Event Name
                TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'e.g., AI Workshop 2024',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.event),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Event name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Date
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Time
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  decoration: InputDecoration(
                    labelText: 'Time',
                    hintText: 'Select time',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Time is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., University Main Hall',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Hosted By
                TextFormField(
                  controller: _hostedByController,
                  decoration: InputDecoration(
                    labelText: 'Hosted By',
                    hintText: 'e.g., AI Club, Department Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Host name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the event, agenda, and expectations...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _createEvent,
                    icon: Icon(Icons.check_circle),
                    label: Text('Create Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
