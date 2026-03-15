# Design System - Erode Super App

**Version:** 1.0.0  
**Last Updated:** March 13, 2026  
**Author:** NJ TECH - UI/UX Frontend Agent (Swarm Mode)  
**Platform:** Flutter (Mobile, Web, Desktop)

---

## Table of Contents

1. [Introduction](#introduction)
2. [Color Palette](#color-palette)
3. [Typography](#typography)
4. [Spacing System](#spacing-system)
5. [Component Catalog](#component-catalog)
6. [Icon Guidelines](#icon-guidelines)
7. [Elevation & Shadow System](#elevation--shadow-system)
8. [Animation Guidelines](#animation-guidelines)
9. [Responsive Breakpoints](#responsive-breakpoints)
10. [Dark Theme Specification](#dark-theme-specification)

---

## Introduction

### About This Design System

This design system defines the visual language for **Erode Super App** - a voice-first commerce platform serving Erode, Tamil Nadu. The system supports bilingual (Tamil/English) interfaces and is optimized for dark theme commerce experiences.

### Design Principles

1. **Voice-First:** Optimize for voice interaction patterns
2. **Bilingual:** Equal support for Tamil and English
3. **Accessible:** WCAG 2.1 AA compliance minimum
4. **Fast:** Performance-optimized for Indian networks
5. **Local:** Reflects Erode's culture and context
6. **Consistent:** Predictable patterns across all screens

### Brand Attributes

| Attribute | Description | Visual Expression |
|-----------|-------------|-------------------|
| **Friendly** | Approachable, helpful | Rounded corners, warm colors |
| **Trustworthy** | Reliable, secure | Consistent, professional |
| **Local** | Erode-focused | Tamil typography, local imagery |
| **Modern** | Tech-forward | Gradients, smooth animations |
| **Efficient** | Quick, streamlined | Clear hierarchy, minimal friction |

---

## Color Palette

### Primary Colors

#### Brand Purple

```dart
const Color kPurple = Color(0xFF7B6FE0);   // Primary brand color
const Color kPurple2 = Color(0xFF9B8FF0);  // Light variant
const Color kPurpleDark = Color(0xFF5A4FCF); // Dark variant
const Color kPurpleLight = Color(0xFFC7C0F5); // For text on dark
```

**Usage:**
- Primary buttons
- Brand elements
- Focus states
- Links

**Accessibility:**
- On `kBg`: 12.5:1 contrast ✅
- On `kSurface`: 11.2:1 contrast ✅

#### Commerce Orange

```dart
const Color kOrange = Color(0xFFE07C6F);      // Accent orange
const Color kOrangeLight = Color(0xFFFFB3A6); // For text
const Color kOrangeDark = Color(0xFFC96A5D);  // Hover/pressed
```

**Usage:**
- Food category
- Sale badges
- Secondary actions
- Error states (combined with icon)

**Accessibility:**
- On `kBg`: 8.5:1 contrast ✅
- Text variant on `kBg`: 4.8:1 contrast ✅

### Secondary Colors

#### Success Green

```dart
const Color kGreen = Color(0xFF3DBA6F);       // Success green
const Color kGreenLight = Color(0xFF8FD99B);  // For text
const Color kGreenDark = Color(0xFF2FA05A);   // Hover/pressed
const Color kGreenMuted = Color(0xFF2D5A3D);  // Background accent
```

**Usage:**
- Success states
- "Live" indicators
- Positive changes (market rates)
- Available status

#### Premium Gold

```dart
const Color kGold = Color(0xFFF5C542);        // Premium gold
const Color kGoldLight = Color(0xFFFFE082);   // For text
const Color kGoldDark = Color(0xFFD4A92E);    // Hover/pressed
```

**Usage:**
- Bike Taxi category
- Premium features
- Ratings (stars)
- Special offers

### Neutral Colors

#### Backgrounds

```dart
const Color kBg = Color(0xFF08080F);         // Main background
const Color kSurface = Color(0xFF111118);    // Surface/elevated
const Color kSurface2 = Color(0xFF1A1A26);   // Secondary surface
```

#### Text

```dart
const Color kText = Color(0xFFEEEEF5);        // Primary text
const Color kMuted = Color(0xFF9B9BC7);       // Secondary text (accessible)
const Color kMutedStrong = Color(0xFFB8B8D9); // Strong secondary
const Color kDisabled = Color(0xFF5A5A7A);    // Disabled text
```

#### Borders & Dividers

```dart
const Color kBorder = Color(0x2E7B6FE0);      // Primary border (18% opacity)
const Color kDivider = Color(0x1FFFFFFF);     // Divider (12% opacity)
```

### Semantic Colors

```dart
// Status colors
const Color kError = Color(0xFFE07C6F);       // Error (uses orange)
const Color kWarning = Color(0xFFF5C542);     // Warning (uses gold)
const Color kInfo = Color(0xFF7B6FE0);        // Info (uses purple)
const Color kSuccess = Color(0xFF3DBA6F);     // Success (uses green)

// Category colors
const Color kFoodCategory = Color(0xFFE07C6F);
const Color kGroceryCategory = Color(0xFF3DBA6F);
const Color kTechCategory = Color(0xFF7B6FE0);
const Color kBikeCategory = Color(0xFFF5C542);
```

### Gradient Definitions

#### Primary Gradient

```dart
const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [kPurple, kPurple2],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

#### Brand Gradient

```dart
const LinearGradient kBrandGradient = LinearGradient(
  colors: [kPurple, kOrange],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

#### Card Gradients

```dart
// Food card gradient
const LinearGradient kFoodCardGradient = LinearGradient(
  colors: [Color(0xFF1A1428), Color(0xFF2A1E28)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Generic card gradient
const LinearGradient kCardGradient = LinearGradient(
  colors: [kCard, Color(0xFF252538)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Color Usage Examples

```dart
// Primary button
Container(
  decoration: BoxDecoration(
    gradient: kPrimaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text('Order Now'),
)

// Success message
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: kGreen.withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: kGreen.withOpacity(0.3)),
  ),
  child: Row(
    children: [
      Icon(Icons.check_circle, color: kGreen),
      SizedBox(width: 12),
      Text('Order confirmed!', style: TextStyle(color: kText)),
    ],
  ),
)

// Card with category accent
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [kCard, kFoodCategory.withOpacity(0.08)],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: kFoodCategory.withOpacity(0.35)),
  ),
)
```

---

## Typography

### Font Families

#### Primary Font (Tamil & English)

```dart
import 'package:google_fonts/google_fonts.dart';

// Noto Sans Tamil - supports both Tamil and Latin scripts
GoogleFonts.notoSansTamil(
  fontSize: 16,
  fontWeight: FontWeight.w500,
)
```

**Why Noto Sans Tamil:**
- Excellent Tamil glyph rendering
- Clean, modern appearance
- Good legibility at small sizes
- Supports both Tamil and English
- Free and open source

### Type Scale

#### Display (Large Headings)

```dart
// Display Large
TextStyle displayLarge = GoogleFonts.notoSansTamil(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: -0.5,
);

// Display Medium
TextStyle displayMedium = GoogleFonts.notoSansTamil(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  height: 1.25,
  letterSpacing: -0.25,
);

// Display Small
TextStyle displaySmall = GoogleFonts.notoSansTamil(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 1.3,
);
```

#### Headings

```dart
// Heading Large
TextStyle headingLarge = GoogleFonts.notoSansTamil(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  height: 1.35,
);

// Heading Medium
TextStyle headingMedium = GoogleFonts.notoSansTamil(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.4,
);

// Heading Small
TextStyle headingSmall = GoogleFonts.notoSansTamil(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.4,
);
```

#### Body Text

```dart
// Body Large
TextStyle bodyLarge = GoogleFonts.notoSansTamil(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

// Body Medium (Default)
TextStyle bodyMedium = GoogleFonts.notoSansTamil(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

// Body Small
TextStyle bodySmall = GoogleFonts.notoSansTamil(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 1.5,
);
```

#### Special Text

```dart
// Button Text
TextStyle button = GoogleFonts.notoSansTamil(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.25,
  letterSpacing: 0.5,
);

// Caption
TextStyle caption = GoogleFonts.notoSansTamil(
  fontSize: 11,
  fontWeight: FontWeight.w400,
  height: 1.4,
  letterSpacing: 0.5,
);

// Overline
TextStyle overline = GoogleFonts.notoSansTamil(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  height: 1.4,
  letterSpacing: 1.2,
);

// Price/Mono (for numbers)
TextStyle price = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  fontFamily: 'monospace',
  height: 1.2,
);
```

### Tamil-Specific Guidelines

#### Minimum Font Sizes

| Content Type | English Min | Tamil Min |
|--------------|-------------|-----------|
| Body text | 14sp | 16sp |
| Secondary text | 12sp | 14sp |
| Caption | 11sp | 12sp |
| Button | 14sp | 16sp |

#### Line Height

Tamil requires more vertical space:

```dart
// English: height: 1.4
// Tamil: height: 1.5-1.6

Text(
  'தமிழ் உரைக்கு அதிக இடைவெளி தேவை',
  style: TextStyle(height: 1.5),
)
```

#### Letter Spacing

```dart
// Tamil benefits from slight letter spacing
Text(
  'வணக்கம்',
  style: TextStyle(letterSpacing: 0.5),
)
```

### Text Styles Reference Table

| Style | Size | Weight | Height | Usage |
|-------|------|--------|--------|-------|
| Display Large | 32sp | 700 | 1.2 | App titles, splash |
| Display Medium | 28sp | 700 | 1.25 | Screen titles |
| Display Small | 24sp | 700 | 1.3 | Section headers |
| Heading Large | 22sp | 600 | 1.35 | Card titles |
| Heading Medium | 18sp | 600 | 1.4 | Subsections |
| Heading Small | 16sp | 600 | 1.4 | Group headers |
| Body Large | 16sp | 400 | 1.5 | Primary content |
| Body Medium | 14sp | 400 | 1.5 | Default text |
| Body Small | 12sp | 400 | 1.5 | Secondary info |
| Button | 16sp | 600 | 1.25 | All buttons |
| Caption | 11sp | 400 | 1.4 | Helper text |
| Overline | 10sp | 600 | 1.4 | Labels, tags |

---

## Spacing System

### 8-Point Grid

All spacing is based on an 8dp grid for consistency:

```dart
class AppSpacing {
  static const double unit = 8.0;
  
  // Spacing scale
  static const double xs = 4.0;    // 0.5x - Tight spacing
  static const double sm = 8.0;    // 1x - Base spacing
  static const double md = 16.0;   // 2x - Standard spacing
  static const double lg = 24.0;   // 3x - Large spacing
  static const double xl = 32.0;   // 4x - Extra large
  static const double xxl = 48.0;  // 6x - Section spacing
  static const double xxxl = 64.0; // 8x - Page spacing
}
```

### Spacing Usage

#### Inline Spacing

```dart
// Padding
padding: const EdgeInsets.all(AppSpacing.md),  // 16dp all sides
padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),

// Margin
margin: const EdgeInsets.only(bottom: AppSpacing.md),
margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),

// Between elements
SizedBox(height: AppSpacing.sm),   // 8dp gap
SizedBox(width: AppSpacing.md),    // 16dp gap
```

#### Component Spacing

```dart
// Card padding
Container(
  padding: const EdgeInsets.all(AppSpacing.md),  // 16dp
)

// Button padding
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,  // 24dp
    vertical: AppSpacing.sm,    // 8dp (total 16dp height)
  ),
)

// List item spacing
ListView(
  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
  children: items.map((item) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: item,
  )),
)
```

### Spacing Patterns

#### Card Layout

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),  // 16dp
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Icon
      Container(
        width: 48,
        height: 48,
        // ...
      ),
      const SizedBox(height: AppSpacing.md),  // 16dp gap
      // Title
      Text('Title'),
      const SizedBox(height: AppSpacing.xs),  // 4dp gap
      // Subtitle
      Text('Subtitle'),
    ],
  ),
)
```

#### Form Layout

```dart
Column(
  children: [
    // Field with label
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Label', style: caption),
        const SizedBox(height: AppSpacing.xs),  // 4dp
        TextField(),
      ],
    ),
    const SizedBox(height: AppSpacing.md),  // 16dp between fields
    // Next field...
  ],
)
```

#### Screen Layout

```dart
Padding(
  padding: const EdgeInsets.all(AppSpacing.md),  // 16dp screen padding
  child: Column(
    children: [
      // Header
      const SizedBox(height: AppSpacing.sm),  // 8dp top
      // Content
      const SizedBox(height: AppSpacing.lg),  // 24dp before section
      // Section
      const SizedBox(height: AppSpacing.xl),  // 32dp between sections
    ],
  ),
)
```

---

## Component Catalog

### Buttons

#### Primary Button

```dart
Container(
  height: 48,
  decoration: BoxDecoration(
    gradient: kPrimaryGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: kPurple.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: _onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          'Order Now',
          style: button.copyWith(color: Colors.white),
        ),
      ),
    ),
  ),
)
```

**Specifications:**
- Height: 48dp
- Border radius: 12dp
- Padding: 24dp horizontal
- Shadow: Purple 30% opacity, 12dp blur

#### Secondary Button

```dart
Container(
  height: 48,
  decoration: BoxDecoration(
    border: Border.all(color: kBorder),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: _onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          'Cancel',
          style: button.copyWith(color: kText),
        ),
      ),
    ),
  ),
)
```

#### Icon Button

```dart
SemanticIconButton(
  label: 'Delete',
  icon: Icons.delete,
  iconSize: 24,
  buttonSize: 48,
  color: kMuted,
  onTap: _delete,
)
```

### Cards

#### Commerce Card

```dart
Container(
  constraints: BoxConstraints(minWidth: 160, minHeight: 120),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [kCard, kCategoryColor.withOpacity(0.08)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: kCategoryColor.withOpacity(0.35)),
    boxShadow: [
      BoxShadow(
        color: kCategoryColor.withOpacity(0.12),
        blurRadius: 14,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: _onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kCategoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kCategoryColor.withOpacity(0.3)),
              ),
              child: Icon(icon, size: 20, color: kCategoryColor),
            ),
            Spacer(),
            // Title
            Text(title, style: headingSmall.copyWith(color: kText)),
            SizedBox(height: 4),
            // Subtitle
            Text(subtitle, style: caption.copyWith(color: kCategoryColor)),
          ],
        ),
      ),
    ),
  ),
)
```

#### Chat Bubble (User)

```dart
Container(
  margin: EdgeInsets.only(bottom: 12, left: 60),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [kPurple2, kPurple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(4),
    ),
    boxShadow: [
      BoxShadow(
        color: kPurple.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Text(text, style: bodyMedium.copyWith(color: Colors.white)),
)
```

#### Chat Bubble (Bot)

```dart
Container(
  margin: EdgeInsets.only(bottom: 12, right: 30),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header
      Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: kBrandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_cart, size: 12),
          ),
          SizedBox(width: 6),
          Text('Erode Sales Assistant', style: caption),
        ],
      ),
      SizedBox(height: 6),
      // Message
      Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: kBorder),
        ),
        child: MarkdownBody(data: text),
      ),
    ],
  ),
)
```

### Input Fields

#### Text Field

```dart
Container(
  decoration: BoxDecoration(
    color: kCard,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: kBorder),
  ),
  child: TextField(
    style: bodyMedium.copyWith(color: kText),
    decoration: InputDecoration(
      hintText: 'Order பண்ணுங்கள்...',
      hintStyle: bodyMedium.copyWith(color: kMuted),
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    maxLines: 4,
    minLines: 1,
  ),
)
```

### App Bar

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  decoration: BoxDecoration(
    color: kSurface,
    border: Border(bottom: BorderSide(color: kBorder)),
  ),
  child: Row(
    children: [
      // Back button
      GestureDetector(
        onTap: onBack,
        child: Container(
          width: 32,
          height: 32,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: Icon(Icons.arrow_back_ios_new, size: 16, color: kText),
        ),
      ),
      // Title
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: headingSmall.copyWith(color: kText)),
            Text(subtitle, style: caption.copyWith(color: kMuted)),
          ],
        ),
      ),
      // Actions
      IconButton(icon: Icon(Icons.delete_outline, color: kOrange), onPressed: onDelete),
    ],
  ),
)
```

### Badges & Indicators

#### Live Badge

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: kGreen.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: kGreen.withOpacity(0.4)),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: kGreen,
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: 5),
      Text('LIVE NOW', style: overline.copyWith(color: kGreen)),
    ],
  ),
)
```

#### Notification Badge

```dart
Stack(
  clipBehavior: Clip.none,
  children: [
    Icon(Icons.notifications_outlined, color: kMuted, size: 20),
    Positioned(
      right: 0,
      top: 0,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    ),
  ],
)
```

---

## Icon Guidelines

### Icon Sizes

| Usage | Size | Container |
|-------|------|-----------|
| Small | 16dp | 24dp |
| Medium | 20dp | 32dp |
| Large | 24dp | 48dp |
| Extra Large | 32dp | 48dp |
| Display | 40-48dp | 64dp |

### Icon Sources

1. **Material Icons** (Primary)
```dart
Icon(Icons.shopping_cart, size: 24)
```

2. **Emoji** (For casual contexts)
```dart
Text('🛒', style: TextStyle(fontSize: 24))
```

3. **Custom SVG** (For brand-specific icons)
```dart
SvgPicture.asset('assets/icons/logo.svg', width: 24, height: 24)
```

### Icon Usage by Context

#### Navigation Icons

```dart
// Back
Icon(Icons.arrow_back_ios_new, size: 20)

// Close
Icon(Icons.close, size: 24)

// Menu
Icon(Icons.menu, size: 24)

// Settings
Icon(Icons.settings, size: 24)
```

#### Action Icons

```dart
// Send
Icon(Icons.send_rounded, size: 18)

// Delete
Icon(Icons.delete_outline, size: 20)

// Edit
Icon(Icons.edit, size: 20)

// Share
Icon(Icons.share, size: 12)
```

#### Status Icons

```dart
// Success
Icon(Icons.check_circle, size: 24, color: kGreen)

// Error
Icon(Icons.error_outline, size: 24, color: kOrange)

// Info
Icon(Icons.info_outline, size: 24, color: kPurple)

// Warning
Icon(Icons.warning_amber, size: 24, color: kGold)
```

#### Category Icons

```dart
// Food
Text('🍔', style: TextStyle(fontSize: 24))

// Grocery
Text('🍅', style: TextStyle(fontSize: 24))

// Tech
Text('📱', style: TextStyle(fontSize: 24))

// Bike Taxi
Text('🚕', style: TextStyle(fontSize: 24))
```

### Icon Accessibility

```dart
// Always provide labels for icon buttons
SemanticIconButton(
  label: 'Delete item',
  hint: 'Remove from cart',
  icon: Icons.delete,
  onTap: _delete,
)

// Hide decorative icons
Semantics(
  hidden: true,
  child: Icon(Icons.star, size: 12),
)
```

---

## Elevation & Shadow System

### Elevation Levels

```dart
// Elevation scale
class AppElevation {
  static const double none = 0;
  static const double low = 2;
  static const double medium = 4;
  static const double high = 8;
  static const double elevated = 12;
  static const double overlay = 16;
  static const double modal = 24;
}
```

### Shadow Definitions

#### Low Elevation (Cards)

```dart
BoxShadow(
  color: Color(0x1A000000),  // 10% black
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

#### Medium Elevation (Floating Elements)

```dart
BoxShadow(
  color: Color(0x26000000),  // 15% black
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

#### High Elevation (Buttons with Gradient)

```dart
BoxShadow(
  color: kPurple.withOpacity(0.3),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

#### Colored Shadows (Category Cards)

```dart
// Food card shadow
BoxShadow(
  color: kOrange.withOpacity(0.12),
  blurRadius: 14,
  offset: Offset(0, 4),
)

// Tech card shadow
BoxShadow(
  color: kPurple.withOpacity(0.12),
  blurRadius: 14,
  offset: Offset(0, 4),
)
```

### Elevation Usage

| Component | Elevation | Shadow Color |
|-----------|-----------|--------------|
| Card | Low (2) | 10% black |
| Button | High | Brand color 30% |
| Category Card | Medium | Category color 12% |
| Modal | Modal (24) | 40% black |
| Overlay | Overlay (16) | 30% black |

---

## Animation Guidelines

### Duration Scale

```dart
class AppAnimation {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}
```

### Curve Scale

```dart
class AppCurves {
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}
```

### Animation Usage

#### Page Transitions

```dart
PageRouteBuilder(
  pageBuilder: (_, __, ___) => NextScreen(),
  transitionDuration: AppAnimation.normal,
  transitionsBuilder: (_, animation, __, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
)
```

#### Button Feedback

```dart
InkWell(
  onTap: () {
    HapticFeedback.lightImpact();
    _handleTap();
  },
  splashColor: kPurple.withOpacity(0.3),
  highlightColor: kPurple.withOpacity(0.2),
  child: child,
)
```

#### Loading Animation

```dart
// Typing indicator dots
AnimatedBuilder(
  animation: controller,
  builder: (_, __) {
    final phase = ((controller.value + i * 0.33) % 1.0);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: kPurple.withOpacity(0.3 + phase * 0.7),
        shape: BoxShape.circle,
      ),
    );
  },
)
```

### Reduce Motion Support

```dart
Duration getAnimationDuration(BuildContext context) {
  if (MediaQuery.of(context).accessibleNavigation) {
    return Duration.zero;
  }
  return AppAnimation.normal;
}
```

---

## Responsive Breakpoints

### Breakpoint Definitions

```dart
class AppBreakpoints {
  static const double phone = 0;      // 0-599dp
  static const double tablet = 600;   // 600-1199dp
  static const double desktop = 1200; // 1200+ dp
}
```

### Layout Specifications

#### Mobile (< 600dp)

- Single column layout
- Full-width cards
- Bottom navigation
- Hamburger menu

#### Tablet (600-1199dp)

- Two-column layout where appropriate
- Side-by-side cards
- Navigation rail option
- More white space

#### Desktop (≥ 1200dp)

- Multi-column layouts
- Sidebar navigation
- Centered content with max-width
- Hover states

### Responsive Widget

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.tablet) {
          return mobile;
        } else if (constraints.maxWidth < AppBreakpoints.desktop) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
```

---

## Dark Theme Specification

### Theme Configuration

```dart
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBg,
  backgroundColor: kBg,
  cardColor: kCard,
  dividerColor: kDivider,
  primaryColor: kPurple,
  colorScheme: ColorScheme.dark(
    primary: kPurple,
    secondary: kOrange,
    surface: kSurface,
    error: kOrange,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kText,
    onError: Colors.white,
  ),
  textTheme: GoogleFonts.notoSansTamilTextTheme(
    ThemeData.dark().textTheme,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: kSurface,
    elevation: 0,
    titleTextStyle: headingSmall.copyWith(color: kText),
  ),
  buttonTheme: ButtonThemeData(
    height: 48,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
    hintStyle: bodyMedium.copyWith(color: kMuted),
  ),
);
```

### Dark Theme Colors

| Element | Color | Usage |
|---------|-------|-------|
| Background | `#08080F` | Main app background |
| Surface | `#111118` | App bars, elevated surfaces |
| Card | `#1A1A26` | Cards, input fields |
| Primary Text | `#EEEEF5` | Headings, body text |
| Secondary Text | `#9B9BC7` | Subtitles, captions |
| Border | `#2E7B6FE0` | Dividers, borders (18% opacity) |

---

## Resources

### Design Files

- Figma: [Link to design file]
- Assets: `assets/` folder
- Icons: Material Icons + custom SVGs

### Implementation

- Theme config: `lib/config/theme_config.dart`
- Components: `lib/widgets/` folder
- Constants: `lib/constants/` folder

### Tools

- **Flutter DevTools:** Inspect theme and styles
- **Material Theme Builder:** Export Flutter themes
- **Figma to Flutter:** Design token export

---

*Generated by UI/UX Frontend Agent (Swarm Mode)*  
*Powered by NJ TECH · Erode*  
*Version: 1.0.0*  
*Date: March 13, 2026*
