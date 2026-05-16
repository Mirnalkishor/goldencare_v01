import 'package:flutter/material.dart';

/// Design tokens extracted from Web app globals.css
/// OKLCH values converted to HEX approximations
class GCColors {
  // ── Primary (Warm Gold) ──────────────────────────────
  // from web: oklch(0.72 0.12 85) — navbar logo bg, buttons, highlights
  static const primary = Color(0xFFC4973B);
  // from web: oklch(0.2 0.02 50) — text on gold buttons
  static const primaryForeground = Color(0xFF2E2315);

  // ── Background & Foreground ─────────────────────────
  // from web: oklch(0.98 0.005 85) — page background (cream)
  static const background = Color(0xFFFAF8F5);
  // from web: oklch(0.25 0.02 50) — main text color (dark brown)
  static const foreground = Color(0xFF3B3025);

  // ── Card ────────────────────────────────────────────
  // from web: oklch(1 0 0) — card backgrounds
  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF3B3025); // same as foreground

  // ── Secondary ───────────────────────────────────────
  // from web: oklch(0.96 0.01 85) — secondary backgrounds
  static const secondary = Color(0xFFF5F2EE);
  static const secondaryForeground = Color(0xFF3B3025);

  // ── Muted ───────────────────────────────────────────
  // from web: oklch(0.94 0.01 85) — muted backgrounds, input bg
  static const muted = Color(0xFFEDE9E3);
  // from web: oklch(0.5 0.02 50) — muted text (placeholder, secondary text)
  static const mutedForeground = Color(0xFF7A7060);

  // ── Accent (Sage Green) ─────────────────────────────
  // from web: oklch(0.65 0.1 155) — checkmarks, success indicators
  static const accent = Color(0xFF4D9B6A);
  static const accentForeground = Color(0xFFFAFAFA);

  // ── Destructive ─────────────────────────────────────
  // from web: oklch(0.55 0.2 25) — errors, delete
  static const destructive = Color(0xFFB5302D);
  static const destructiveForeground = Color(0xFFFAFAFA);

  // ── Borders & Inputs ────────────────────────────────
  // from web: oklch(0.9 0.02 85) — borders
  static const border = Color(0xFFE5E0D8);
  // from web: oklch(0.94 0.01 85) — input borders
  static const input = Color(0xFFEDE9E3);
  // from web: oklch(0.72 0.12 85) — focus ring (same as primary)
  static const ring = Color(0xFFC4973B);

  // ── Gold Shades ─────────────────────────────────────
  // from web: oklch(0.85 0.08 85)
  static const goldLight = Color(0xFFDCC590);
  // from web: oklch(0.55 0.12 85)
  static const goldDark = Color(0xFF8A6A1E);

  // ── Sage Shades ─────────────────────────────────────
  // from web: oklch(0.85 0.05 155)
  static const sageLight = Color(0xFFB5D4C0);

  // ── Star Rating ─────────────────────────────────────
  static const starFilled = primary; // gold stars, same as primary

  // ── Footer ──────────────────────────────────────────
  // from web: bg-foreground text-background → dark bg, cream text
  static const footerBackground = foreground;
  static const footerText = background;

  // ── Warning (Important Notice) ──────────────────────
  static const warningBackground = Color(0xFFFFF8E1); // amber-50/50
  static const warningBorder = Color(0xFFFFE082); // amber-200
  static const warningText = Color(0xFF6D4C00); // amber-800
  static const warningIcon = Color(0xFFE65100); // amber-600
}
