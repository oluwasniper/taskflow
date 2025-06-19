// lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E), // Dark background
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        centerTitle: true, // Center title
      ),
      body: ListView(
        padding: const EdgeInsets.all(20), // Padding around the entire list
        children: [
          _buildProfileHeader(), // Section for user profile info
          const SizedBox(height: 30), // Spacer
          _buildSectionTitle('Statistics'), // Section title
          const SizedBox(height: 10), // Spacer
          _buildStatsCard(), // Card displaying user statistics
          const SizedBox(height: 30), // Spacer
          _buildSectionTitle('Achievements'), // Section title
          const SizedBox(height: 10), // Spacer
          _buildAchievements(), // Horizontal list of achievements
          const SizedBox(height: 30), // Spacer
          _buildSectionTitle('Settings'), // Section title
          const SizedBox(height: 10), // Spacer
          _buildSettingsList(context), // List of settings options
        ],
      ),
    );
  }

  /// Builds the top section of the profile screen, displaying user avatar, name, and email.
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(
            'https://placehold.co/100x100/blue/white?text=User',
          ), // Placeholder image
        ),
        const SizedBox(height: 15), // Spacer
        const Text(
          'John Doe', // User's name
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5), // Spacer
        Text(
          'john.doe@example.com', // User's email
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  /// Builds a generic section title with consistent styling.
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

  /// Builds a card displaying key user statistics.
  Widget _buildStatsCard() {
    return Card(
      color: const Color(0xff2D2D2D), // Card background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround, // Distribute space evenly
          children: [
            _buildStatItem('Completed', '128', Icons.check_circle_outline),
            _buildStatItem('Productivity', '85%', Icons.trending_up),
            _buildStatItem('Projects', '12', Icons.folder_outlined),
          ],
        ),
      ),
    );
  }

  /// Builds a single statistic item (icon, value, label).
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28), // Statistic icon
        const SizedBox(height: 8), // Spacer
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4), // Spacer
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      ],
    );
  }

  /// Builds a horizontal scrollable list of user achievements.
  Widget _buildAchievements() {
    return SizedBox(
      height: 100, // Fixed height for the horizontal ListView
      child: ListView(
        scrollDirection: Axis.horizontal, // Scroll horizontally
        children: [
          _buildAchievementItem('Master Tasker', Icons.star, Colors.amber),
          _buildAchievementItem(
            'Productivity Pro',
            Icons.emoji_events,
            Colors.deepOrange,
          ),
          _buildAchievementItem('Early Bird', Icons.wb_sunny, Colors.yellow),
          _buildAchievementItem(
            'Night Owl',
            Icons.nightlight_round,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  /// Builds a single achievement item card.
  Widget _buildAchievementItem(String name, IconData icon, Color color) {
    return Container(
      width: 100, // Fixed width for each achievement card
      margin: const EdgeInsets.only(right: 12), // Margin between cards
      padding: const EdgeInsets.all(12), // Padding inside the container
      decoration: BoxDecoration(
        color: const Color(0xff2D2D2D), // Card background color
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Column(
        // Column containing icon and text
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        children: [
          Icon(icon, color: color, size: 36), // Achievement icon
          const SizedBox(
            height: 6,
          ), // *** FIX: Reduced from 8 to 6 to prevent overflow ***
          Text(
            name,
            textAlign: TextAlign.center, // Center text horizontally
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Builds a card containing a list of settings options.
  Widget _buildSettingsList(BuildContext context) {
    return Card(
      color: const Color(0xff2D2D2D), // Card background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Rounded corners
      child: Column(
        children: [
          _buildSettingsTile('Account', Icons.person_outline, () {
            // TODO: Implement navigation to account settings
          }),
          _buildSettingsTile('Notifications', Icons.notifications_outlined, () {
            // TODO: Implement navigation to notification settings
          }),
          _buildSettingsTile('Appearance', Icons.palette_outlined, () {
            // TODO: Implement navigation to appearance settings
          }),
          _buildSettingsTile('Help & Support', Icons.help_outline, () {
            // TODO: Implement navigation to help & support
          }),
          _buildSettingsTile('Logout', Icons.logout, () {
            // TODO: Implement logout logic
          }, isLogout: true), // Special styling for logout
        ],
      ),
    );
  }

  /// Builds a single ListTile for a settings option.
  Widget _buildSettingsTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.grey[400],
      ), // Icon for the setting
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.white,
        ), // Text for the setting
      ),
      trailing: isLogout
          ? null
          : const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ), // Arrow for navigation
      onTap: onTap, // Callback when tile is tapped
    );
  }
}
