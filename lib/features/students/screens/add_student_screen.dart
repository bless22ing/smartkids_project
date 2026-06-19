import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_constants.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  // PageController controls moving between steps
  final _pageController = PageController();
  int _currentStep = 0;
  bool _saving = false;

  // One form key per step — validates only the current step
  final _formKeys = List.generate(6, (_) => GlobalKey<FormState>());

  // ===== PERSONAL DETAILS =====
  //final _nameCtrl = TextEditingController();
  //DateTime? _dateOfBirth;
  //String _gender = 'Male';

  final _surnameCtrl = TextEditingController();      // renamed/split
  final _firstNameCtrl = TextEditingController();    // new
  DateTime? _dateOfBirth;
  String _gender = 'Male';

// ===== REGISTER DETAILS (NEW) =====
  final _birthCertCtrl = TextEditingController();
  final _religionCtrl = TextEditingController();
  ScholarType _scholarType = ScholarType.day;
  final _gamesHouseCtrl = TextEditingController();

  // ===== SCHOOL DETAILS =====
  String _classId = AppConstants.classEcdA;
  DateTime _enrollmentDate = DateTime.now();

  // ===== GUARDIAN 1 =====
  final _g1NameCtrl = TextEditingController();
  final _g1ContactCtrl = TextEditingController();
  final _g1EmailCtrl = TextEditingController();
  String _g1Relationship = 'Mother';

  // ===== GUARDIAN 2 =====
  final _g2NameCtrl = TextEditingController();
  final _g2ContactCtrl = TextEditingController();
  final _g2EmailCtrl = TextEditingController();
  String _g2Relationship = 'Father';

  // ===== NEXT OF KIN =====
  final _nokNameCtrl = TextEditingController();
  final _nokContactCtrl = TextEditingController();
  final _nokRelationshipCtrl = TextEditingController();

  // ===== MEDICAL =====
  final _allergiesCtrl = TextEditingController();
  final _medicalNotesCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _surnameCtrl.dispose();
    _firstNameCtrl.dispose();
    _birthCertCtrl.dispose();
    _religionCtrl.dispose();
    _gamesHouseCtrl.dispose();
    _g1NameCtrl.dispose();
    _g1ContactCtrl.dispose();
    _g1EmailCtrl.dispose();
    _g2NameCtrl.dispose();
    _g2ContactCtrl.dispose();
    _g2EmailCtrl.dispose();
    _nokNameCtrl.dispose();
    _nokContactCtrl.dispose();
    _nokRelationshipCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicalNotesCtrl.dispose();
    super.dispose();
  }

  // Move to next step — validates current step first
  void _nextStep() {
    // Validate current step's form
    if (!_formKeys[_currentStep].currentState!.validate()) return;

    // Extra validation for date of birth on step 0
    if (_currentStep == 0 && _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      // Last step — save
      _saveStudent();
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

  // Build and save the student to Firestore
  Future<void> _saveStudent() async {
    setState(() => _saving = true);

    try {
      final student = StudentModel(
        id: '',
        surname: _surnameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender,
        birthCertNo: _birthCertCtrl.text.trim(),
        religion: _religionCtrl.text.trim(),
        scholarType: _scholarType,
        gamesHouse: _gamesHouseCtrl.text.trim(),
        classId: _classId,
        enrollmentDate: _enrollmentDate,
        guardian1: GuardianModel(
          name: _g1NameCtrl.text.trim(),
          contact: _g1ContactCtrl.text.trim(),
          email: _g1EmailCtrl.text.trim(),
          relationship: _g1Relationship,
        ),
        guardian2: GuardianModel(
          name: _g2NameCtrl.text.trim(),
          contact: _g2ContactCtrl.text.trim(),
          email: _g2EmailCtrl.text.trim(),
          relationship: _g2Relationship,
        ),
        nextOfKin: GuardianModel(
          name: _nokNameCtrl.text.trim(),
          contact: _nokContactCtrl.text.trim(),
          email: '',
          relationship: _nokRelationshipCtrl.text.trim(),
        ),
        allergies: _allergiesCtrl.text.trim(),
        medicalNotes: _medicalNotesCtrl.text.trim(),
      );

      await ref.read(studentServiceProvider).addStudent(student);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student enrolled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll student: $e'),
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
        title: const Text('Enroll Student'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            // Progress bar shows which step we're on
            value: (_currentStep + 1) / 6,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
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
                  'Step ${_currentStep + 1} of 6',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),

          // Form pages
          Expanded(
            child: PageView(
              controller: _pageController,
              // Disable swiping — user must use buttons
              // This forces validation before moving forward
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalStep(),
                _buildSchoolStep(),
                _buildGuardian1Step(),
                _buildGuardian2Step(),
                _buildNextOfKinStep(),
                _buildMedicalStep(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Back button — hidden on first step
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
                      _currentStep == 5 ? 'Enroll Student' : 'Next',
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
      case 1: return 'School Details';
      case 2: return 'Guardian 1';
      case 3: return 'Guardian 2';
      case 4: return 'Next of Kin';
      case 5: return 'Medical Information';
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
            // Surname
            TextFormField(
              controller: _surnameCtrl,
              decoration: _inputDecoration(
                label: 'Surname',
                icon: Icons.person_outline,
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Surname is required' : null,
            ),

            const SizedBox(height: 16),

            // First name
            TextFormField(
              controller: _firstNameCtrl,
              decoration: _inputDecoration(
                label: 'First Name',
                icon: Icons.person_outline,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'First name is required' : null,
            ),

            const SizedBox(height: 16),

            // Date of birth picker
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.cake_outlined),
              title: Text(
                _dateOfBirth == null
                    ? 'Select Date of Birth'
                    : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 4)),
                  firstDate: DateTime.now().subtract(const Duration(days: 365 * 8)),
                  lastDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                );
                if (picked != null) setState(() => _dateOfBirth = picked);
              },
            ),

            const SizedBox(height: 16),

            // Gender dropdown
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: _inputDecoration(
                label: 'Gender',
                icon: Icons.people_outline,
              ),
              items: ['Male', 'Female'].map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (v) => setState(() => _gender = v!),
            ),

            const SizedBox(height: 16),

            // Birth certificate number — NEW
            TextFormField(
              controller: _birthCertCtrl,
              decoration: _inputDecoration(
                label: 'Birth Certificate No.',
                icon: Icons.badge_outlined,
              ),
            ),

            const SizedBox(height: 16),

            // Religion — NEW
            TextFormField(
              controller: _religionCtrl,
              decoration: _inputDecoration(
                label: 'Religion',
                icon: Icons.church_outlined,
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Boarder/Day — NEW
            DropdownButtonFormField<ScholarType>(
              value: _scholarType,
              decoration: _inputDecoration(
                label: 'Boarder / Day Scholar',
                icon: Icons.home_work_outlined,
              ),
              items: ScholarType.values.map((s) {
                return DropdownMenuItem(value: s, child: Text(s.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _scholarType = v!),
            ),

            const SizedBox(height: 16),

            // Games house — NEW
            TextFormField(
              controller: _gamesHouseCtrl,
              decoration: _inputDecoration(
                label: 'Games House (optional)',
                icon: Icons.sports_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 2: SCHOOL =================

  Widget _buildSchoolStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            // Class selection
            DropdownButtonFormField<String>(
              value: _classId,
              decoration: _inputDecoration(
                label: 'Class',
                icon: Icons.class_outlined,
              ),
              items: [
                DropdownMenuItem(
                  value: AppConstants.classEcdA,
                  child: const Text('ECD A'),
                ),
                DropdownMenuItem(
                  value: AppConstants.classEcdB,
                  child: const Text('ECD B'),
                ),
              ],
              onChanged: (v) => setState(() => _classId = v!),
            ),

            const SizedBox(height: 16),

            // Enrollment date picker
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.event_outlined),
              title: Text(
                'Enrollment Date: ${_enrollmentDate.day}/${_enrollmentDate.month}/${_enrollmentDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _enrollmentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _enrollmentDate = picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 3: GUARDIAN 1 =================

  Widget _buildGuardian1Step() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _g1Relationship,
              decoration: _inputDecoration(
                label: 'Relationship',
                icon: Icons.family_restroom,
              ),
              items: ['Mother', 'Father', 'Guardian'].map((r) {
                return DropdownMenuItem(value: r, child: Text(r));
              }).toList(),
              onChanged: (v) => setState(() => _g1Relationship = v!),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _g1NameCtrl,
              decoration: _inputDecoration(
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _g1ContactCtrl,
              decoration: _inputDecoration(
                label: 'Contact Number',
                icon: Icons.phone_outlined,
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Contact is required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _g1EmailCtrl,
              decoration: _inputDecoration(
                label: 'Email Address',
                icon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 4: GUARDIAN 2 =================

  Widget _buildGuardian2Step() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guardian 2 is optional — show a note
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
                      'Guardian 2 is optional. Leave blank if not applicable.',
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _g2Relationship,
              decoration: _inputDecoration(
                label: 'Relationship',
                icon: Icons.family_restroom,
              ),
              items: ['Mother', 'Father', 'Guardian'].map((r) {
                return DropdownMenuItem(value: r, child: Text(r));
              }).toList(),
              onChanged: (v) => setState(() => _g2Relationship = v!),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _g2NameCtrl,
              decoration: _inputDecoration(
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              textCapitalization: TextCapitalization.words,
              // No validator — optional field
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _g2ContactCtrl,
              decoration: _inputDecoration(
                label: 'Contact Number',
                icon: Icons.phone_outlined,
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _g2EmailCtrl,
              decoration: _inputDecoration(
                label: 'Email Address',
                icon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 5: NEXT OF KIN =================

  Widget _buildNextOfKinStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[4],
        child: Column(
          children: [
            TextFormField(
              controller: _nokNameCtrl,
              decoration: _inputDecoration(
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nokContactCtrl,
              decoration: _inputDecoration(
                label: 'Contact Number',
                icon: Icons.phone_outlined,
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Contact is required' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nokRelationshipCtrl,
              decoration: _inputDecoration(
                label: 'Relationship to Child',
                icon: Icons.people_outline,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Relationship is required'
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 6: MEDICAL =================

  Widget _buildMedicalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[5],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.medical_information_outlined,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Medical information is confidential and only visible to authorized staff.',
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Allergies field
            TextFormField(
              controller: _allergiesCtrl,
              decoration: _inputDecoration(
                label: 'Allergies',
                icon: Icons.warning_amber_outlined,
                helperHint: 'e.g. Peanuts, dairy, bee stings...', // renamed
              ),
              maxLines: 3,
            ),

// Medical notes field
            TextFormField(
              controller: _medicalNotesCtrl,
              decoration: _inputDecoration(
                label: 'Medical Notes',
                icon: Icons.notes_outlined,
                helperHint: 'Any conditions, medications, or special needs...', // renamed
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  // Shared input decoration — consistent styling across all steps

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? helperHint, // renamed to avoid confusion
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      hintText: helperHint, // use renamed parameter here
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
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }
}