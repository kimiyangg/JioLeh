import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/pages/profile/my_pinned_spots_page_model.dart';
import 'package:jio_leh/pages/profile/pin_detail_page.dart';
import 'package:jio_leh/pages/profile/widgets/pinned_spot_card.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_page_header.dart';

/// Pushes the full grid of every place the current user has pinned.
Future<void> showMyPinnedSpotsPage(BuildContext context) {
  return Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => const MyPinnedSpotsPage()));
}

class MyPinnedSpotsPage extends StatefulWidget {
  const MyPinnedSpotsPage({super.key});

  @override
  State<MyPinnedSpotsPage> createState() => _MyPinnedSpotsPageState();
}

class _MyPinnedSpotsPageState extends State<MyPinnedSpotsPage> {
  late final MyPinnedSpotsPageModel _model;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _model = MyPinnedSpotsPageModel(pins: services.pins, auth: services.auth)
      ..addListener(_rebuild)
      ..load();
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _model
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      return const Center(child: BrandLoadingAnimation());
    }

    if (_model.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load your pinned spots: ${_model.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_model.entries.isEmpty) {
      return const Center(child: Text('No pinned spots yet.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _model.entries.length,
      itemBuilder: (context, index) {
        final entry = _model.entries[index];
        return PinnedSpotCard(
          entry: entry,
          onTap: () =>
              showPinDetailPage(context, place: entry.place, pin: entry.pin),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(title: 'My Pinned Spots'),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }
}