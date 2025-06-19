// lib/presentation/screens/timeline_screen.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xff1E1E1E,
      ), // Dark background for consistency
      appBar: AppBar(
        title: const Text('My Timeline'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTimelineHeader(),
          const SizedBox(height: 30),
          _buildSectionTitle('Today'),
          const SizedBox(height: 10),
          _buildTimelineEventsToday(),
          const SizedBox(height: 30),
          _buildSectionTitle('Earlier this Week'),
          const SizedBox(height: 10),
          _buildTimelineEventsEarlierWeek(),
          const SizedBox(height: 30),
          _buildSectionTitle('Last Month'),
          const SizedBox(height: 10),
          _buildTimelineEventsLastMonth(),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Journey',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A chronological view of your activities.',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // --- Timeline Event Widgets ---

  Widget _buildTimelineEventsToday() {
    return Column(
      children: [
        _buildTimelineTile(
          time: '10:30 AM',
          title: 'Completed Project Proposal',
          description: 'Finalized the proposal for Project Phoenix.',
          icon: Icons.assignment_turned_in,
          iconColor: Colors.green,
        ),
        _buildTimelineTile(
          time: '09:00 AM',
          title: 'Team Stand-up Meeting',
          description: 'Discussed daily progress and blockers with the team.',
          icon: Icons.groups,
          iconColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildTimelineEventsEarlierWeek() {
    return Column(
      children: [
        _buildTimelineTile(
          time: 'Monday, 3:00 PM',
          title: 'Code Review Session',
          description: 'Reviewed pull requests for feature X.',
          icon: Icons.code,
          iconColor: Colors.purple,
        ),
        _buildTimelineTile(
          time: 'Tuesday, 11:00 AM',
          title: 'Client Demo Preparation',
          description:
              'Prepared slides and demo environment for client presentation.',
          icon: Icons.laptop_mac,
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildTimelineEventsLastMonth() {
    return Column(
      children: [
        _buildTimelineTile(
          time: 'May 15, 2025',
          title: 'Project Alpha Launched',
          description:
              'Successfully launched the Alpha version of the new product.',
          icon: Icons.rocket_launch,
          iconColor: Colors.redAccent,
        ),
        _buildTimelineTile(
          time: 'April 28, 2025',
          title: 'Attended Flutter Conference',
          description:
              'Learned about the latest Flutter updates and best practices.',
          icon: Icons.event,
          iconColor: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildTimelineTile({
    required String time,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return IntrinsicHeight(
      // Ensures the lines align vertically
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Timeline indicator
          Column(
            children: [
              Container(
                width: 2,
                height: 10, // Short line above the dot
                color: Colors.grey[700],
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: iconColor, // Use iconColor for the dot
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[700]!, width: 2),
                ),
                child: Icon(icon, size: 10, color: Colors.white),
              ),
              Expanded(child: Container(width: 2, color: Colors.grey[700])),
            ],
          ),
          const SizedBox(width: 15),
          // Right side: Event details
          Expanded(
            child: Card(
              color: const Color(0xff2D2D2D), // Card background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 15), // Margin between cards
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
