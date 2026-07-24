import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knocky/widgets/bbcode_renderer/parser.dart';
import 'package:knocky/widgets/bbcode_renderer/tags.dart';

/// Mirrors the tag set the app registers, without needing a BuildContext.
BBStylesheet buildTestStylesheet() {
  final stylesheet = defaultBBStylesheet()
    ..addTag(InlineCodeTag(isDark: false))
    ..addTag(EmoteTag(isDark: false))
    ..addTag(KnockoutVideoTag())
    ..addTag(CodeBlockTag(isDark: false))
    ..addTag(SmartUrlTag())
    ..addTag(BlockquoteTag())
    ..addTag(KnockoutCollapseTag(isDark: false));
  for (final tag in linkTags.keys) {
    stylesheet.addTag(LinkEmbedTag(tag: tag, provider: tag));
  }
  return stylesheet;
}

/// Concatenated text of every rendered span, so we can assert content survived.
String renderedText(List<InlineSpan> spans) =>
    spans.map((s) => s.toPlainText(includeSemanticsLabels: false)).join();

void main() {
  final stylesheet = buildTestStylesheet();
  final validTags = stylesheet.validTags;

  List<InlineSpan> render(String source) {
    var failed = false;
    final spans = parseBBCode(
      preprocessContent(source, validTags),
      stylesheet: stylesheet,
      onError: (_, _) => failed = true,
    );
    expect(failed, isFalse, reason: 'parse reported an error for: $source');
    return spans;
  }

  group('normalizeTagAttributes', () {
    test('rewrites a value-less attribute into key="value"', () {
      expect(
        normalizeTagAttributes('[youtube thumbnail]url[/youtube]', validTags),
        '[youtube thumbnail="thumbnail"]url[/youtube]',
      );
    });

    test('handles several value-less attributes', () {
      expect(
        normalizeTagAttributes('[img foo bar]x[/img]', validTags),
        '[img foo="foo" bar="bar"]x[/img]',
      );
    });

    test('drops attributes that are not simple words', () {
      expect(
        normalizeTagAttributes('[b "quoted]x[/b]', validTags),
        '[b]x[/b]',
      );
    });

    test('leaves tags that already use "=" alone', () {
      expect(
        normalizeTagAttributes('[quote user=bob thumbnail]x[/quote]', validTags),
        '[quote user=bob thumbnail]x[/quote]',
      );
      expect(
        normalizeTagAttributes('[color=#ff0000]x[/color]', validTags),
        '[color=#ff0000]x[/color]',
      );
    });

    test('leaves prose in brackets alone', () {
      expect(
        normalizeTagAttributes('[see attached image]', validTags),
        '[see attached image]',
      );
    });

    test('leaves closing tags alone', () {
      expect(normalizeTagAttributes('[/b]', validTags), '[/b]');
    });
  });

  group('dropOrphanedClosingTags', () {
    test('removes a closing tag with no opener', () {
      expect(dropOrphanedClosingTags('hello[/b] world', validTags),
          'hello world');
    });

    test('removes the surplus closing tag only', () {
      expect(dropOrphanedClosingTags('[b]hi[/b][/b]', validTags), '[b]hi[/b]');
    });

    test('keeps balanced tags untouched', () {
      expect(dropOrphanedClosingTags('[b][i]hi[/i][/b]', validTags),
          '[b][i]hi[/i][/b]');
    });

    test('keeps unknown closing tags as-is', () {
      expect(dropOrphanedClosingTags('[/nonsense]', validTags), '[/nonsense]');
    });
  });

  group('rendering unsupported attributes', () {
    test('[youtube thumbnail] renders the embed instead of blanking', () {
      final spans = render('[youtube thumbnail]https://youtu.be/abc[/youtube]');
      expect(spans, isNotEmpty);
      expect(spans.whereType<WidgetSpan>(), isNotEmpty);
    });

    test('[b bogus] keeps its content', () {
      expect(renderedText(render('before [b bogus]hi[/b] after')),
          contains('hi'));
    });

    test('unknown flags on a quote keep the post readable', () {
      expect(renderedText(render('[quote nonsense]quoted[/quote] tail')),
          contains('tail'));
    });

    test('a stray closing tag no longer blanks the post', () {
      expect(renderedText(render('some text [/b] more text')),
          contains('more text'));
    });

    test('supported syntax still renders', () {
      expect(renderedText(render('[b]bold[/b] and [i]italic[/i]')),
          'bold and italic');
    });
  });
}
