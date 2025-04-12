import 'package:flutter/material.dart';

class NotificationsDrawer extends StatelessWidget {
  const NotificationsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: double.infinity,
        color: Colors.black54,
        child: Column(
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.redAccent),
                child: Center(
                  child: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    title: Text(
                      'No new notifications',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.white60),
                    title: Text(
                      'Someone liked your post!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () {
                      // Handle notification click
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
