import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';

class PlannedFeaturePage extends StatelessWidget {
  final String title;
  const PlannedFeaturePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: CardContainer(
        title: title,
        child: Text(
          'Tämä ominaisuus on suunnitteilla.',
          style: TextStyle(color: AppTheme.amber, fontSize: 11, height: 1.55),
        ),
      ),
    );
  }
}
