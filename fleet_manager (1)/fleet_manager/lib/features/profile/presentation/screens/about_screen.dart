import 'package:flutter/material.dart';
import 'package:fleet_manager/core/constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '${AppStrings.appName}\n\n'
          'A lightweight fleet management tool for tracking trucks, '
          'drivers, and trip status — built for logistics teams who '
          'need a quick dashboard without heavy GPS/mapping overhead.',
        ),
      ),
    );
  }
}
