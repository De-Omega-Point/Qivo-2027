import 'package:flutter/material.dart';

import 'widgets/phrase_bank.dart';
import 'widgets/prep_form.dart';

class PrepScreen extends StatelessWidget {
  const PrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          if (compact) {
            return const Column(
              children: [
                PrepForm(),
                SizedBox(height: 16),
                PhraseBank(),
              ],
            );
          }
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: PrepForm()),
              SizedBox(width: 16),
              Expanded(child: PhraseBank()),
            ],
          );
        },
      ),
    );
  }
}
