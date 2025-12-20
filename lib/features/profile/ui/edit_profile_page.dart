import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/widgets/background_scaffold.dart';
import '../models/user_profile.dart';
import '../services/profile_api.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile initial;

  const EditProfilePage({super.key, required this.initial});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.initial.displayName);
    _heightController =
        TextEditingController(text: widget.initial.heightCm?.toString() ?? '');
    _weightController =
        TextEditingController(text: widget.initial.weightKg?.toString() ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  int? _parseIntOrNull(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  double? _parseDoubleOrNull(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  /// Extract JSON object from a non-JSON exception string.
  /// Example inputs:
  /// - 'Exception: {"status":false,"errors":{...}}'
  /// - 'Failed to update profile (400): {"status":false,...}'
  Map<String, dynamic>? _tryExtractJsonMap(String raw) {
    // Find the first {...} block (non-greedy).
    final match = RegExp(r'(\{.*\})', dotAll: true).firstMatch(raw);
    if (match == null) return null;

    final jsonText = match.group(1);
    if (jsonText == null) return null;

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  String _buildErrorMessageFromApi(Map<String, dynamic> data) {
    // Prefer "errors" (field-level)
    final errorsAny = data['errors'];
    if (errorsAny is Map) {
      final errors = Map<String, dynamic>.from(errorsAny);

      // Show important fields first (more user-friendly)
      final preferredOrder = <String>[
        'display_name',
        'height_cm',
        'weight_kg',
      ];

      final lines = <String>[];

      String? pickFirstMessage(dynamic v) {
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v is String && v.trim().isNotEmpty) return v;
        return null;
      }

      String prettyKey(String key) {
        switch (key) {
          case 'display_name':
            return 'Display name';
          case 'height_cm':
            return 'Height';
          case 'weight_kg':
            return 'Weight';
          default:
            return key;
        }
      }

      // Add preferred fields first
      for (final k in preferredOrder) {
        if (!errors.containsKey(k)) continue;
        final msg = pickFirstMessage(errors[k]);
        if (msg != null) lines.add('${prettyKey(k)}: $msg');
      }

      // Add any remaining errors
      for (final entry in errors.entries) {
        if (preferredOrder.contains(entry.key)) continue;
        final msg = pickFirstMessage(entry.value);
        if (msg != null) lines.add('${prettyKey(entry.key)}: $msg');
      }

      if (lines.isNotEmpty) return lines.join('\n');
    }

    // Fallback to generic message
    final m = data['message'];
    if (m != null && m.toString().trim().isNotEmpty) {
      return m.toString();
    }

    return 'Failed to update profile.';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();

    try {
      final updated = await ProfileApi.updateProfile(
        auth.request,
        displayName: _displayNameController.text.trim(),
        heightCm: _parseIntOrNull(_heightController.text),
        weightKg: _parseDoubleOrNull(_weightController.text),
      );

      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;

      // Now ProfileApi throws Exception(jsonEncode(response)),
      // so we can decode directly (no regex needed).
      final raw = e.toString();
      final jsonText = raw.startsWith('Exception: ') ? raw.substring(11) : raw;

      String message = 'Failed to update profile.';
      try {
        final decoded = jsonDecode(jsonText);
        if (decoded is Map) {
          message = _buildErrorMessageFromApi(
            Map<String, dynamic>.from(decoded),
          );
        } else {
          message = 'Failed to update profile: $raw';
        }
      } catch (_) {
        message = 'Failed to update profile: $raw';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      backgroundAsset: 'assets/images/bg_gym.jpg',
      overlayOpacity: 0.55,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo_reserve.png', height: 26),
            const SizedBox(width: 10),
            const Text('Edit Profile'),
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        helperText: 'This is what others see on your profile.',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Display name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        helperText: 'Optional',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return null;
                        final x = int.tryParse(t);
                        if (x == null) return 'Height must be a number';
                        if (x <= 0) return 'Height must be positive';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        helperText: 'Optional',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return null;
                        final x = double.tryParse(t);
                        if (x == null) return 'Weight must be a number';
                        if (x <= 0) return 'Weight must be positive';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
