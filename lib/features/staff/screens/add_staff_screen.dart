import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_constants.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/user_permissions.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';

class AddStaffScreen extends ConsumerStatefulWidget {
  const AddStaffScreen({super.key});

  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _saving = false;

  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  // Personal details
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Female';

  // Employment details
  UserRole _role = UserRole.teacher;
  StaffType _staffType = StaffType.teaching;
  String? _classId;
  final _dutiesCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  // Qualifications
  final List<Qualification> _qualifications = [];
  final _qualTitleCtrl = TextEditingController();
  final _qualInstitutionCtrl = TextEditingController();
  final _qualYearCtrl = TextEditingController();

  // Permissions — for assistants
  bool _canWriteRecords = false;
  bool _canMarkAttendance = false;
  bool _canManageFees = false;
  bool _canViewReports = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _dutiesCtrl.dispose();
    _salaryCtrl.dispose();
    _qualTitleCtrl.dispose();
    _qualInstitutionCtrl.dispose();
    _qualYearCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_formKeys[_currentStep].currentState!.validate()) return;
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _saveStaff();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveStaff() async {
    setState(() => _saving = true);

    try {
      // Build permissions based on role
      // Teachers get default permissions
      // Assistants get only what admin checked
      final UserPermissions permissions;
      if (_role == UserRole.assistant) {
        permissions = UserPermissions(
          canWriteRecords: _canWriteRecords,
          canMarkAttendance: _canMarkAttendance,
          canManageFees: _canManageFees,
          canViewReports: _canViewReports,
        );
      } else {
        permissions = _role.defaultPermissions;
      }

      final staff = StaffModel(
        id: '',
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        gender: _gender,
        role: _role,
        staffType: _staffType,
        classId: _staffType == StaffType.teaching ? _classId : null,
        duties: _dutiesCtrl.text.trim(),
        joinDate: DateTime.now(),
        qualifications: _qualifications,
        permissions: permissions,
        monthlySalary: double.tryParse(_salaryCtrl.text) ?? 0,
        salaryPayments: [],
        status: StaffStatus.invited,
      );

      await ref.read(staffServiceProvider).addStaff(staff);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Staff member added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add staff: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Staff Member'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor:
            AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _stepTitle(_currentStep),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of 4',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalStep(),
                _buildEmploymentStep(),
                _buildQualificationsStep(),
                _buildPermissionsStep(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _nextStep,
                    child: _saving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _currentStep == 3
                          ? 'Add Staff Member'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0: return 'Personal Details';
      case 1: return 'Employment Details';
      case 2: return 'Qualifications';
      case 3: return 'Permissions';
      default: return '';
    }
  }

  // ================= STEP 1: PERSONAL =================

  Widget _buildPersonalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration(
                  label: 'Full Name', icon: Icons.person_outline),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: _inputDecoration(
                  label: 'Email Address', icon: Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: _inputDecoration(
                  label: 'Phone Number', icon: Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Phone is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              decoration: _inputDecoration(
                  label: 'Home Address', icon: Icons.home_outlined),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: _inputDecoration(
                  label: 'Gender', icon: Icons.people_outline),
              items: ['Female', 'Male'].map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (v) => setState(() => _gender = v!),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 2: EMPLOYMENT =================

  Widget _buildEmploymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            // Role dropdown
            DropdownButtonFormField<UserRole>(
              value: _role,
              decoration: _inputDecoration(
                  label: 'Role', icon: Icons.badge_outlined),
              items: UserRole.values.map((r) {
                return DropdownMenuItem(
                    value: r, child: Text(r.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 16),

            // Staff type
            DropdownButtonFormField<StaffType>(
              value: _staffType,
              decoration: _inputDecoration(
                  label: 'Staff Type', icon: Icons.work_outline),
              items: StaffType.values.map((t) {
                return DropdownMenuItem(
                    value: t, child: Text(t.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _staffType = v!),
            ),
            const SizedBox(height: 16),

            // Class assignment — only for teaching staff
            if (_staffType == StaffType.teaching) ...[
              DropdownButtonFormField<String>(
                value: _classId,
                decoration: _inputDecoration(
                    label: 'Assigned Class', icon: Icons.class_outlined),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('No class assigned')),
                  DropdownMenuItem(
                    value: AppConstants.classEcdA,
                    child: const Text('ECD A'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.classEcdB,
                    child: const Text('ECD B'),
                  ),
                ],
                onChanged: (v) => setState(() => _classId = v),
              ),
              const SizedBox(height: 16),
            ],

            // Duties
            TextFormField(
              controller: _dutiesCtrl,
              decoration: _inputDecoration(
                  label: 'Duties & Responsibilities',
                  icon: Icons.assignment_outlined),
              maxLines: 3,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Duties are required' : null,
            ),
            const SizedBox(height: 16),

            // Salary
            TextFormField(
              controller: _salaryCtrl,
              decoration: _inputDecoration(
                label: 'Monthly Salary (USD)',
                icon: Icons.attach_money,
              ).copyWith(prefixText: '\$ '),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Salary is required';
                }
                if (double.tryParse(v) == null) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 3: QUALIFICATIONS =================

  Widget _buildQualificationsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add qualifications one at a time. '
                          'You can skip this step if none yet.',
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Add qualification form
            TextFormField(
              controller: _qualTitleCtrl,
              decoration: _inputDecoration(
                  label: 'Qualification Title',
                  icon: Icons.school_outlined),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qualInstitutionCtrl,
              decoration: _inputDecoration(
                  label: 'Institution', icon: Icons.business_outlined),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qualYearCtrl,
              decoration: _inputDecoration(
                  label: 'Year Obtained', icon: Icons.calendar_today),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Add button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_qualTitleCtrl.text.isEmpty) return;
                  setState(() {
                    _qualifications.add(Qualification(
                      title: _qualTitleCtrl.text.trim(),
                      institution: _qualInstitutionCtrl.text.trim(),
                      year: int.tryParse(_qualYearCtrl.text) ?? 0,
                    ));
                    _qualTitleCtrl.clear();
                    _qualInstitutionCtrl.clear();
                    _qualYearCtrl.clear();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Qualification'),
              ),
            ),

            const SizedBox(height: 16),

            // List of added qualifications
            if (_qualifications.isEmpty)
              Center(
                child: Text(
                  'No qualifications added yet',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              )
            else
              ..._qualifications.map((q) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: Text(q.title),
                    subtitle: Text('${q.institution} • ${q.year}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      onPressed: () {
                        setState(() => _qualifications.remove(q));
                      },
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ================= STEP 4: PERMISSIONS =================

  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Only show permission toggles for assistants
            if (_role != UserRole.assistant) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_role.displayName}s automatically get '
                            'appropriate permissions for their role. '
                            'No manual setup needed.',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Assistant permissions — admin controls these
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Assistants have no permissions by default. '
                            'Grant only what is needed.',
                        style:
                        TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Permission toggles
              SwitchListTile(
                title: const Text('Write Records'),
                subtitle: const Text(
                    'Can write anecdote and social development records'),
                value: _canWriteRecords,
                onChanged: (v) => setState(() => _canWriteRecords = v),
              ),
              SwitchListTile(
                title: const Text('Mark Attendance'),
                subtitle: const Text('Can take register and mark attendance'),
                value: _canMarkAttendance,
                onChanged: (v) =>
                    setState(() => _canMarkAttendance = v),
              ),
              SwitchListTile(
                title: const Text('Manage Fees'),
                subtitle: const Text('Can record fee payments'),
                value: _canManageFees,
                onChanged: (v) => setState(() => _canManageFees = v),
              ),
              SwitchListTile(
                title: const Text('View Reports'),
                subtitle: const Text('Can view student progress reports'),
                value: _canViewReports,
                onChanged: (v) => setState(() => _canViewReports = v),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }
}