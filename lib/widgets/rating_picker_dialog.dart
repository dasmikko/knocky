import 'package:flutter/material.dart';
import '../data/ratings.dart';

/// Result from rating picker - either a rating or a request to unrate
class RatingPickerResult {
  final Rating? rating;
  final bool unrate;

  const RatingPickerResult.rate(this.rating) : unrate = false;
  const RatingPickerResult.unrate() : rating = null, unrate = true;
}

/// Shows a dialog to pick a rating
/// Returns RatingPickerResult with either a rating or unrate=true
Future<RatingPickerResult?> showRatingPickerDialog(
  BuildContext context, {
  bool showUnrate = false,
}) async {
  return showDialog<RatingPickerResult>(
    context: context,
    builder: (context) => RatingPickerDialog(showUnrate: showUnrate),
  );
}

class RatingPickerDialog extends StatelessWidget {
  final bool showUnrate;

  const RatingPickerDialog({super.key, this.showUnrate = false});

  @override
  Widget build(BuildContext context) {
    final availableRatings = enabledRatings;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 350,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Rate Post',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Unrate button
            if (showUnrate)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      const RatingPickerResult.unrate(),
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Remove my rating'),
                  ),
                ),
              ),
            // Rating grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: availableRatings.length,
                itemBuilder: (context, index) {
                  final rating = availableRatings[index];
                  return _RatingTile(
                    rating: rating,
                    onTap: () => Navigator.pop(
                      context,
                      RatingPickerResult.rate(rating),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  final Rating rating;
  final VoidCallback onTap;

  const _RatingTile({
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: rating.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  rating.assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rating.name,
                style: const TextStyle(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
