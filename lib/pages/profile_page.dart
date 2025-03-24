import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _professionController;
  String _selectedGender = 'Male';
  String _selectedStressLevel = 'Low';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _stressLevels = ['Low', 'Moderate', 'High'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userBox = await Hive.openBox('user_data');
    _nameController = TextEditingController(text: userBox.get('name'));
    _ageController = TextEditingController(text: userBox.get('age').toString());
    _professionController = TextEditingController(text: userBox.get('profession'));
    setState(() {
      _selectedGender = userBox.get('gender');
      _selectedStressLevel = userBox.get('stressLevel');
    });
  }

  Future<void> _updateUserData() async {
    final userBox = await Hive.openBox('user_data');
    await userBox.put('name', _nameController.text);
    await userBox.put('age', int.parse(_ageController.text));
    await userBox.put('profession', _professionController.text);
    await userBox.put('gender', _selectedGender);
    await userBox.put('stressLevel', _selectedStressLevel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xC4FF4000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xC4FF4000),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter your age';
                  if (int.tryParse(value!) == null) return 'Please enter a valid age';
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _professionController,
                label: 'Profession',
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Please enter your profession' : null,
              ),
              SizedBox(height: 20),
              _buildDropdown(
                label: 'Gender',
                value: _selectedGender,
                items: _genders,
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              SizedBox(height: 20),
              _buildDropdown(
                label: 'Current Stress Level',
                value: _selectedStressLevel,
                items: _stressLevels,
                onChanged: (value) => setState(() => _selectedStressLevel = value!),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _updateUserData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xC4FF4000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Same _buildTextField and _buildDropdown methods as RegisterPage
  // but with orange theme colors instead of white
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xC4FF4000)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
