# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

### Development Commands

```bash
# Use FVM for Flutter version consistency (team uses Flutter 3.32.5)
fvm flutter pub get              # Install dependencies
fvm flutter run                  # Run app in debug mode
fvm flutter run --release        # Run app in release mode
fvm flutter clean               # Clean build artifacts
```

### Quality Assurance Commands

```bash
fvm flutter analyze            # Static code analysis (strict mode enabled)
fvm flutter test              # Run all tests
fvm flutter doctor            # Check development environment
```

### iOS-specific Commands (macOS only)

```bash
cd ios && pod install && cd ..  # Install iOS dependencies after pubspec changes
```

## Architecture Overview

This is a Flutter-based handwriting note app built with a **feature-driven architecture** using **GoRouter** for navigation. The codebase has been recently refactored with a clean modular structure.

### Core Architecture Pattern

**Clean Feature Architecture:**

- **Features** (`lib/features/`): Self-contained modules for major functionality
- **Shared** (`lib/shared/`): Common utilities, services, and app-wide components
- **GoRouter-based navigation**: Centralized routing with feature-specific route definitions

### Feature Structure

Each feature follows a consistent structure:

```
lib/features/[feature_name]/
├── constants/     # Feature-specific constants
├── controllers/   # Business logic and state management
├── mixins/        # Reusable behavior mixins
├── models/        # Data models
├── notifiers/     # Custom notifiers and state providers
├── pages/         # Screen/page widgets
├── routing/       # Feature-specific routes
└── widgets/       # UI components
    ├── controls/  # Control widgets
    └── toolbar/   # Toolbar components
```

### Key Features

#### 1. Canvas System (`lib/features/canvas/`)

**Primary drawing and note editing functionality:**

- **Controllers**: `note_editor_controller.dart` manages drawing state and tool selection (currently commented for Provider migration)
- **Mixins**: `auto_save_mixin.dart` and `tool_management_mixin.dart` for cross-cutting concerns
- **Notifiers**: Custom extensions of Scribble library with `custom_scribble_notifier.dart` and `scribble_notifier_x.dart`
- **Comprehensive UI**: Modular toolbar system with separate components for colors, strokes, tools, and actions
- **Controls**: Pressure sensitivity, pointer mode, and viewport information widgets

#### 2. Note Management (`lib/features/notes/`)

**Note organization and listing:**

- **Models**: `note_model.dart` and `note_page_model.dart` for data structure
- **Data**: `fake_notes.dart` provides development data
- **Pages**: `note_list_screen.dart` for note browsing

#### 3. Home (`lib/features/home/`)

**Main navigation and entry point:**

- **Pages**: `home_screen.dart` as the main landing page
- **Routing**: Centralized home navigation

#### 4. Shared Infrastructure (`lib/shared/`)

**App-wide utilities and components:**

- **Routing**: `app_routes.dart` defines all route constants and type-safe navigation helpers
- **Services**: `file_picker_service.dart` for file operations
- **Widgets**: Reusable UI components like headers, cards, and navigation elements

### Navigation Architecture

**GoRouter-based routing** with feature separation:

- **Main router** (`lib/main.dart`): Combines routes from all features
- **Feature routes**: Each feature manages its own routes
- **Type-safe navigation**: `AppRoutes` class provides route constants and helper methods

### External Dependencies

- **Scribble**: Custom GitHub fork (main branch) for Apple Pencil pressure support
- **go_router**: v16.0.0 for declarative navigation
- **pdfx**: v2.5.0 for PDF viewing and interaction
- **file_picker**: v8.0.6 for file selection

### Development Standards

- **Dart SDK**: 3.8.1+ required
- **Strict linting**: Comprehensive analysis rules for code quality
- **Code style**: Single quotes, const constructors, final locals enforced
- **Documentation**: Public API documentation required (`public_member_api_docs: true`)
- **Import organization**: Relative imports preferred, directives ordering enforced

## Common Development Workflows

### Adding New Canvas Features

1. **Controllers**: Check existing controller patterns in `lib/features/canvas/controllers/`
2. **Mixins**: Use mixins for cross-cutting concerns (auto-save, tool management)
3. **Notifiers**: Extend existing custom notifiers for drawing behavior
4. **UI Components**: Add widgets to appropriate subdirectories (controls/, toolbar/)
5. **Constants**: Define feature constants in `note_editor_constant.dart`

### Working with Navigation

1. **Route Definition**: Add routes to feature-specific routing files
2. **Route Constants**: Define paths in `lib/shared/routing/app_routes.dart`
3. **Type-safe Navigation**: Use helper methods from `AppRoutes` class
4. **Main Router**: Routes are automatically included from feature route lists

### Adding New Features

1. **Create Feature Structure**: Follow the established pattern under `lib/features/[feature_name]/`
2. **Feature Routes**: Create routing file following existing patterns
3. **Register Routes**: Add feature routes to main router in `lib/main.dart`
4. **Shared Resources**: Add any shared components to `lib/shared/`

### Working with PDF Features

- PDF functionality is in `lib/features/canvas/pages/pdf_canvas_page.dart`
- Uses `pdfx` package for PDF rendering with canvas overlay
- File selection handled by shared `file_picker_service.dart`

## Testing Strategy

- Widget tests configured in `test/` directory
- Use `fvm flutter test` to run all tests
- Focus testing on canvas functionality and PDF integration as core features

## State Management Transition

**Note**: The project is transitioning to Provider for state management:

- Current controllers are commented for Provider migration
- Mixins provide reusable state management patterns
- Custom notifiers extend Scribble functionality

## Team Context

This is a 4-person team project (2 designers, 2 developers) building a handwriting note app over 8 weeks. The codebase was recently refactored to improve modularity and maintainability. Current focus is on canvas functionality and clean architecture patterns.
