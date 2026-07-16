import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/pages/profile/pin_detail_page_model.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/tag_chip_row.dart';

/// Pushes a page showing one of the current user's own pins: their rating,
/// review, and photos for that place.
Future<void> showPinDetailPage(
  BuildContext context, {
  required Place place,
  required UserPin pin,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => PinDetailPage(place: place, pin: pin)),
  );
}

class PinDetailPage extends StatefulWidget {
  const PinDetailPage({super.key, required this.place, required this.pin});

  final Place place;
  final UserPin pin;

  @override
  State<PinDetailPage> createState() => _PinDetailPageState();
}

class _PinDetailPageState extends State<PinDetailPage> {
  late final PinDetailPageModel _model;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _model = PinDetailPageModel(pin: widget.pin, pins: services.pins)
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
            'Could not load photos: ${_model.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final rating = widget.pin.rating ?? 0;
    final review = widget.pin.review?.trim() ?? '';
    final categoryLabel = PinType.fromEmoji(widget.place.category)?.label;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categoryLabel != null)
            Text(
              categoryLabel,
              style: TextStyle(
                fontSize: context.scaledFont(AppTextSizes.label),
                color: AppColors.lightSubtitle,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (widget.pin.aiTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            TagChipRow(tags: widget.pin.aiTags),
          ],
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                Icon(
                  star <= rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.isEmpty ? 'No review written.' : review,
            style: TextStyle(
              fontSize: context.scaledFont(AppTextSizes.body),
              fontStyle: review.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: review.isEmpty
                  ? AppColors.lightSubtitle
                  : AppColors.lightText,
            ),
          ),
          if (_model.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final url in _model.photoUrls)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 120,
                          height: 120,
                          child: ColoredBox(
                            color: Colors.black12,
                            child: Icon(Icons.broken_image),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(title: widget.pin.customName ?? widget.place.name),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }
}