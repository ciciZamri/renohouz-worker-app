import 'package:flutter/material.dart';

class ErrorItem extends StatelessWidget {
  final Function onRetry;
  final String errorMessage;
  const ErrorItem({Key? key, required this.onRetry, this.errorMessage = 'Something went wrong'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 24.0),
          Text(errorMessage),
          const SizedBox(height: 16.0),
          OutlinedButton(onPressed: () => onRetry(), child: const Text('Try again'))
        ],
      ),
    );
  }
}
