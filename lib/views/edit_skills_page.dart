import 'package:flutter/material.dart';
import 'package:renohouz_worker/widgets/extra_dialog.dart';

class EditSkillsPage extends StatefulWidget {
  final List<String> initialSkills;
  const EditSkillsPage(this.initialSkills, {Key? key}) : super(key: key);

  @override
  State<EditSkillsPage> createState() => _EditSkillsPageState();
}

class _EditSkillsPageState extends State<EditSkillsPage> {
  List<String> skills = [];
  List<String> suggestions = [];
  TextEditingController controller = TextEditingController();

  Future<List<String>> fetchAutoComplete() async {
    final result = await Future.delayed(
      const Duration(seconds: 1),
      () => ['potong rumput', 'mengecat', 'pasang kipas', 'wiring'],
    );
    result.removeWhere((e) => suggestions.contains(e));
    return result;
  }

  @override
  void initState() {
    super.initState();
    skills = widget.initialSkills;
    controller.addListener(() {
      fetchAutoComplete().then((List<String> value) {
        setState(() => suggestions = value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skills')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 6,
                  children: skills
                      .map<Widget>((e) => Chip(
                            label: Text(e),
                            onDeleted: () => setState(() => skills.remove(e)),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Skill', hintText: 'Type your skills here'),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (skills.length > 6) {
                        showSimpleDialog(context, 'You can only add 7 skills at maximum.');
                        return;
                      }
                      if (!(skills.contains(controller.text))) {
                        setState(() {
                          skills.add(controller.text);
                          controller.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add_rounded, color: Colors.amber),
                  ),
                ],
              ),
              ...suggestions
                  .map((e) => InkWell(
                        onTap: () {
                          if (skills.length > 6) {
                            showSimpleDialog(context, 'You can only add 7 skills at maximum.');
                            return;
                          }
                          if (!skills.contains(e)) setState(() => skills.add(e));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                              child: Text(e),
                            ),
                            const Divider(height: 1),
                          ],
                        ),
                      ))
                  .toList(),
              const SizedBox(height: 128),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ButtonStyle(minimumSize: MaterialStateProperty.all(const Size(double.infinity, 56))),
                onPressed: () => Navigator.pop(context, skills),
                icon: const Icon(Icons.done_rounded),
                label: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
