import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class TimelinePage extends StatelessWidget {
  const TimelinePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(title: const Text('Timeline')),
      body: Column(),
    );
  }
}
