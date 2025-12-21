import 'package:flutter/material.dart';
import 'package:reserve_mobile/core/widgets/reserve_navbar.dart';
import 'package:reserve_mobile/home_search/models/fitness_class.dart';
import 'package:reserve_mobile/home_search/services/classes_service.dart';

class ClassFormPage extends StatefulWidget {
  final FitnessClass? initial; // null = create, not null = edit

  const ClassFormPage({super.key, this.initial});

  @override
  State<ClassFormPage> createState() => _ClassFormPageState();
}

class _ClassFormPageState extends State<ClassFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameC;
  late final TextEditingController _priceC;
  late final TextEditingController _imageUrlC;
  late final TextEditingController _locationC;
  late final TextEditingController _descriptionC;

  String _category = "yoga";
  DateTime? _datetime;

  bool _submitting = false;

  bool get isEdit => widget.initial?.id != null;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;

    _nameC = TextEditingController(text: c?.name ?? "");
    _priceC = TextEditingController(text: (c?.price ?? 0).toString());
    _imageUrlC = TextEditingController(text: c?.imageUrl ?? "");
    _locationC = TextEditingController(text: c?.location ?? "");
    _descriptionC = TextEditingController(text: c?.description ?? "");

    _category = (c?.category.isNotEmpty ?? false) ? c!.category : "yoga";
    _datetime = c?.datetime;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _priceC.dispose();
    _imageUrlC.dispose();
    _locationC.dispose();
    _descriptionC.dispose();
    super.dispose();
  }

  // -------------------- DateTime picker --------------------
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _datetime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_datetime ?? now),
    );
    if (time == null) return;

    setState(() {
      _datetime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "-";
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    final d = days[(dt.weekday - 1).clamp(0, 6)];
    final m = months[(dt.month - 1).clamp(0, 11)];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');

    return "$d, ${dt.day} $m ${dt.year} • $hh:$mm";
  }

  // -------------------- Submit --------------------
  Future<void> _submit() async {
    if (_submitting) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _submitting = true);

    try {
      // We build a FitnessClass object using YOUR MODEL fields.
      // owner is optional (backend will usually set owner from session)
      final fc = FitnessClass(
        id: widget.initial?.id,
        owner: widget.initial?.owner, // not required to send; ok to keep null
        name: _nameC.text.trim(),
        category: _category,
        price: int.parse(_priceC.text.trim()),
        imageUrl: _imageUrlC.text.trim(),
        description: _descriptionC.text.trim(),
        datetime: _datetime,
        location: _locationC.text.trim(),
      );

      if (isEdit) {
  await ClassesService.update(
    context: context,
    id: widget.initial!.id!,
    data: fc.toJson(),
  );
} else {
  await ClassesService.create(
    context: context,
    data: fc.toJson(),
  );
}
      if (!mounted) return;
      Navigator.pop(context, true); // tell previous page: refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // -------------------- UI helpers --------------------
  String _categoryLabel(String code) {
    switch (code) {
      case "yoga":
        return "Yoga";
      case "pilates":
        return "Pilates";
      case "dance":
        return "Dance";
      case "boxing":
        return "Boxing";
      case "muaythai":
        return "Muaythai";
      case "ice-skating":
        return "Ice Skating";
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3EE),
      body: Column(
        children: [
          const ReserveNavbar(active: NavItem.classes),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(60, 40, 60, 60),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? "Edit Class" : "Create Class",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2B2B2B),
                              ),
                            ),
                            const SizedBox(height: 18),

                            _label("Class Name"),
                            _field(
                              controller: _nameC,
                              hint: "Enter class name",
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return "Name is required.";
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _label("Category"),
                            _categoryDropdown(),
                            const SizedBox(height: 16),

                            _label("Price"),
                            _field(
                              controller: _priceC,
                              hint: "e.g. 300000",
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final s = (v ?? "").trim();
                                if (s.isEmpty) return "Price is required.";
                                final n = int.tryParse(s);
                                if (n == null || n < 0) return "Price must be a valid number.";
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _label("Image URL"),
                            _field(
                              controller: _imageUrlC,
                              hint: "https://...",
                            ),
                            const SizedBox(height: 16),

                            _label("Location"),
                            _field(
                              controller: _locationC,
                              hint: "e.g. Studio A",
                            ),
                            const SizedBox(height: 16),

                            _label("Date & Time"),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF3EE),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFE8D8CC)),
                                    ),
                                    child: Text(
                                      _formatDateTime(_datetime),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF3B3B3B),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _pickDateTime,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B4A36),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text(
                                    "Pick",
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _label("Description"),
                            _field(
                              controller: _descriptionC,
                              hint: "Write class description...",
                              maxLines: 6,
                            ),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: _submitting ? null : () => Navigator.pop(context, false),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF6B4A36), width: 1.5),
                                    foregroundColor: const Color(0xFF6B4A36),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _submitting ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE7773A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      _submitting ? "Saving..." : (isEdit ? "Save Changes" : "Create"),
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Small widgets --------------------
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Color(0xFF3B3B3B),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFDF3EE),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8D8CC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8D8CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6B4A36), width: 1.5),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    const items = [
      "yoga",
      "pilates",
      "dance",
      "boxing",
      "muaythai",
      "ice-skating",
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D8CC)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c,
                  child: Text(
                    _categoryLabel(c),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _category = v);
          },
        ),
      ),
    );
  }
}
