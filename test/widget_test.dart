import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:secure_photo_gallery/data/sample_data.dart';
import 'package:secure_photo_gallery/main.dart';
import 'package:secure_photo_gallery/models/media_item.dart';
import 'package:secure_photo_gallery/screens/auth_screen.dart';
import 'package:secure_photo_gallery/screens/main_navigation_screen.dart';
import 'package:secure_photo_gallery/screens/onboarding_screen.dart';
import 'package:secure_photo_gallery/screens/profile_screen.dart';
import 'package:secure_photo_gallery/widgets/locked_vault_screen.dart';
import 'package:secure_photo_gallery/widgets/media_grid_item.dart';
import 'package:secure_photo_gallery/widgets/photo_details_screen.dart';

class _MockImageHttpOverrides extends HttpOverrides {
  static final List<int> _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(_transparentPng);
  }
}

class _MockHttpClient implements HttpClient {
  final List<int> _bytes;
  _MockHttpClient(this._bytes);

  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest(_bytes);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(_bytes);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final List<int> _bytes;
  _MockHttpClientRequest(this._bytes);

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse(_bytes);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final List<int> _bytes;
  _MockHttpClientResponse(this._bytes);

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockImageHttpOverrides();
  });

  test('SampleData contains at least 15 photographs with titles and descriptions', () {
    final photos = SampleData.allMedia.where((m) => m.type == MediaType.photo).toList();
    expect(photos.length, greaterThanOrEqualTo(15));
    for (final photo in photos) {
      expect(photo.title.trim(), isNotEmpty);
      expect(photo.description.trim(), isNotEmpty);
    }
  });

  testWidgets(
      'Gallery renders 3 per row with consistent spacing, scrolls, opens detail with title/description, and returns',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationScreen()),
    );
    await tester.pump();

    // Verify 3-column grid with consistent spacing
    final sliverGrid = tester.widget<SliverGrid>(find.byType(SliverGrid).first);
    final delegate =
        sliverGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);
    expect(delegate.crossAxisSpacing, equals(delegate.mainAxisSpacing));
    expect(delegate.crossAxisSpacing, greaterThan(0));

    // Verify 3 items share the same top Y row
    final firstThree = find.byType(MediaGridItem);
    expect(firstThree, findsWidgets);
    final rect0 = tester.getRect(firstThree.at(0));
    final rect1 = tester.getRect(firstThree.at(1));
    final rect2 = tester.getRect(firstThree.at(2));
    expect(rect0.top, equals(rect1.top));
    expect(rect1.top, equals(rect2.top));
    expect(rect1.left - rect0.right, closeTo(delegate.crossAxisSpacing, 0.5));
    expect(rect2.left - rect1.right, closeTo(delegate.crossAxisSpacing, 0.5));

    // Verify scrolling through the collection works
    final scrollView = find.byType(CustomScrollView).first;
    final initialTop = tester.getTopLeft(firstThree.first).dy;
    await tester.drag(scrollView, const Offset(0, -500));
    await tester.pump();
    await tester.drag(scrollView, const Offset(0, 500));
    await tester.pump();
    expect(tester.getTopLeft(firstThree.first).dy, closeTo(initialTop, 5));

    // Tap first item to open larger detail view (also confirms no Hero tag collision)
    final firstItem = SampleData.allMedia.first;
    await tester.tap(firstThree.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(PhotoDetailsScreen), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text(firstItem.title), findsOneWidget);
    expect(find.text(firstItem.description), findsOneWidget);

    // Return to the full gallery
    await tester.tap(find.byTooltip('Back to gallery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(PhotoDetailsScreen), findsNothing);
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('App layout adapts sensibly across phone, landscape, and tablet/desktop sizes',
      (WidgetTester tester) async {
    const sizes = [
      Size(320, 568), // Narrow phone
      Size(844, 390), // Phone landscape
      Size(1024, 768), // Tablet / Desktop
    ];

    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      for (final screen in <Widget>[
        const MainNavigationScreen(),
        const OnboardingScreen(),
        const AuthScreen(),
        const ProfileScreen(),
        LockedVaultScreen(lockedItems: SampleData.allMedia.take(3).toList()),
        PhotoDetailsScreen(mediaList: SampleData.allMedia, initialIndex: 0),
      ]) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: 'No layout errors for ${screen.runtimeType} at $size');
      }
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('SecurePhotoGalleryApp boots into SplashScreen cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const SecurePhotoGalleryApp());
    await tester.pump();
    expect(find.text('Secure Photos'), findsOneWidget);

    // Advance timer past splash delay so no pending timer remains
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();
    expect(find.text('Skip'), findsOneWidget);
  });
}
