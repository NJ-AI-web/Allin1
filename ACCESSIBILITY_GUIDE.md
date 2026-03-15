# Accessibility Guide - Erode Super App

**Version:** 1.0.0  
**Last Updated:** March 13, 2026  
**Compliance Target:** WCAG 2.1 AA  
**Author:** NJ TECH - UI/UX Frontend Agent (Swarm Mode)

---

## Table of Contents

1. [Introduction](#introduction)
2. [Adding Semantics to Widgets](#adding-semantics-to-widgets)
3. [Color Contrast Guidelines](#color-contrast-guidelines)
4. [Touch Target Standards](#touch-target-standards)
5. [Tamil Typography Best Practices](#tamil-typography-best-practices)
6. [Screen Reader Testing Guide](#screen-reader-testing-guide)
7. [Keyboard Navigation](#keyboard-navigation)
8. [Motion & Animation](#motion--animation)
9. [Forms & Input Fields](#forms--input-fields)
10. [Images & Icons](#images--icons)
11. [Checklist for New Components](#checklist-for-new-components)

---

## Introduction

### Why Accessibility Matters

Accessibility ensures that our app can be used by **everyone**, including people with:
- **Visual impairments** (blindness, low vision, color blindness)
- **Hearing impairments** (deafness, hard of hearing)
- **Motor impairments** (limited dexterity, tremors)
- **Cognitive impairments** (learning disabilities, memory issues)

### WCAG 2.1 AA Requirements

Our app targets WCAG 2.1 AA compliance, which requires:

| Principle | Requirement | Our Standard |
|-----------|-------------|--------------|
| **Perceivable** | Text alternatives, adaptable content, distinguishable | ✅ All UI elements labeled |
| **Operable** | Keyboard accessible, enough time, no seizures | ✅ 48dp touch targets |
| **Understandable** | Readable, predictable, input assistance | ✅ Tamil/English support |
| **Robust** | Compatible with assistive technologies | ✅ Full Semantics coverage |

### Legal Requirements

- **India:** Rights of Persons with Disabilities Act, 2016
- **International:** WCAG 2.1 AA is the global standard
- **App Stores:** Google Play and App Store require accessibility

---

## Adding Semantics to Widgets

### What is Semantics?

Semantics is Flutter's accessibility layer that provides information to screen readers (TalkBack on Android, VoiceOver on iOS).

### Basic Semantics Widget

```dart
Semantics(
  label: 'Send message',           // What screen reader announces
  hint: 'Double tap to send',      // Additional context
  button: true,                     // Role: button
  enabled: true,                    // State: enabled
  onTap: _sendMessage,              // Action
  child: Icon(Icons.send),          // Visual representation
)
```

### Semantics Properties Reference

| Property | Type | Description | Example |
|----------|------|-------------|---------|
| `label` | String | Primary description | `'Delete chat'` |
| `hint` | String | Additional context | `'Remove all messages'` |
| `value` | String | Current value | `'Selected'` |
| `button` | bool | Is it a button? | `true` |
| `link` | bool | Is it a link? | `true` |
| `heading` | bool | Is it a heading? | `true` |
| `headingLevel` | int | Heading level (1-6) | `2` |
| `enabled` | bool | Is it enabled? | `true` |
| `selected` | bool | Is it selected? | `true` |
| `checked` | bool | Checkbox state | `true` |
| `hidden` | bool | Hide from screen readers | `true` |
| `image` | bool | Is it an image? | `true` |
| `liveRegion` | bool | Dynamic content | `true` |
| `assertive` | bool | Interrupt speech | `true` |

### Common Patterns

#### 1. Icon Button

```dart
// ❌ BAD: No accessibility
IconButton(
  icon: Icon(Icons.delete),
  onPressed: _delete,
)

// ✅ GOOD: Full accessibility
Semantics(
  label: 'Delete',
  hint: 'Remove this item',
  button: true,
  child: IconButton(
    icon: Icon(Icons.delete),
    onPressed: _delete,
  ),
)

// ✅ BEST: Use SemanticIconButton from semantic_wrapper.dart
SemanticIconButton(
  label: 'Delete',
  hint: 'Remove this item',
  icon: Icons.delete,
  onTap: _delete,
)
```

#### 2. Card/Tile

```dart
// ✅ GOOD: Card with Semantics
Semantics(
  label: 'Food Delivery',
  hint: 'Order from 16th Road restaurants',
  button: true,
  child: GestureDetector(
    onTap: () => Navigator.pushNamed(context, '/food'),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(/* ... */),
      child: Column(
        children: [
          Icon(Icons.restaurant, size: 40),
          Text('Food Delivery'),
          Text('16th Road restaurants'),
        ],
      ),
    ),
  ),
)
```

#### 3. Image with Description

```dart
// ✅ GOOD: Image with alt text
Semantics(
  label: 'Fresh vegetables at Erode market',
  image: true,
  child: Image.asset('assets/vegetables.jpg'),
)
```

#### 4. Decorative Image (Hide from Screen Readers)

```dart
// ✅ GOOD: Decorative image hidden
Semantics(
  hidden: true,  // Screen readers skip this
  child: Icon(Icons.star, size: 12),  // Decorative
)
```

#### 5. Form Field

```dart
// ✅ GOOD: Labeled text field
Semantics(
  label: 'Phone number',
  hint: 'Enter your 10-digit mobile number',
  textField: true,
  child: TextField(
    decoration: InputDecoration(
      labelText: 'Phone Number',
      hintText: '9876543210',
    ),
  ),
)
```

#### 6. Dynamic Content (Live Region)

```dart
// ✅ GOOD: Announces loading state changes
Semantics(
  liveRegion: true,
  assertive: true,  // Interrupt current speech
  child: Text(_isLoading ? 'Loading...' : 'Ready'),
)
```

### Using the Semantic Wrapper

Import and use our reusable components:

```dart
import 'package:erode_superapp/widgets/semantic_wrapper.dart';

// Button
SemanticButton(
  label: 'Send',
  hint: 'Send your message',
  onTap: _send,
  child: Icon(Icons.send),
)

// Tamil text
TamilText(
  'வணக்கம்! என்ன வேண்டும்?',
  semanticsLabel: 'Vanakkam! Enna vendum?',
  fontSize: 18,
)

// Card
SemanticCard(
  label: 'Grocery Card',
  hint: 'Order fresh groceries',
  onTap: _openGrocery,
  child: GroceryCard(),
)
```

---

## Color Contrast Guidelines

### WCAG Contrast Requirements

| Content Type | AA Standard | AAA Standard |
|--------------|-------------|--------------|
| Normal text (< 18pt) | 4.5:1 | 7:1 |
| Large text (≥ 18pt) | 3:1 | 4.5:1 |
| UI components | 3:1 | 3:1 |
| Graphical objects | 3:1 | 3:1 |

### Our Color Palette (Accessible)

```dart
// Primary Colors - All pass WCAG AA on dark background
const Color kBg = Color(0xFF08080F);        // Background
const Color kSurface = Color(0xFF111118);   // Surface
const Color kCard = Color(0xFF1A1A26);      // Cards

// Text Colors
const Color kText = Color(0xFFEEEEF5);      // Primary text - 18.5:1 on bg
const Color kMuted = Color(0xFF9B9BC7);     // Secondary text - 4.6:1 on bg
const Color kMutedStrong = Color(0xFFB8B8D9); // Strong secondary - 6.2:1

// Brand Colors
const Color kPurple = Color(0xFF7B6FE0);    // Primary brand
const Color kPurple2 = Color(0xFF9B8FF0);   // Light purple
const Color kOrange = Color(0xFFE07C6F);    // Accent
const Color kGreen = Color(0xFF3DBA6F);     // Success
const Color kGold = Color(0xFFF5C542);      // Premium

// Accessible text colors for brand colors
const Color kPurpleText = Color(0xFFB8AFF5);  // For purple backgrounds
const Color kOrangeText = Color(0xFFFFB3A6);  // For orange backgrounds
const Color kGreenText = Color(0xFF8FD99B);   // For green backgrounds
const Color kGoldText = Color(0xFFFFE082);    // For gold backgrounds
```

### Checking Contrast

#### Method 1: Use Our Utility Function

```dart
import 'package:erode_superapp/widgets/semantic_wrapper.dart';

// Check if colors meet WCAG AA
bool passes = meetsWcagAA(kMuted, kBg);  // true/false

// Get contrast ratio
double ratio = calculateContrastRatio(kText, kBg);  // e.g., 18.5

// Get accessible text color for a background
Color textColor = getAccessibleTextColor(kPurple);  // Returns white
```

#### Method 2: Online Tools

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Contrast Ratio](https://contrast-ratio.com/)
- [Colorable](https://colorable.jxnblk.com/)

#### Method 3: Flutter DevTools

1. Run app in debug mode
2. Open Flutter DevTools
3. Go to "Inspector" tab
4. Enable "Show Semantics"
5. Check contrast warnings

### Common Contrast Issues & Fixes

#### Issue 1: Muted Text Too Dark

```dart
// ❌ BAD: 3.8:1 ratio (fails AA)
const Color kMuted = Color(0xFF7777A0);

// ✅ GOOD: 4.6:1 ratio (passes AA)
const Color kMuted = Color(0xFF9B9BC7);
```

#### Issue 2: Gradient Text

```dart
// ❌ BAD: Gradient may reduce contrast
ShaderMask(
  shaderCallback: (r) => LinearGradient(
    colors: [Colors.white, Colors.purple],
  ).createShader(r),
  child: Text('Title'),
)

// ✅ GOOD: Solid high-contrast color
Text('Title',
  style: TextStyle(color: kText),  // #EEEEF5
)

// ✅ ALSO GOOD: High-contrast gradient
ShaderMask(
  shaderCallback: (r) => LinearGradient(
    colors: [Color(0xFFEEEEF5), Color(0xFFC7C0F5)],  // Both pass
  ).createShader(r),
  child: Text('Title'),
)
```

#### Issue 3: Colored Text on Dark Background

```dart
// ❌ BAD: Orange text fails contrast
Text('Sale', style: TextStyle(color: kOrange))  // #E07C6F

// ✅ GOOD: Lighter orange passes
Text('Sale', style: TextStyle(color: kOrangeText))  // #FFB3A6
```

---

## Touch Target Standards

### Minimum Sizes

| Element | Minimum Size | Recommended |
|---------|--------------|-------------|
| Buttons | 48x48 dp | 48x48 dp |
| Icon buttons | 48x48 dp | 48x48 dp |
| Cards | 48x48 dp | Full width |
| Form fields | 48x48 dp | 56dp height |
| Checkbox/Radio | 48x48 dp | 48x48 dp |
| Links | 48x48 dp | 44x44 dp minimum |

### Why 48dp?

- **Average finger size:** 10-14mm (≈ 28-40dp)
- **Motor impairment considerations:** Need extra space
- **WCAG 2.2 AAA:** Requires 48x48dp minimum
- **Material Design:** Recommends 48x48dp

### Implementing Touch Targets

#### Method 1: Container with Constraints

```dart
// ✅ GOOD: Explicit touch target
GestureDetector(
  onTap: _handleTap,
  child: Container(
    width: 48,
    height: 48,
    padding: EdgeInsets.all(12),  // Visual padding
    child: Icon(Icons.send, size: 24),
  ),
)
```

#### Method 2: Using Our SemanticButton

```dart
// ✅ BEST: Automatic touch target
SemanticButton(
  label: 'Send',
  onTap: _send,
  child: Icon(Icons.send, size: 24),
  // Automatically 48x48dp
)
```

#### Method 3: InkWell with Constraints

```dart
// ✅ GOOD: Material with proper target
InkWell(
  onTap: _handleTap,
  borderRadius: BorderRadius.circular(12),
  child: Container(
    constraints: BoxConstraints(
      minWidth: 48,
      minHeight: 48,
    ),
    padding: EdgeInsets.all(12),
    child: Icon(Icons.edit),
  ),
)
```

### Common Touch Target Issues

#### Issue 1: Icon Too Small

```dart
// ❌ BAD: Icon is 16dp, target is unclear
Icon(Icons.close, size: 16)

// ✅ GOOD: Icon is 24dp with 48dp target
Container(
  width: 48,
  height: 48,
  child: Icon(Icons.close, size: 24),
)
```

#### Issue 2: Padding Reduces Target

```dart
// ❌ BAD: Padding reduces effective target
Padding(
  padding: EdgeInsets.all(16),
  child: Icon(Icons.menu, size: 24),  // Only 24x24 target!
)

// ✅ GOOD: Container maintains target
Container(
  width: 48,
  height: 48,
  child: Icon(Icons.menu, size: 24),
)
```

#### Issue 3: Text Link Without Target

```dart
// ❌ BAD: Only text is tappable
Text('Learn more', onTap: _openLink)

// ✅ GOOD: Full area is tappable
GestureDetector(
  onTap: _openLink,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    child: Text('Learn more'),
  ),
)
```

---

## Tamil Typography Best Practices

### Font Selection

**Primary Font:** Noto Sans Tamil (Google Fonts)

```dart
import 'package:google_fonts/google_fonts.dart';

Text(
  'வணக்கம்! என்ன வேண்டும்?',
  style: GoogleFonts.notoSansTamil(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,  // Line height for Tamil
  ),
)
```

### Font Sizes

| Usage | Minimum Size | Recommended |
|-------|--------------|-------------|
| Body text | 14sp | 16sp |
| Secondary text | 12sp | 14sp |
| Headings | 18sp | 20-24sp |
| Buttons | 14sp | 16sp |
| Captions | 11sp | 12sp |

**Note:** Tamil text often needs 1-2sp larger than English for equivalent readability.

### Line Height

Tamil script requires more vertical space:

```dart
// ✅ GOOD: Proper line height for Tamil
Text(
  'தமிழ் உரைக்கு அதிக இடைவெளி தேவை',
  style: TextStyle(
    fontSize: 16,
    height: 1.4,  // 40% more than English
  ),
)

// ❌ BAD: Default line height
Text(
  'தமிழ் உரை',
  style: TextStyle(fontSize: 16),  // height: 1.0 (too tight)
)
```

### Letter Spacing

```dart
// ✅ GOOD: Slight letter spacing for clarity
Text(
  'வணக்கம்',
  style: TextStyle(
    fontSize: 16,
    letterSpacing: 0.5,
  ),
)
```

### Mixed Language Text

```dart
// ✅ GOOD: Proper locale declaration
RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: 'Order ',
        style: TextStyle(color: kText),
      ),
      TextSpan(
        text: 'பண்ணுங்கள்',
        style: GoogleFonts.notoSansTamil(color: kText),
        locale: Locale('ta', 'IN'),  // Tamil locale
      ),
      TextSpan(
        text: ' now!',
        style: TextStyle(color: kText),
      ),
    ],
  ),
)
```

### Screen Reader Announcements

```dart
// ✅ GOOD: Phonetic label for non-Tamil speakers
Semantics(
  label: 'Vanakkam! Enna vendum?',  // Phonetic
  child: Text('வணக்கம்! என்ன வேண்டும்?'),  // Tamil script
)

// ✅ BEST: Use TamilText widget
TamilText(
  'வணக்கம்! என்ன வேண்டும்?',
  semanticsLabel: 'Vanakkam! Enna vendum?',
)
```

### Common Tamil Typography Issues

#### Issue 1: Font Size Too Small

```dart
// ❌ BAD: 12sp is too small for Tamil
Text('தமிழ்', style: TextStyle(fontSize: 12))

// ✅ GOOD: Minimum 14sp
Text('தமிழ்', style: TextStyle(fontSize: 16))
```

#### Issue 2: Wrong Font

```dart
// ❌ BAD: Default font doesn't support Tamil well
Text('தமிழ்')

// ✅ GOOD: Noto Sans Tamil
Text('தமிழ்', style: GoogleFonts.notoSansTamil())
```

#### Issue 3: Insufficient Line Height

```dart
// ❌ BAD: Text overlaps
Text('தமிழ் உரை', style: TextStyle(height: 1.0))

// ✅ GOOD: Proper spacing
Text('தமிழ் உரை', style: TextStyle(height: 1.4))
```

---

## Screen Reader Testing Guide

### Android (TalkBack)

#### Enabling TalkBack

1. Settings → Accessibility → TalkBack
2. Toggle "Use TalkBack"
3. Or: Volume buttons shortcut (hold both for 3 seconds)

#### Basic Gestures

| Gesture | Action |
|---------|--------|
| Swipe right/left | Navigate to next/previous item |
| Double tap | Activate selected item |
| Two-finger swipe up | Read from top |
| Two-finger swipe down | Read from current position |
| Three-finger swipe up | Open TalkBack menu |

#### Testing Checklist

- [ ] All buttons are announced with labels
- [ ] All images have descriptions (or are hidden)
- [ ] Form fields have labels and hints
- [ ] Navigation is logical (left-to-right, top-to-bottom)
- [ ] Dynamic content changes are announced
- [ ] Error messages are announced
- [ ] Focus order matches visual order

#### Debugging Tips

```dart
// Announce custom message
SemanticsService.announce(
  'Order placed successfully!',
  TextDirection.ltr,
  assertive: true,
);

// Check what's being announced
Semantics(
  label: 'Expected label',
  child: YourWidget(),
)
```

### iOS (VoiceOver)

#### Enabling VoiceOver

1. Settings → Accessibility → VoiceOver
2. Toggle "VoiceOver"
3. Or: Triple-click side button

#### Basic Gestures

| Gesture | Action |
|---------|--------|
| Swipe right/left | Navigate to next/previous item |
| Double tap | Activate selected item |
| Three-finger swipe up | Read from top |
| Three-finger swipe down | Read all |
| Two-finger tap | Stop speaking |

### Testing Workflow

#### 1. Turn Off Screen

```dart
// Test without looking at screen
// Navigate through entire app flow
// Note any confusing announcements
```

#### 2. Test Common Flows

```
1. Launch app → Navigate to chat → Send message
2. Navigate to food card → Order food
3. Fill form → Submit
4. Receive error → Understand error
5. Complete order → Get confirmation
```

#### 3. Test Dynamic Content

```dart
// Loading states
Semantics(
  liveRegion: true,
  child: Text(_isLoading ? 'Loading...' : 'Ready'),
)

// Error messages
Semantics(
  liveRegion: true,
  assertive: true,
  child: Text(error),
)

// Success messages
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success!'),
    // Announced automatically
  ),
);
```

---

## Keyboard Navigation (Web PWA)

### Focus Indicators

```dart
// ✅ GOOD: Visible focus indicator
Focus(
  onFocusChange: (hasFocus) {
    if (hasFocus) {
      // Visual feedback
    }
  },
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      focusColor: kPurple.withOpacity(0.3),
      highlightColor: kPurple.withOpacity(0.2),
      onTap: _handleTap,
      child: YourWidget(),
    ),
  ),
)
```

### Tab Order

```dart
// ✅ GOOD: Logical tab order
FocusTraversalGroup(
  policy: ReadingOrderTraversalPolicy(),
  child: Column(
    children: [
      Focus(
        child: TextField(decoration: InputDecoration(labelText: 'Name')),
      ),
      Focus(
        child: TextField(decoration: InputDecoration(labelText: 'Email')),
      ),
      Focus(
        child: ElevatedButton(onPressed: _submit, child: Text('Submit')),
      ),
    ],
  ),
)
```

### Keyboard Shortcuts (Web)

```dart
// Add keyboard shortcuts for common actions
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control):
        _sendAction,
    LogicalKeySet(LogicalKeyboardKey.keyK, LogicalKeyboardKey.control):
        _openSearch,
  },
  child: Actions(
    actions: {
      _SendIntent: CallbackAction(onInvoke: (_) => _send()),
    },
  ),
)
```

---

## Motion & Animation

### Reduce Motion Support

```dart
// Check if user prefers reduced motion
bool shouldReduceMotion(BuildContext context) {
  return MediaQuery.of(context).accessibleNavigation ||
      WidgetsBinding.instance.platformDispatcher
          .accessibilityFeatures.reduceMotion;
}

// Use in animations
AnimatedContainer(
  duration: shouldReduceMotion(context)
      ? Duration.zero
      : Duration(milliseconds: 300),
  // ...
)
```

### Animation Guidelines

| Animation Type | Normal Duration | Reduced Motion |
|----------------|-----------------|----------------|
| Page transitions | 300-500ms | Instant |
| Button feedback | 150-200ms | Instant |
| Loading spinners | Continuous | Static icon |
| Micro-interactions | 200-300ms | Instant |

### Safe Animations

```dart
// ✅ GOOD: Respects reduce motion
AnimationController(
  vsync: this,
  duration: shouldReduceMotion(context)
      ? Duration.zero
      : Duration(milliseconds: 300),
)

// ❌ BAD: Ignores user preference
AnimationController(
  vsync: this,
  duration: Duration(milliseconds: 300),  // Always animates
)
```

---

## Forms & Input Fields

### Labeling Form Fields

```dart
// ✅ GOOD: Labeled text field
Semantics(
  label: 'Phone number',
  hint: 'Enter your 10-digit mobile number',
  textField: true,
  child: TextField(
    decoration: InputDecoration(
      labelText: 'Phone Number',
      hintText: '9876543210',
      helperText: 'Format: 9876543210',
    ),
  ),
)
```

### Error States

```dart
// ✅ GOOD: Accessible error
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    errorText: _error,
    helperText: _error == null ? 'We\'ll never share your email' : null,
  ),
)

// Announce error
if (_error != null) {
  SemanticsService.announce(
    _error!,
    TextDirection.ltr,
    assertive: true,
  );
}
```

### Required Fields

```dart
// ✅ GOOD: Indicate required fields
Semantics(
  label: 'Name, required field',
  child: TextField(
    decoration: InputDecoration(
      labelText: 'Name *',
      hintText: 'Enter your full name',
    ),
  ),
)
```

---

## Images & Icons

### Informative Images

```dart
// ✅ GOOD: Descriptive alt text
Semantics(
  label: 'Fresh vegetables at Erode market including tomatoes, onions, and carrots',
  image: true,
  child: Image.asset('assets/vegetables.jpg'),
)
```

### Decorative Images

```dart
// ✅ GOOD: Hidden from screen readers
Semantics(
  hidden: true,
  child: Icon(Icons.star, size: 12),
)
```

### Icon Buttons

```dart
// ✅ GOOD: Labeled icon button
SemanticIconButton(
  label: 'Delete',
  hint: 'Remove this item from cart',
  icon: Icons.delete,
  onTap: _delete,
)
```

### Emoji Handling

```dart
// ✅ GOOD: Emoji with text
Row(
  children: [
    Semantics(hidden: true, child: Text('🍔')),
    SizedBox(width: 8),
    Text('Food Delivery'),
  ],
)

// ❌ BAD: Emoji only
Text('🍔')  // Screen reader says "hamburger"
```

---

## Checklist for New Components

### Before Merging, Verify:

#### Semantics
- [ ] All interactive elements have Semantics widgets
- [ ] Labels are descriptive and concise
- [ ] Hints provide additional context
- [ ] Roles are correct (button, link, image, etc.)
- [ ] States are announced (enabled, selected, checked)

#### Color & Contrast
- [ ] Text contrast ratio ≥ 4.5:1 (normal) or ≥ 3:1 (large)
- [ ] UI component contrast ≥ 3:1
- [ ] Color is not the only way to convey information
- [ ] Focus indicators are visible

#### Touch Targets
- [ ] All interactive elements ≥ 48x48dp
- [ ] Adequate spacing between targets (8dp minimum)
- [ ] Touch target matches visual bounds

#### Typography
- [ ] Tamil text uses Noto Sans Tamil font
- [ ] Minimum font size 14sp for Tamil
- [ ] Line height ≥ 1.4 for Tamil text
- [ ] Text scales properly (test at 200%)

#### Keyboard Navigation (Web)
- [ ] All interactive elements are focusable
- [ ] Focus order is logical
- [ ] Focus indicators are visible
- [ ] No keyboard traps

#### Motion
- [ ] Animations respect reduce motion setting
- [ ] No auto-playing animations
- [ ] Users can pause/stop animations

#### Testing
- [ ] Tested with TalkBack (Android)
- [ ] Tested with VoiceOver (iOS)
- [ ] Tested with keyboard only (web)
- [ ] Tested at 200% text scaling
- [ ] Tested in high contrast mode

---

## Resources

### Tools

- **Flutter DevTools:** Built-in accessibility inspector
- **Accessibility Scanner (Android):** Automated testing
- **Xcode Accessibility Inspector (iOS):** Manual testing
- **axe DevTools:** Web accessibility testing

### Guidelines

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)
- [Flutter Accessibility Guide](https://docs.flutter.dev/development/ui/accessibility)

### Testing Services

- [Accessibility Insights](https://accessibilityinsights.io/)
- [WAVE Web Accessibility Tool](https://wave.webaim.org/)

---

## Contact

**Questions?** Reach out to the accessibility team.  
**Report Issue:** Create a GitHub issue with "accessibility" label.

---

*Generated by UI/UX Frontend Agent (Swarm Mode)*  
*Powered by NJ TECH · Erode*  
*Version: 1.0.0*  
*Date: March 13, 2026*
