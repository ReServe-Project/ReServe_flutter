import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/profile/services/profile_api.dart';
import '../../features/profile/models/user_profile.dart';
import '../models/PersonalGoal.dart';
import '../services/personal_goal_api.dart';

class PersonalGoalsPage extends StatefulWidget {
  const PersonalGoalsPage({super.key});

  @override
  State<PersonalGoalsPage> createState() => _PersonalGoalsPageState();
}

class _PersonalGoalsPageState extends State<PersonalGoalsPage> {
  static const _bg = Color(0xFFFBF8F1);
  static const _orange = Color(0xFFE86C2A);
  static const _dark = Color(0xFF3F3A59);
  static const _tile = Color(0xFFEFEDE8);

  late int _year;
  late int _month;

  String? _selectedDateStr; // YYYY-MM-DD
  bool _filterBySelectedDate = false;

  bool _loadingCalendar = true;
  bool _loadingGoals = false;

  String _monthName = '';
  List<List<int>> _calendarGrid = const [];
  List<PersonalGoal> _visibleGoals = const [];

  Future<UserProfile>? _profileFuture;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _selectedDateStr = _fmtDate(now);

    final auth = context.read<AuthProvider>();
    _profileFuture = ProfileApi.fetchMyProfile(auth.request);

    _loadCalendar(year: _year, month: _month, keepGoalsList: false);
  }

  String _fmtDate(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _loadCalendar({
    required int year,
    required int month,
    required bool keepGoalsList,
  }) async {
    final auth = context.read<AuthProvider>();

    setState(() {
      _loadingCalendar = true;
    });

    try {
      final cal = await PersonalGoalsApi.fetchCalendar(auth.request, year, month);

      setState(() {
        _year = cal.year;
        _month = cal.month;
        _monthName = cal.monthName;
        _calendarGrid = cal.calendarGrid;

        // Django JS does NOT auto-refresh the goals list on month navigation,
        // so we keep that behavior unless this is the initial load.
        if (!keepGoalsList) {
          _filterBySelectedDate = false;
          _visibleGoals = cal.flattenMonthlyGoalsSorted();
        }

        _loadingCalendar = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCalendar = false);
      _showSnack('Failed to load calendar: $e');
    }
  }

  Future<void> _loadGoalsForSelectedDate() async {
    final dateStr = _selectedDateStr;
    if (dateStr == null) return;

    final parts = dateStr.split('-');
    if (parts.length != 3) return;

    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return;

    final auth = context.read<AuthProvider>();

    setState(() {
      _loadingGoals = true;
      _filterBySelectedDate = true;
    });

    try {
      final goals = await PersonalGoalsApi.fetchGoalsForDate(
        auth.request,
        year: y,
        month: m,
        day: d,
      );

      setState(() {
        _visibleGoals = goals;
        _loadingGoals = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingGoals = false);
      _showSnack('Failed to load goals: $e');
    }
  }

  void _prevMonth() {
    int y = _year;
    int m = _month;
    if (m == 1) {
      m = 12;
      y--;
    } else {
      m--;
    }
    _loadCalendar(year: y, month: m, keepGoalsList: true);
  }

  void _nextMonth() {
    int y = _year;
    int m = _month;
    if (m == 12) {
      m = 1;
      y++;
    } else {
      m++;
    }
    _loadCalendar(year: y, month: m, keepGoalsList: true);
  }

  bool _isSelectedDay(int day) {
    if (day == 0) return false;
    final s = _selectedDateStr;
    if (s == null) return false;

    final parts = s.split('-');
    if (parts.length != 3) return false;

    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return false;

    return y == _year && m == _month && d == day;
  }

  void _onDayTap(int day) {
    if (day == 0) return;

    String two(int x) => x.toString().padLeft(2, '0');
    final dateStr = '$_year-${two(_month)}-${two(day)}';

    setState(() {
      _selectedDateStr = dateStr;
    });

    _loadGoalsForSelectedDate();
  }

  Future<void> _openAddGoalDialog() async {
    final dateStr = _selectedDateStr ?? _fmtDate(DateTime.now());
    final controller = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Add New Goal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2E2B41)),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Goal Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E2B41)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your goal',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _orange, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA44311),
                        backgroundColor: const Color(0xFFFFEDE3),
                        side: const BorderSide(color: _orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final title = controller.text.trim();
                        if (title.isEmpty) return;
                        Navigator.pop(context, title);
                      },
                      child: const Text('Add goal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;
    final title = result.trim();
    if (title.isEmpty) return;

    final auth = context.read<AuthProvider>();

    try {
      // Parse the date to get a temporary ID and create the goal object
      final goalDate = DateTime.parse(dateStr);
      
      // Optimistic UI: add the goal immediately with a temporary ID
      final tempGoal = PersonalGoal(
        id: -DateTime.now().millisecondsSinceEpoch, // negative temp ID
        title: title,
        date: goalDate,
        isCompleted: false,
      );

      setState(() {
        // Only add if we're showing goals for this date
        if (_filterBySelectedDate && _selectedDateStr == dateStr) {
          _visibleGoals = [..._visibleGoals, tempGoal];
        }
      });

      // Send to server
      await PersonalGoalsApi.addGoal(auth.request, title: title, dateStr: dateStr);

      // Refresh to get the real goal ID and ensure consistency
      await _loadCalendar(year: _year, month: _month, keepGoalsList: true);
      await _loadGoalsForSelectedDate();
      
      _showSnack('Goal added successfully!');
    } catch (e) {
      // Revert optimistic update on error by reloading
      await _loadGoalsForSelectedDate();
      _showSnack('Failed to add goal: $e');
    }
  }

  Future<void> _toggleGoal(PersonalGoal goal) async {
    final auth = context.read<AuthProvider>();

    // Optimistic UI
    setState(() {
      _visibleGoals = _visibleGoals
          .map((g) => g.id == goal.id ? g.copyWith(isCompleted: !g.isCompleted) : g)
          .toList();
    });

    try {
      await PersonalGoalsApi.toggleGoal(auth.request, goalId: goal.id);

      // Refresh current view to stay consistent with server
      if (_filterBySelectedDate) {
        await _loadGoalsForSelectedDate();
      }
    } catch (e) {
      // Revert by refreshing
      if (_filterBySelectedDate) {
        await _loadGoalsForSelectedDate();
      } else {
        // If we're showing month list, just reload calendar and rebuild list
        await _loadCalendar(year: _year, month: _month, keepGoalsList: false);
      }
      _showSnack('Failed to toggle goal: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Personal Goals'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900;

                  final left = _buildLeftCalendar();
                  final right = _buildRightGoalsPanel();

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 460, child: left),
                        const SizedBox(width: 28),
                        Expanded(child: right),
                      ],
                    );
                  }

                  return ListView(
                    children: [
                      left,
                      const SizedBox(height: 24),
                      right,
                      const SizedBox(height: 18),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 436,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _orange,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x22000000), offset: Offset(0, 2))],
          ),
          child: const Center(
            child: Text(
              'Select a date to set your goals!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 436,
          height: 439,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _orange),
            borderRadius: BorderRadius.circular(14),
          ),
          child: _loadingCalendar
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        _navBtn(icon: Icons.chevron_left, onTap: _prevMonth),
                        Expanded(
                          child: Center(
                            child: Text(
                              '$_monthName $_year',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _orange,
                              ),
                            ),
                          ),
                        ),
                        _navBtn(icon: Icons.chevron_right, onTap: _nextMonth),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildWeekdayHeader(),
                    const SizedBox(height: 6),
                    Expanded(child: _buildCalendarGrid()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _navBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: const Color(0xFF444444)),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const labels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Row(
      children: labels
          .map(
            (t) => Expanded(
              child: Center(
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B6B83),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    // We render week rows to mimic Django layout precisely.
    return Column(
      children: _calendarGrid.map((week) {
        return Expanded(
          child: Row(
            children: week.map((day) {
              if (day == 0) {
                return const Expanded(child: SizedBox());
              }

              final selected = _isSelectedDay(day);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Material(
                    color: selected ? _orange : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _onDayTap(day),
                      borderRadius: BorderRadius.circular(10),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : const Color(0xFF2E2B41),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRightGoalsPanel() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar (overlapping)
        Positioned(
          left: 10,
          top: -6,
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _orange, width: 4),
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
          ),
        ),

        // Content column
        Padding(
          padding: const EdgeInsets.only(left: 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<UserProfile>(
                future: _profileFuture,
                builder: (context, snap) {
                  final name = (snap.data?.displayName?.trim().isNotEmpty ?? false)
                      ? snap.data!.displayName
                      : (context.read<AuthProvider>().username ?? 'Your');

                  return Text(
                    "'s Personal Goals",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111014),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Dark panel
              Container(
                height: 593,
                decoration: BoxDecoration(
                  color: _dark,
                  border: Border.all(color: _orange, width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Goals list
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 28, 18, 78),
                      child: _loadingGoals
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 742),
                                child: Scrollbar(
                                  child: ListView.separated(
                                    itemCount: _visibleGoals.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final g = _visibleGoals[i];
                                      return _GoalTile(
                                        goal: g,
                                        onToggle: () => _toggleGoal(g),
                                        bg: _tile,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                    ),

                    // Bottom notch + button
                    Positioned(
                      bottom: -22,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _bg,
                            border: Border.all(color: _orange, width: 2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: SizedBox(
                            width: 245,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _openAddGoalDialog,
                              icon: const Icon(Icons.add),
                              label: const Text(
                                'Add Goal',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  final PersonalGoal goal;
  final VoidCallback onToggle;
  final Color bg;

  const _GoalTile({
    required this.goal,
    required this.onToggle,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF2E2B41),
      decoration: goal.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      decorationThickness: 2,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 664),
        child: Container(
          height: 61,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Checkbox(
                value: goal.isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: const Color(0xFF3F3A59),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  goal.title,
                  style: titleStyle.copyWith(
                    color: goal.isCompleted ? const Color(0xFF777777) : const Color(0xFF2E2B41),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
