import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:renohouz_worker/manager.dart';
import 'package:renohouz_worker/models/address.dart';
import 'package:renohouz_worker/providers/user_provider.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/views/address_form_page.dart';
import 'package:provider/provider.dart';
import 'package:renohouz_worker/views/edit_skills_page.dart';
import 'package:renohouz_worker/widgets/extra_dialog.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController aboutController;
  DateTime birthDate = DateTime(1999);
  Address? address;
  List<String> skills = [];
  String gender = 'male';
  bool isLoading = false;

  String? addressError;
  String? skillsError;

  @override
  void initState() {
    super.initState();
    UserProvider user = context.read<UserProvider>();
    if (user.about == null) {
      nameController = TextEditingController();
      aboutController = TextEditingController();
    } else {
      nameController = TextEditingController(text: user.name);
      aboutController = TextEditingController(text: user.about);
      birthDate = user.birthDate!;
      address = user.address!;
      skills = user.skills;
      gender = user.gender;
    }
  }

  Widget textField(TextEditingController controller, String label,
      {String? hintText, TextInputType? type, String? Function(String?)? validator, int lines = 1, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        minLines: lines,
        maxLines: lines + 1,
        validator: (val) => val?.isEmpty ?? true ? 'required' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixText: prefix,
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  bool validate() {
    if (address == null) {
      addressError = 'required';
    }
    if (skills.isEmpty) {
      skillsError = 'required';
    }
    setState(() {});
    return (formKey.currentState!.validate() && address != null && skills.isNotEmpty);
  }

  Widget birthDatePicker() {
    return InkWell(
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: birthDate,
          firstDate: DateTime(DateTime.now().year - 90),
          lastDate: DateTime(DateTime.now().year - 16),
        ).then((value) {
          if (value != null) setState(() => birthDate = value);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded),
            Text(DateFormat('d MMMM y').format(birthDate)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget addressPicker() {
    if (address == null) {
      return Row(
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressFormPage())).then((value) {
                if (value != null) setState(() => address = value);
              });
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
          ),
        ],
      );
    }
    return Row(
      children: [
        Text(address!.formattedString),
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressFormPage())).then((value) {
              if (value != null) setState(() => address = value);
            });
          },
          icon: const Icon(Icons.edit_rounded),
        ),
      ],
    );
  }

  Widget skillsEditor() {
    if (skills.isEmpty) {
      return Row(
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditSkillsPage(skills))).then((value) {
                if (value != null) {
                  setState(() => skills = value);
                }
              });
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add'),
          ),
        ],
      );
    }
    return Wrap(
      spacing: 6,
      children: [
        ...skills.map<Widget>((e) => Chip(label: Text(e))).toList(),
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditSkillsPage(skills))).then((value) {
              if (value != null) {
                setState(() => skills = value);
              }
            });
          },
          icon: const Icon(Icons.edit_rounded),
        ),
      ],
    );
  }

  Widget popupMenu() {
    return PopupMenuButton(itemBuilder: (context) {
      return [
        PopupMenuItem(
            child: TextButton(
          onPressed: () {
            User? user = FirebaseAuth.instance.currentUser;
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, logout')),
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                  ],
                );
              },
            ).then((confirm) async {
              if (confirm && user != null) {
                Manager.signOut().catchError((err) {
                  Debugger.log(err);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text('Something went wrong. Please try again later.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))],
                      );
                    },
                  );
                });
              }
            });
          },
          child: const Text('Log out'),
        ))
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registration'),
        actions: [popupMenu()],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              children: [
                textField(nameController, 'Full name', hintText: 'Your full name'),
                textField(
                  aboutController,
                  'About',
                  lines: 6,
                  hintText: 'Tell us about yourself and what skills do you have.',
                ),
                const SizedBox(height: 12),
                const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
                RadioListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                  value: 'male',
                  title: const Text('Male', style: TextStyle(fontSize: 14)),
                  groupValue: gender,
                  onChanged: (String? val) => setState(() => gender = val!),
                ),
                RadioListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                  value: 'female',
                  title: const Text('Female', style: TextStyle(fontSize: 14)),
                  groupValue: gender,
                  onChanged: (String? val) => setState(() => gender = val!),
                ),
                const SizedBox(height: 16),
                const Text('Birth date', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                birthDatePicker(),
                const SizedBox(height: 20),
                const Text('Address', style: TextStyle(fontWeight: FontWeight.w600)),
                addressPicker(),
                const SizedBox(height: 20),
                const Text('Skills', style: TextStyle(fontWeight: FontWeight.w600)),
                skillsEditor(),
                const SizedBox(height: 128),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(minimumSize: MaterialStateProperty.all(const Size(double.infinity, 56))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(isLoading ? 'Loading...' : 'Register'),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (validate()) {
                            setState(() => isLoading = true);
                            context
                                .read<UserProvider>()
                                .register(nameController.text, gender, aboutController.text, birthDate, address!, skills)
                                .catchError((err) {
                              showSimpleDialog(context, 'Something went wrong. Please try again');
                              setState(() => isLoading = false);
                            });
                          }
                        },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
