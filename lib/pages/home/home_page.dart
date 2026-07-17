import 'package:flutter/material.dart';

import 'package:jio_leh/widgets/app_bottom_nav.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/map/map_page.dart';
import 'package:jio_leh/pages/map/map_page_model.dart';
import 'package:jio_leh/pages/map/add_pin.dart';
import 'package:jio_leh/pages/invitations/invitations_page.dart';
import 'package:jio_leh/pages/friends/friends_page.dart';
import 'package:jio_leh/pages/profile/profile_page.dart';

// The signed-in home: four tabbed pages behind a bottom nav, plus the center
// "+" that opens the create-a-location sheet.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  bool _didInit = false;
  late final MapPageModel _mapModel;

  // One page per tab. IndexedStack keeps every page alive across switches, so
  // the map doesn't reload (and lose its viewport) each time you leave it.
  late final List<Widget> _pages;

  static const _items = [
    AppNavItem(icon: Icons.map_outlined, label: 'Map'),
    AppNavItem(icon: Icons.flash_on, label: 'Jios'),
    AppNavItem(icon: Icons.people_outline, label: 'Friends'),
    AppNavItem(icon: Icons.person_outline, label: 'You'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _mapModel = MapPageModel(
      pins: services.pins,
      location: services.location,
      geocoding: services.geocoding,
      fog: services.fog,
    );
    _pages = [
      MapPage(model: _mapModel),
      const InvitationsPage(),
      const FriendsPage(),
      const ProfilePage(), // null userId => the current user's own profile
    ];
  }

  @override
  void dispose() {
    _mapModel.dispose();
    super.dispose();
  }

  Future<void> _openCreatePin() async {
    setState(() => _index = 0); // land on the map so the new pin is visible
    await addPin(context, _mapModel);
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
