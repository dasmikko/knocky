#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const outputDir = path.join(__dirname, '..', 'lib', 'data');

// Ensure the directory exists
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// Helper to escape single quotes in strings
function escapeString(str) {
  return str.replace(/'/g, "\\'");
}

// ============================================
// THREAD ICONS
// ============================================
function generateThreadIcons() {
  const icons = require('../assets/icons.js');
  const outputPath = path.join(outputDir, 'thread_icons.dart');

  let dart = `// Generated from assets/icons.js - do not edit manually
// Run: node scripts/convert_assets_to_dart.js

class ThreadIcon {
  final int id;
  final String url;
  final String description;
  final String category;
  final bool restricted;
  final bool disabled;
  final String? bg;

  const ThreadIcon({
    required this.id,
    required this.url,
    required this.description,
    required this.category,
    this.restricted = false,
    this.disabled = false,
    this.bg,
  });
}

const List<ThreadIcon> threadIcons = [
`;

  for (const icon of icons) {
    const bg = icon.bg ? `'${icon.bg}'` : 'null';
    dart += `  ThreadIcon(
    id: ${icon.id},
    url: '${escapeString(icon.url)}',
    description: '${escapeString(icon.description)}',
    category: '${escapeString(icon.category)}',
    restricted: ${icon.restricted ?? false},
    disabled: ${icon.disabled ?? false},
    bg: ${bg},
  ),
`;
  }

  dart += `];

/// Lookup a thread icon by ID, returns null if not found
ThreadIcon? getThreadIconById(int id) {
  return threadIcons.where((icon) => icon.id == id).firstOrNull;
}

/// Get all enabled (non-disabled) icons
List<ThreadIcon> get enabledThreadIcons =>
    threadIcons.where((icon) => !icon.disabled).toList();

/// Get all non-restricted icons (for regular users)
List<ThreadIcon> get publicThreadIcons =>
    threadIcons.where((icon) => !icon.restricted && !icon.disabled).toList();
`;

  fs.writeFileSync(outputPath, dart);
  console.log(`Generated ${icons.length} thread icons to ${outputPath}`);
}

// ============================================
// EMOTES
// ============================================
function generateEmotes() {
  const emotes = require('../assets/emotesList.json');
  const outputPath = path.join(outputDir, 'emotes.dart');

  let dart = `// Generated from assets/emotesList.json - do not edit manually
// Run: node scripts/convert_assets_to_dart.js

class Emote {
  final String code;
  final String url;
  final String? title;
  final String? urlDark;
  final bool hidden;

  const Emote({
    required this.code,
    required this.url,
    this.title,
    this.urlDark,
    this.hidden = false,
  });
}

const List<Emote> emotes = [
`;

  let count = 0;
  for (const [code, data] of Object.entries(emotes)) {
    // Skip the legend entry
    if (code.includes('LEGEND')) continue;

    const title = data.title ? `'${escapeString(data.title)}'` : 'null';
    const urlDark = data.url_dark ? `'${escapeString(data.url_dark)}'` : 'null';

    dart += `  Emote(
    code: '${escapeString(code)}',
    url: '${escapeString(data.url)}',
    title: ${title},
    urlDark: ${urlDark},
    hidden: ${data.hidden ?? false},
  ),
`;
    count++;
  }

  dart += `];

/// Lookup an emote by code, returns null if not found
Emote? getEmoteByCode(String code) {
  return emotes.where((e) => e.code == code).firstOrNull;
}

/// Get all visible (non-hidden) emotes
List<Emote> get visibleEmotes =>
    emotes.where((e) => !e.hidden).toList();

/// Map of emote codes to emotes for fast lookup
final Map<String, Emote> emoteMap = {
  for (final e in emotes) e.code: e,
};
`;

  fs.writeFileSync(outputPath, dart);
  console.log(`Generated ${count} emotes to ${outputPath}`);
}

// ============================================
// RATINGS
// ============================================
function generateRatings() {
  const ratings = require('../assets/ratingList.json');
  const outputPath = path.join(outputDir, 'ratings.dart');

  let dart = `// Generated from assets/ratingList.json - do not edit manually
// Run: node scripts/convert_assets_to_dart.js

class Rating {
  final String code;
  final String name;
  final String url;
  final bool disabled;

  const Rating({
    required this.code,
    required this.name,
    required this.url,
    this.disabled = false,
  });
}

const List<Rating> ratings = [
`;

  let count = 0;
  for (const [code, data] of Object.entries(ratings)) {
    dart += `  Rating(
    code: '${escapeString(code)}',
    name: '${escapeString(data.name)}',
    url: '${escapeString(data.url)}',
    disabled: ${data.disabled ?? false},
  ),
`;
    count++;
  }

  dart += `];

/// Lookup a rating by code, returns null if not found
Rating? getRatingByCode(String code) {
  return ratings.where((r) => r.code == code).firstOrNull;
}

/// Get all enabled ratings
List<Rating> get enabledRatings =>
    ratings.where((r) => !r.disabled).toList();

/// Map of rating codes to ratings for fast lookup
final Map<String, Rating> ratingMap = {
  for (final r in ratings) r.code: r,
};
`;

  fs.writeFileSync(outputPath, dart);
  console.log(`Generated ${count} ratings to ${outputPath}`);
}

// Run all generators
generateThreadIcons();
generateEmotes();
generateRatings();

console.log('\nDone!');
