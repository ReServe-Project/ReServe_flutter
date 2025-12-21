import 'package:flutter/material.dart';
import 'package:reserve_mobile/home_search/models/fitness_class.dart';
import 'package:reserve_mobile/home_search/search/class_detail_page.dart';
import 'package:reserve_mobile/home_search/search/class_form_page.dart';
import 'package:reserve_mobile/home_search/services/classes_service.dart';
import 'package:reserve_mobile/core/utils/image_utils.dart';


class ClassCard extends StatelessWidget {
  final FitnessClass c;

  // role logic (your module uses it)
  final bool isInstructor;
  final String currentUser;

  // ✅ NEW: tell parent page to refresh list after edit/delete
  final VoidCallback onChanged;

  const ClassCard({
    super.key,
    required this.c,
    required this.isInstructor,
    required this.currentUser,
    required this.onChanged, // ✅ NEW
  });

  @override
  Widget build(BuildContext context) {
    final bool canManage = isInstructor && (c.owner ?? "") == currentUser;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, 
        children: [
          _imageHeader(),
          Padding(
  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
  child: Text(
    c.name,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
),
Padding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
  child: Text(
    c.formattedPrice,
    style: const TextStyle(
      color: Color(0xFF5C5C5C),
      fontWeight: FontWeight.w600,
    ),
  ),
),
Padding(
  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
  child: Text(
    c.categoryLabel,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      color: Color(0xFF6B4A36),
    ),
  ),
),
Padding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
  child: canManage ? _instructorButtons(context) : _detailsOnly(context),
),

        ],
      ),
    );
  }

  Widget _imageHeader() {
  final url = c.imageUrl.trim();

  return ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
    child: SizedBox(
      height: 140, // 🔥 KEY CHANGE (was too tall)
      width: double.infinity,
      child: url.isNotEmpty
          ? Image.network(
              corsFix(url),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF0E6DE),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 36),
              ),
            )
          : Container(
              color: const Color(0xFFF0E6DE),
              alignment: Alignment.center,
              child: const Icon(Icons.image, size: 36),
            ),
    ),
  );
}



  Widget _detailsOnly(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _goDetail(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE7773A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: const Text("Details", style: TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _instructorButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _goDetail(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE7773A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text("Details", style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClassFormPage(initial: c),
                ),
              );

              // ✅ instead of popping the whole page, just tell parent to refresh
              if (updated == true) {
                onChanged();
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6B4A36), width: 1.5),
              foregroundColor: const Color(0xFF6B4A36),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Edit", style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final confirm = await _confirmDelete(context);
              if (confirm != true) return;
              await ClassesService.delete(
              context: context,
              id: c.id!,
);
              // ✅ refresh list after delete
              onChanged();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1.5),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Class"),
          content: const Text("Are you sure you want to delete this class?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _goDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassDetailPage(fitnessClass: c),
      ),
    );
  }
}
