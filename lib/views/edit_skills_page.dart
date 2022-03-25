import 'package:flutter/material.dart';

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
                  children: skills.map<Widget>((e) => Chip(label: Text(e))).toList(),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              ...suggestions
                  .map((e) => InkWell(
                        onTap: () => setState(() => skills.add(e)),
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
