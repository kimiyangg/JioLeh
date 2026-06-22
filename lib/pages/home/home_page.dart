import 'package:flutter/material.dart';

import 'package:jio_leh/widgets/app_bottom_nav.dart';

import 'package:jio_leh/pages/map/map_page.dart';
import 'package:jio_leh/pages/invitations/invitations_page.dart';
import 'package:jio_leh/pages/friends/friends_page.dart';
import 'package:jio_leh/pages/profile/profile_page.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/map/widgets/location_customize_sheet.dart';

// The signed-in home: four tabbed pages behind a bottom nav, plus the center
// "+" that opens the create-a-location sheet.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  // One page per tab. IndexedStack keeps every page alive across switches, so
  // the map doesn't reload (and lose its viewport) each time you leave it.
  static const _pages = [
    MapPage(),
    InvitationsPage(),
    FriendsPage(),
    ProfilePage(), // null userId => the current user's own profile
  ];

  static const _items = [
    AppNavItem(icon: Icons.map_outlined, label: 'Map'),
    AppNavItem(icon: Icons.flash_on, label: 'Jios'),
    AppNavItem(icon: Icons.people_outline, label: 'Friends'),
    AppNavItem(icon: Icons.person_outline, label: 'You'),
  ];

  Future<void> _openCreatePin() async {
    // UI-only for now: opens the form sheet without an onSave handler, so
    // nothing is persisted. TODO: wire up saving (GPS coords + Services.pins).
    await showLocationCustomizeSheet(context, PinType.restaurant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onCenterTap: _openCreatePin,
      ),
    );
  }
}
