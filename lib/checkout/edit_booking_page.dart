import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import 'booking_model.dart';
import 'booking_service.dart';

class EditBookingPage extends StatefulWidget {
  final Booking booking;

  const EditBookingPage({super.key, required this.booking});

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.booking.fullName);
    emailController = TextEditingController(text: widget.booking.email);
    phoneController =
        TextEditingController(text: widget.booking.phoneNumber);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final service = BookingService(
      request: auth.request,
      baseUrl: 'http://127.0.0.1:8000',
    );

    final success = await service.editBooking(
      bookingId: widget.booking.id,
      fullName: fullNameController.text,
      email: emailController.text,
      phoneNumber: phoneController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update booking')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                v == null || !v.contains('@') ? 'Invalid email' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.number,
                maxLength: 11,
                validator: (v) =>
                v == null || v.length != 11
                    ? 'Phone must be 11 digits'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submit,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
