import 'package:flutter/material.dart';

class RootErrorPage extends StatelessWidget {
  final void Function() onRetry;

  RootErrorPage({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(children: [
        Container(
          width: double.infinity,
          child: const Padding(
            padding: EdgeInsets.only(top: 48.0, bottom: 16.0),
            child: Center(
              child: Text(
                'Renohouz',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          color: Colors.lightGreen,
        ),
        const SizedBox(height: 125),
        const Icon(Icons.wifi_off_rounded, size: 84),
        const SizedBox(height: 16.0),
        const Text(
          'Please check your internet connection\n and try again.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(onPressed: onRetry, child: Text('Try again'))
      ]),
    );
  }
}
