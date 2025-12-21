import 'package:unibridge_lk/controllers/events_controller.dart';
import 'package:unibridge_lk/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEventView extends StatefulWidget {
  final EventModel? event; // null for create, populated for edit
  
  const AddEventView({super.key, this.event});

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
  final _platformController = TextEditingController();
  final _registrationLinkController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  String _eventType = 'Physical';

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // Pre-populate fields for editing
      _eventNameController.text = widget.event!.title;
      _dateController.text = widget.event!.date;
      _timeController.text = widget.event!.time;
      _locationController.text = widget.event!.location;
      _hostedByController.text = widget.event!.host;
      _descriptionController.text = widget.event!.description;
      _eventType = widget.event!.eventType;
      if (widget.event!.platform != null) {
        _platformController.text = widget.event!.platform!;
      }
      
      // Parse date and time from string
      try {
        _selectedDate = DateFormat('MMM dd, yyyy').parse(widget.event!.date);
        final timeMatch = RegExp(r'(\d+):(\d+)\s+(AM|PM)').firstMatch(widget.event!.time);
        if (timeMatch != null) {
          int hour = int.parse(timeMatch.group(1)!);
          final minute = int.parse(timeMatch.group(2)!);
          final period = timeMatch.group(3)!;
          if (period == 'PM' && hour != 12) hour += 12;
          if (period == 'AM' && hour == 12) hour = 0;
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        // If parsing fails, leave as null
      }
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _hostedByController.dispose();
    _descriptionController.dispose();
    _platformController.dispose();
    _registrationLinkController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        _timeController.text = '$hour:$minute $period';
      });
    }
  }

  Future<void> _showSuccessDialogAndRedirect() async {
    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Event "${_eventNameController.text.trim()}" created successfully!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // After a short delay, close both the dialog and this page
    Future.delayed(const Duration(seconds: 1), () {
      // Closes top 2 routes: dialog + AddEventView
      if (Get.isDialogOpen ?? false) {
        Get.close(2);
      } else {
        // Fallback: close current page
        Get.back();
      }
    });
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        Get.snackbar(
          'Error',
          'Please select both date and time',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      setState(() => _isSubmitting = true);

      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final controller = Get.find<EventsController>();
      final bool success;
      
      if (widget.event != null) {
        // Update existing event
        success = await controller.updateEvent(
          eventId: widget.event!.id,
          title: _eventNameController.text.trim(),
          eventDate: eventDateTime,
          location: _locationController.text.trim(),
          hostOrganization: _hostedByController.text.trim(),
          description: _descriptionController.text.trim(),
          eventType: _eventType,
          platform: _eventType == 'Online' ? _platformController.text.trim() : null,
          registrationLink: _registrationLinkController.text.trim().isNotEmpty
              ? _registrationLinkController.text.trim()
              : null,
        );
      } else {
        // Create new event
        success = await controller.addEvent(
          title: _eventNameController.text.trim(),
          eventDate: eventDateTime,
          location: _locationController.text.trim(),
          hostOrganization: _hostedByController.text.trim(),
          description: _descriptionController.text.trim(),
          eventType: _eventType,
          platform: _eventType == 'Online' ? _platformController.text.trim() : null,
          registrationLink: _registrationLinkController.text.trim().isNotEmpty
              ? _registrationLinkController.text.trim()
              : null,
        );
      }

      setState(() => _isSubmitting = false);

      if (success) {
        await _showSuccessDialogAndRedirect();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Create Event'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Event Name
                TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'e.g., AI Workshop 2024',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.event),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Event name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Time
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  decoration: InputDecoration(
                    labelText: 'Time',
                    hintText: 'Select time',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Time is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Event Type
                const Text(
                  'Event Type',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Physical'),
                        value: 'Physical',
                        groupValue: _eventType,
                        onChanged: (value) {
                          setState(() {
                            _eventType = value!;
                            if (_eventType == 'Physical') {
                              _platformController.clear();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Online'),
                        value: 'Online',
                        groupValue: _eventType,
                        onChanged: (value) {
                          setState(() {
                            _eventType = value!;
                            if (_eventType == 'Online') {
                              _locationController.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location (Physical) or Platform (Online)
                if (_eventType == 'Physical')
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g., University Main Hall',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _platformController,
                    decoration: InputDecoration(
                      labelText: 'Platform',
                      hintText: 'e.g., Zoom, Google Meet, Microsoft Teams',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.video_call),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Platform is required for online events';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Registration/Joining Link
                TextFormField(
                  controller: _registrationLinkController,
                  decoration: InputDecoration(
                    labelText: _eventType == 'Online'
                        ? 'Joining Link'
                        : 'Registration Link (Optional)',
                    hintText: _eventType == 'Online'
                        ? 'e.g., https://zoom.us/j/123456789'
                        : 'e.g., https://forms.google.com/...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (_eventType == 'Online' && (value == null || value.isEmpty)) {
                      return 'Joining link is required for online events';
                    }
                    if (value != null && value.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Hosted By
                TextFormField(
                  controller: _hostedByController,
                  decoration: InputDecoration(
                    labelText: 'Hosted By',
                    hintText: 'e.g., AI Club, Department Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.people),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Host name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the event, agenda, and expectations...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 68,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _createEvent,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _isSubmitting
                          ? (widget.event != null ? 'Updating...' : 'Creating...')
                          : (widget.event != null ? 'Update Event' : 'Create Event'),
                    ),
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
