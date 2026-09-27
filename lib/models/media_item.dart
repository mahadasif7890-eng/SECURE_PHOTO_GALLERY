import 'package:flutter/material.dart';

enum MediaType { photo, video }

class MediaItem {
  final String id;
  final String title;
  final String url;
  final MediaType type;
  final String? duration;
  final DateTime dateTime;
  final String location;
  final String size;
  final String resolution;
  final bool isFavorite;
  final bool isLocked;
  final Color? placeholderColor;

  const MediaItem({
    required this.id,
    required this.title,
    required this.url,
    this.type = MediaType.photo,
    this.duration,
    required this.dateTime,
    this.location = 'Unknown Location',
    this.size = '3.4 MB',
    this.resolution = '12.2 MP • 4032 × 3024',
    this.isFavorite = false,
    this.isLocked = false,
    this.placeholderColor,
  });

  bool get isVideo => type == MediaType.video;

  MediaItem copyWith({
    String? id,
    String? title,
    String? url,
    MediaType? type,
    String? duration,
    DateTime? dateTime,
    String? location,
    String? size,
    String? resolution,
    bool? isFavorite,
    bool? isLocked,
    Color? placeholderColor,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      size: size ?? this.size,
      resolution: resolution ?? this.resolution,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      placeholderColor: placeholderColor ?? this.placeholderColor,
    );
  }
}

class MemoryStory {
  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;
  final List<MediaItem> items;
  final Color accentColor;

  const MemoryStory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.items,
    this.accentColor = const Color(0xFF1E88E5),
  });
}

class CollectionAlbum {
  final String id;
  final String title;
  final String? subtitle;
  final String coverUrl;
  final int count;
  final IconData? icon;
  final bool isSpecial;

  const CollectionAlbum({
    required this.id,
    required this.title,
    this.subtitle,
    required this.coverUrl,
    required this.count,
    this.icon,
    this.isSpecial = false,
  });
}
