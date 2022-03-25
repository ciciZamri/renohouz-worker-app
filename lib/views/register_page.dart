import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:renohouz_worker/manager.dart';
import 'package:renohouz_worker/models/address.dart';
import 'package:renohouz_worker/providers/user_provider.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/views/address_form_page.dart';
import 'package:provider/provider.dart';

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
  String? registrationError;

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
        decoration: InputDecoration(labelText: label, hintText: hintText, prefixText: prefix),
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
        decoration: BoxDecoration(border: Border.all()),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded),
            Text('${birthDate.day} ${birthDate.month} ${birthDate.year}'),
          ],
        ),
      ),
    );
  }

  Widget addressPicker() {
    if (address == null) {
      return TextButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressFormPage())).then((value) {
            if (value != null) setState(() => address = value);
          });
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 64.0, bottom: 12),
            child: Text('Registration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                textField(nameController, 'Full name', hintText: 'Your full name'),
                textField(aboutController, 'About', hintText: 'Tell us about yourself and what skills do you have.'),
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
                const Text('Birth date'),
                birthDatePicker(),
                Text('Address'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
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
                                  setState(() {
                                    registrationError = "Something wrong. Please try again.";
                                    isLoading = false;
                                  });
                                });
                              }
                            },
                    ),
                  ],
                ),
                registrationError != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(registrationError ?? '', style: const TextStyle(color: Colors.red)),
                      )
                    : const SizedBox(height: 0),
              ],
            ),
          ),
          TextButton(
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
          ),
        ],
      ),
    );
  }
}
