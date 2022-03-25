import 'package:flutter/material.dart';

Future showSimpleDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))],
      );
    },
  );
}

Future showLoadingDialog(BuildContext context, Function toLoad) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      toLoad();
      return const AlertDialog(
        content: SizedBox(height: 76.0, child: Center(child: CircularProgressIndicator())),
      );
    },
  );
}

/// return true if confirm otherwise null
Future showConfirmationDialog(BuildContext context, String content, String yesLabel,
    {MaterialColor yesLabelColor = Colors.red}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(yesLabel, style: TextStyle(color: yesLabelColor)),
          ),
        ],
      );
    },
  );
}
