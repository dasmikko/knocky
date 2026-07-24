import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/widgets/bbcode_editor/bbcode_editor.dart';
import 'package:knocky/widgets/bbcode_editor/emote_autocomplete_overlay.dart';

void main() {
  group('EmoteAutocompleteManager.getEmoteQuery', () {
    test('triggers at the start of the text', () {
      expect(EmoteAutocompleteManager.getEmoteQuery(':smi', 4), 'smi');
    });

    test('triggers after whitespace', () {
      expect(EmoteAutocompleteManager.getEmoteQuery('hello :smi', 10), 'smi');
      expect(EmoteAutocompleteManager.getEmoteQuery('hello\n:smi', 10), 'smi');
    });

    test('triggers after a closing bbcode tag', () {
      expect(EmoteAutocompleteManager.getEmoteQuery('[b]:smi', 7), 'smi');
    });

    test('does not trigger mid-word', () {
      expect(EmoteAutocompleteManager.getEmoteQuery('Note:something', 14), null);
    });

    test('does not trigger on a completed emote', () {
      expect(EmoteAutocompleteManager.getEmoteQuery(':smile:', 7), null);
    });

    test('does not trigger on a bare colon', () {
      expect(EmoteAutocompleteManager.getEmoteQuery('hey :', 5), null);
    });

    test('does not trigger once the code contains a space', () {
      expect(EmoteAutocompleteManager.getEmoteQuery(':smi le', 7), null);
    });

    test('only considers text before the cursor', () {
      expect(EmoteAutocompleteManager.getEmoteQuery(':smi and more', 4), 'smi');
      expect(EmoteAutocompleteManager.getEmoteQuery('a :smi b', 8), null);
    });
  });

  group('EmoteAutocompleteManager.getMatchingEmotes', () {
    test('returns prefix matches before substring matches', () {
      final matches = EmoteAutocompleteManager.getMatchingEmotes('smi');
      expect(matches, isNotEmpty);
      expect(matches.first.code, 'smile');
    });

    test('prefers the shortest prefix match', () {
      final matches = EmoteAutocompleteManager.getMatchingEmotes('ok');
      expect(matches.first.code, 'ok');
    });

    test('is case insensitive', () {
      final matches = EmoteAutocompleteManager.getMatchingEmotes('SMI');
      expect(matches.first.code, 'smile');
    });

    test('excludes hidden emotes', () {
      final matches = EmoteAutocompleteManager.getMatchingEmotes('ass');
      expect(matches.where((e) => e.code == 'ass'), isEmpty);
    });

    test('returns nothing for an empty query', () {
      expect(EmoteAutocompleteManager.getMatchingEmotes(''), isEmpty);
    });

    test('returns nothing for an unknown code', () {
      expect(
        EmoteAutocompleteManager.getMatchingEmotes('zzzzzznotanemote'),
        isEmpty,
      );
    });
  });

  group('EmoteAutocompleteManager.getReplaceRange', () {
    test('covers the partial code including the colon', () {
      expect(
        EmoteAutocompleteManager.getReplaceRange('hello :smi', 10),
        (6, 10),
      );
    });

    test('is a no-op range when not triggered', () {
      expect(EmoteAutocompleteManager.getReplaceRange('hello', 5), (5, 5));
    });
  });

  group('BbcodeEditor emote autocomplete', () {
    // The overlay is positioned from a post-frame caret measurement, so it
    // takes one extra frame to appear.
    Future<void> typeText(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
      await tester.pump();
    }

    Future<void> pumpEditor(
      WidgetTester tester,
      BbcodeEditorController controller,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BbcodeEditor(
              controller: controller,
              showViewModeToggle: false,
            ),
          ),
        ),
      );
    }

    testWidgets('shows suggestions while typing a code', (tester) async {
      final controller = BbcodeEditorController();
      await pumpEditor(tester, controller);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await typeText(tester, ':smi');

      expect(find.byType(EmoteAutocompleteOverlay), findsOneWidget);
      expect(find.text(':smile:'), findsOneWidget);
    });

    testWidgets('stays compact with many matches', (tester) async {
      await pumpEditor(tester, BbcodeEditorController());

      await tester.tap(find.byType(TextField));
      await tester.pump();
      // A single letter matches far more emotes than the list shows at once.
      await typeText(tester, ':e');

      final list = tester.getRect(find.byType(EmoteAutocompleteOverlay));
      final field = tester.getRect(find.byType(TextField));

      expect(list.width, lessThanOrEqualTo(260));
      expect(list.width, lessThanOrEqualTo(field.width));
      expect(
        list.height,
        lessThanOrEqualTo(
          EmoteAutocompleteOverlay.heightFor(
            EmoteAutocompleteOverlay.visibleItems,
          ),
        ),
      );
    });

    testWidgets('does not show suggestions for plain text', (tester) async {
      final controller = BbcodeEditorController();
      await pumpEditor(tester, controller);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await typeText(tester, 'hello world');

      expect(find.byType(EmoteAutocompleteOverlay), findsNothing);
    });

    testWidgets('tapping a suggestion inserts the full emote', (tester) async {
      final controller = BbcodeEditorController();
      await pumpEditor(tester, controller);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await typeText(tester, 'hey :smi');

      await tester.tap(find.text(':smile:'));
      await tester.pump();

      expect(controller.bbcode, 'hey :smile:');
      expect(find.byType(EmoteAutocompleteOverlay), findsNothing);
    });

    testWidgets('enter inserts the highlighted suggestion', (tester) async {
      final controller = BbcodeEditorController();
      await pumpEditor(tester, controller);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await typeText(tester, ':smi');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(controller.bbcode, ':smile:');
      expect(find.byType(EmoteAutocompleteOverlay), findsNothing);
    });

    testWidgets('arrow down moves the selection before inserting', (
      tester,
    ) async {
      final controller = BbcodeEditorController();
      await pumpEditor(tester, controller);

      final expected = EmoteAutocompleteManager.getMatchingEmotes('sm');

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await typeText(tester, ':sm');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(controller.bbcode, ':${expected[1].code}:');
    });

    testWidgets('follows the caret down the field', (tester) async {
      await pumpEditor(tester, BbcodeEditorController());

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await typeText(tester, ':smi');
      final firstLine = tester.getTopLeft(
        find.byType(EmoteAutocompleteOverlay),
      );

      await typeText(tester, '\n\n\n:smi');
      final fourthLine = tester.getTopLeft(
        find.byType(EmoteAutocompleteOverlay),
      );

      expect(fourthLine.dy, greaterThan(firstLine.dy));
      // Indenting the code shifts the list right with the caret.
      await typeText(tester, '\n\n\n        :smi');
      expect(
        tester.getTopLeft(find.byType(EmoteAutocompleteOverlay)).dx,
        greaterThan(fourthLine.dx),
      );
    });

    testWidgets('stays on screen when the caret is near the bottom', (
      tester,
    ) async {
      // Editor pushed to the bottom of the screen, like a reply sheet.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: 250,
                  child: BbcodeEditor(
                    controller: BbcodeEditorController(),
                    showViewModeToggle: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      // Enough lines to drive the caret to the bottom of the field.
      await typeText(tester, '${'\n' * 12}:smi');

      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final list = tester.getRect(find.byType(EmoteAutocompleteOverlay));
      final caret = tester.getRect(find.byType(TextField)).bottom;

      expect(list.top, greaterThanOrEqualTo(0));
      expect(list.bottom, lessThanOrEqualTo(screen.height));
      // No room below the caret, so it flipped above.
      expect(list.bottom, lessThan(caret));
    });

    testWidgets('escape dismisses the suggestions', (tester) async {
      final controller = BbcodeEditorController();
      await pumpEditor(tester, controller);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await typeText(tester, ':smi');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(find.byType(EmoteAutocompleteOverlay), findsNothing);
      expect(controller.bbcode, ':smi');
    });
  });
}
