import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class EditBookingPage extends StatefulWidget {
  final Booking booking;

  const EditBookingPage({super.key, required this.booking});

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;

  bool saving = false;

  // 🎨 COLOR PALETTE (shared theme)
  static const Color bgCream = Color(0xFFFFF7ED);
  static const Color cardWhite = Colors.white;
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color primaryIndigo = Color(0xFF3F3D6B);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFFFFBF5);

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.booking.fullName);
    emailCtrl = TextEditingController(text: widget.booking.email);
    phoneCtrl = TextEditingController(text: widget.booking.phoneNumber);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => saving = true);

    try {
      await BookingService.editBooking(
        context: context,
        bookingId: widget.booking.id,
        fullName: nameCtrl.text,
        email: emailCtrl.text,
        phoneNumber: phoneCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderGray),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: const Text(
          "Edit Booking",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: primaryIndigo,
          ),
        ),
        elevation: 0,
        backgroundColor: bgCream,
        foregroundColor: primaryIndigo,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderGray),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// CLASS NAME (READ ONLY)
                TextField(
                  readOnly: true,
                  decoration: _inputStyle("Class Name").copyWith(
                    hintText: widget.booking.className,
                  ),
                ),

                const SizedBox(height: 20),

                /// FULL NAME
                TextField(
                  controller: nameCtrl,
                  decoration: _inputStyle("Full Name"),
                ),

                const SizedBox(height: 20),

                /// PHONE + EMAIL
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        decoration: _inputStyle("Phone Number"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: emailCtrl,
                        decoration: _inputStyle("Email"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// SAVE BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
