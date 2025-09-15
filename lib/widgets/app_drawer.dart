import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool isDarkMode;
  final VoidCallback onProfileTap;
  final VoidCallback onToggleDarkMode;
  final VoidCallback onSignOut;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.isDarkMode,
    required this.onProfileTap,
    required this.onToggleDarkMode,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors that adapt to dark/light mode for the drawer background
    final drawerBackgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    // Define colors for the DrawerHeader background
    final headerBackgroundColor = isDarkMode
        ? Colors.blueGrey[900]
        : Colors.indigo[700]; // More modern dark/light header
    final headerTextColor =
        Colors.white; // Text is white on both header backgrounds
    final headerIconColor =
        Colors.white; // Icon is white on both header backgrounds

    // Define colors for ListTile text and icons
    final listItemColor = isDarkMode ? Colors.white70 : Colors.black87;
    final listItemIconColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Drawer(
      backgroundColor: drawerBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with adaptive colors and a subtle gradient for modern feel
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  headerBackgroundColor, // Use the adaptive header background color
              // You can add a subtle gradient for a more modern look
              // gradient: LinearGradient(
              //   colors: isDarkMode
              //       ? [Colors.blueGrey[900]!, Colors.blueGrey[800]!]
              //       : [Colors.indigo[700]!, Colors.indigo[500]!],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: headerIconColor, // Icon background adapts
                  child: Icon(
                    Icons.person,
                    size: 25,
                    color: headerBackgroundColor,
                  ), // Icon color adapts
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    userName,
                    style: TextStyle(
                      color: headerTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    userEmail,
                    style: TextStyle(
                      color: headerTextColor.withOpacity(
                        0.7,
                      ), // Slightly less opaque for email
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: listItemIconColor),
            title: Text('Profile', style: TextStyle(color: listItemColor)),
            onTap: onProfileTap,
          ),
          ListTile(
            leading: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: listItemIconColor,
            ),
            title: Text(
              isDarkMode ? 'Light Mode' : 'Dark Mode',
              style: TextStyle(color: listItemColor),
            ),
            onTap: onToggleDarkMode,
          ),
          const Divider(), // Divider remains neutral
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ), // Sign out remains red
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}
