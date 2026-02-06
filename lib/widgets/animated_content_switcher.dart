import 'package:flutter/material.dart';

/// A widget that provides smooth fade transitions between loading, empty,
/// error, and content states.
///
/// Only shows the loading indicator on initial load (when [data] is null).
/// On subsequent refreshes, the existing content remains visible.
class AnimatedContentSwitcher<T> extends StatelessWidget {
  /// Whether data is currently being loaded.
  final bool isLoading;

  /// The data to display. When null during loading, shows the loading indicator.
  final T? data;

  /// Builder for the content when data is available and not empty.
  final Widget Function(T data) contentBuilder;

  /// Optional check to determine if data is empty.
  /// If not provided, only null checks are performed.
  final bool Function(T data)? isEmpty;

  /// Widget to show when data is empty. Defaults to a simple text message.
  final Widget? emptyWidget;

  /// Optional error message. When set and data is null, shows error state.
  final String? errorMessage;

  /// Optional widget to show on error. If not provided, uses default error UI.
  final Widget? errorWidget;

  /// Callback when retry is pressed on error state.
  final VoidCallback? onRetry;

  /// Duration of the fade transition. Defaults to 200ms.
  final Duration duration;

  const AnimatedContentSwitcher({
    super.key,
    required this.isLoading,
    required this.data,
    required this.contentBuilder,
    this.isEmpty,
    this.emptyWidget,
    this.errorMessage,
    this.errorWidget,
    this.onRetry,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final isInitialLoad = isLoading && data == null;
    final hasError = errorMessage != null && data == null;
    final isDataEmpty = data != null && (isEmpty?.call(data as T) ?? false);

    return AnimatedSwitcher(
      duration: duration,
      child: isInitialLoad
          ? const Center(
              key: ValueKey('loading'),
              child: CircularProgressIndicator(),
            )
          : hasError
              ? _buildErrorWidget(context)
              : isDataEmpty
                  ? _buildEmptyWidget()
                  : data != null
                      ? KeyedSubtree(
                          key: const ValueKey('content'),
                          child: contentBuilder(data as T),
                        )
                      : const SizedBox.shrink(key: ValueKey('none')),
    );
  }

  Widget _buildEmptyWidget() {
    return emptyWidget ??
        const Center(
          key: ValueKey('empty'),
          child: Text('No data available'),
        );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return KeyedSubtree(
        key: const ValueKey('error'),
        child: errorWidget!,
      );
    }

    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
