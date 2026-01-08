import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:extera_next/config/themes.dart';
import 'package:extera_next/utils/client_download_content_extension.dart';
import 'package:extera_next/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:extera_next/widgets/matrix.dart';

class MxcImage extends StatefulWidget {
  final Uri? uri;
  final Event? event;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isThumbnail;
  final bool animated;
  final Duration retryDuration;
  final Duration animationDuration;
  final Curve animationCurve;
  final ThumbnailMethod thumbnailMethod;
  final Widget Function(BuildContext context)? placeholder;
  final String? cacheKey;
  final Client? client;
  final BorderRadius borderRadius;

  const MxcImage({
    this.uri,
    this.event,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.isThumbnail = true,
    this.animated = false,
    this.animationDuration = FluffyThemes.animationDuration,
    this.retryDuration = const Duration(seconds: 2),
    this.animationCurve = FluffyThemes.animationCurve,
    this.thumbnailMethod = ThumbnailMethod.scale,
    this.cacheKey,
    this.client,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  @override
  State<MxcImage> createState() => _MxcImageState();
}

class _MxcImageState extends State<MxcImage> {
  // Static cache to hold bytes in memory across widget rebuilds
  static final Map<String, Uint8List> _imageDataCache = {};

  Uint8List? _currentData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // OPTIMIZATION: Check cache synchronously.
    // If data is there, render it on Frame 1. No "pop-in" effect.
    _currentData = _getFromCache();

    if (_currentData == null) {
      _load();
    }
  }

  @override
  void didUpdateWidget(MxcImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // OPTIMIZATION: Only reload if the source actually changed.
    // This protects against the 2.5k updates/min from the parent.
    if (oldWidget.uri != widget.uri ||
        oldWidget.event != widget.event ||
        oldWidget.cacheKey != widget.cacheKey) {
      final cached = _getFromCache();
      if (cached != null) {
        setState(() {
          _currentData = cached;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentData = null;
        });
        _load();
      }
    }
  }

  Uint8List? _getFromCache() {
    if (widget.cacheKey != null) {
      return _imageDataCache[widget.cacheKey];
    }
    return null;
  }

  void _saveToCache(Uint8List data) {
    if (widget.cacheKey != null) {
      _imageDataCache[widget.cacheKey!] = data;
    }
  }

  Future<void> _load() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final client =
          widget.client ??
          widget.event?.room.client ??
          Matrix.of(context).client;
      final uri = widget.uri;
      final event = widget.event;
      Uint8List? loadedBytes;

      if (uri != null) {
        // Calculate pixel ratio once
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final realWidth = widget.width != null
            ? widget.width! * devicePixelRatio
            : null;
        final realHeight = widget.height != null
            ? widget.height! * devicePixelRatio
            : null;

        loadedBytes = await client.downloadMxcCached(
          uri,
          width: realWidth,
          height: realHeight,
          thumbnailMethod: widget.thumbnailMethod,
          isThumbnail: widget.isThumbnail,
          animated: widget.animated,
        );
      } else if (event != null) {
        final data = await event.downloadAndDecryptAttachment(
          getThumbnail: widget.isThumbnail,
        );
        if (data.detectFileType is MatrixImageFile) {
          loadedBytes = data.bytes;
        }
      }

      if (!mounted) return;

      if (loadedBytes != null && loadedBytes.isNotEmpty) {
        _saveToCache(loadedBytes);
        setState(() {
          _currentData = loadedBytes;
          _isLoading = false;
        });
      } else {
        // Failed to load valid bytes
        _scheduleRetry();
      }
    } on IOException catch (_) {
      _scheduleRetry();
    } catch (e, s) {
      Logs().d('Unexpected error loading mxc image', e, s);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scheduleRetry() {
    if (!mounted) return;
    // Don't busy-loop retries.
    Future.delayed(widget.retryDuration, () {
      if (mounted) {
        _isLoading = false;
        _load();
      }
    });
  }

  Widget _buildPlaceholder(BuildContext context) =>
      widget.placeholder?.call(context) ??
      SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      );

  Widget _buildError(BuildContext context) => SizedBox(
    width: widget.width,
    height: widget.height,
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Icon(
        Icons.broken_image_outlined,
        size: min(widget.height ?? 64, 64),
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    if (data == null || data.isEmpty) {
      return KeyedSubtree(
        key: const ValueKey('placeholder'),
        child: _buildPlaceholder(context),
      );
    }

    // Create the image widget
    final imageWidget = Image.memory(
      data,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      // OPTIMIZATION: gaplessPlayback prevents white flicker during updates
      gaplessPlayback: true,
      // OPTIMIZATION: Low quality for thumbnails saves GPU
      filterQuality: widget.isThumbnail
          ? FilterQuality.low
          : FilterQuality.medium,
      errorBuilder: (context, e, s) {
        Logs().d('Unable to render mxc image bytes', e, s);
        return _buildError(context);
      },
    );

    // OPTIMIZATION: Avoid ClipRRect if not necessary. Clipping is expensive.
    if (widget.borderRadius == BorderRadius.zero) {
      return imageWidget;
    }

    return ClipRRect(
      key: ValueKey(widget.cacheKey ?? widget.uri),
      borderRadius: widget.borderRadius,
      child: imageWidget,
    );
  }
}
