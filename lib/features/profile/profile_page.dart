import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/background_scaffold.dart';
import 'models/user_profile.dart';
import 'services/profile_api.dart';
import 'ui/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _load();
  }

  Future<UserProfile> _load() async {
    final auth = context.read<AuthProvider>();
    return ProfileApi.fetchMyProfile(auth.request);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureProfile = _load();
    });
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout(baseUrl: AppConfig.baseUrl);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  bool _isInstructor(String? role) {
    if (role == null) return false;
    return role.toLowerCase().contains('instructor');
  }

  String _roleLabel(String? role) {
    return _isInstructor(role) ? 'Instructor' : 'Member';
  }

  String _formatLastLogin(String? iso) {
    if (iso == null || iso.trim().isEmpty) return '-';
    return iso; // simple for now
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      backgroundAsset: 'assets/images/bg_gym.jpg',
      overlayOpacity: 0.55,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo_reserve.png', height: 28),
            const SizedBox(width: 10),
            const Text('Profile'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      child: FutureBuilder<UserProfile>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Failed to load profile.'),
                        const SizedBox(height: 12),
                        Text(snapshot.error.toString()),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final profile = snapshot.data!;
          final roleText = _roleLabel(profile.role);
          final isInstructor = _isInstructor(profile.role);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileHeaderCard(
                displayName: profile.displayName,
                handle: profile.handle,
                roleLabel: roleText,
                isInstructor: isInstructor,
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Account',
                children: [
                  _InfoRow(label: 'RS ID', value: profile.rsId ?? '-'),
                  _InfoRow(label: 'Username', value: profile.username),
                  _InfoRow(label: 'Role', value: roleText),
                ],
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Body Metrics',
                children: [
                  _InfoRow(
                    label: 'Height',
                    value: profile.heightCm == null ? '-' : '${profile.heightCm} cm',
                  ),
                  _InfoRow(
                    label: 'Weight',
                    value: profile.weightKg == null ? '-' : '${profile.weightKg} kg',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Activity',
                children: [
                  _InfoRow(label: 'Last login', value: _formatLastLogin(profile.lastLoginIso)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<UserProfile?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(initial: profile),
                      ),
                    );

                    if (updated != null) {
                      setState(() {
                        _futureProfile = Future.value(updated);
                      });
                    } else {
                      _refresh();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String displayName;
  final String? handle;
  final String roleLabel;
  final bool isInstructor;

  const _ProfileHeaderCard({
    required this.displayName,
    required this.handle,
    required this.roleLabel,
    required this.isInstructor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('@${handle ?? "-"}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  _RoleBadge(label: roleLabel, isInstructor: isInstructor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final bool isInstructor;

  const _RoleBadge({required this.label, required this.isInstructor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = isInstructor ? theme.colorScheme.primaryContainer : theme.colorScheme.secondaryContainer;
    final fg = isInstructor ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: theme.textTheme.labelLarge?.copyWith(color: fg)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
