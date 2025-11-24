import 'package:flutter/material.dart';

class AppPaddings {
  AppPaddings._(); // Private constructor to prevent instantiation

  // Standard Paddings
  static const EdgeInsets xs = EdgeInsets.all(4);
  static const EdgeInsets sm = EdgeInsets.all(8);
  static const EdgeInsets md = EdgeInsets.all(16);
  static const EdgeInsets lg = EdgeInsets.all(24);
  static const EdgeInsets xl = EdgeInsets.all(32);

  // Horizontal Paddings
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: 32);

  // Vertical Paddings
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: 4);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: 24);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: 32);

  // Screen Paddings
  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: 16);

  // Card Paddings
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(12);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(24);

  // List Item Paddings
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets listItemPaddingSmall = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
}

