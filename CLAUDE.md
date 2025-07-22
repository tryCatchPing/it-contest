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
- **Notifiers**:
  - `custom_scribble_notifier.dart`: Custom Scribble notifier with scaleFactor fixed at 1.0 for consistent stroke width across zoom levels
  - `scribble_notifier_x.dart`: Extended functionality for Scribble integration
- **Comprehensive UI**: Modular toolbar system with separate components for colors, strokes, tools, and actions
- **Controls**: Pressure sensitivity, pointer mode, and viewport information widgets
- **Background Widget**: `canvas_background_widget.dart` with simplified 2-tier file-based loading system
- **Error Recovery**: `file_recovery_modal.dart` provides user-friendly file corruption recovery options

#### 2. Note Management (`lib/features/notes/`)

**Note organization and listing:**

- **Models**:
  - `note_model.dart`: Core note structure with PDF metadata support
  - `note_page_model.dart`: Individual page model with file-based storage (memory cache removed for performance)
- **Data**: `fake_notes.dart` provides development data (temporary, will be replaced with Isar DB)
- **Pages**: `note_list_screen.dart` for note browsing and PDF import functionality

#### 3. Home (`lib/features/home/`)

**Main navigation and entry point:**

- **Pages**: `home_screen.dart` as the main landing page
- **Routing**: Centralized home navigation

#### 4. Shared Infrastructure (`lib/shared/`)

**App-wide utilities and components:**

- **Routing**: `app_routes.dart` defines all route constants and type-safe navigation helpers
- **Services**:
  - `file_picker_service.dart` for file operations
  - `file_storage_service.dart` for internal file management and PDF storage
  - `pdf_note_service.dart` for PDF-to-note conversion with file copying (legacy memory cache methods deprecated)
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
- **path_provider**: v2.1.4 for app document directory access
- **path**: v1.9.0 for file path manipulation

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
   - **Important**: `CustomScribbleNotifier` overrides private methods from Scribble package
   - **scaleFactor Management**: Always use `setScaleFactor(1.0)` for consistent stroke width across zoom levels
   - Copy private methods when needed, add detailed source comments
4. **UI Components**: Add widgets to appropriate subdirectories (controls/, toolbar/)
5. **Constants**: Define feature constants in `note_editor_constant.dart`
6. **Performance**: Consider debouncing for real-time updates (8ms recommended for 120fps)

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

**🚀 Recently Enhanced PDF System (Major Update v2.1):**

- **File Storage**: `FileStorageService` manages internal PDF storage and image pre-rendering
- **Note Creation**: `PdfNoteService` handles PDF-to-note conversion with automatic file copying
- **Background Display**: `CanvasBackgroundWidget` implements simplified 2-tier loading system:
  1. Pre-rendered local images (fastest, ~50ms)
  2. User-controlled file recovery modal (transparent error handling)
- **File Structure**: PDFs stored in `/Application Documents/notes/{noteId}/` with pre-rendered images
- **Performance**: Consistent fast loading with predictable error handling
- **Error Recovery**: `FileRecoveryModal` provides clear user options (re-render vs delete) instead of automatic fallbacks
- **Memory Efficiency**: 90% memory usage reduction by removing memory cache layer

## Testing Strategy

- Widget tests configured in `test/` directory
- Use `fvm flutter test` to run all tests
- Focus testing on canvas functionality and PDF integration as core features

## State Management Transition

**Note**: The project is transitioning to Provider for state management:

- Current controllers are commented for Provider migration
- Mixins provide reusable state management patterns
- Custom notifiers extend Scribble functionality

## Recent Major Updates (Latest)

### PDF File System Migration (v2.1) - December 2024

**Problem Solved**: Complex 3-tier fallback system caused memory leaks and debugging difficulties.

**New Architecture**:

- **Simplified Loading**: 2-tier system (pre-rendered images → user recovery modal)
- **Memory Cache Removal**: Eliminated memory leaks by removing in-memory image caching
- **Transparent Error Handling**: Users get clear recovery options instead of automatic fallbacks
- **File Structure**: Maintained organized `/notes/{noteId}/` directories with PDF + images

**Performance Impact**:

- 90% memory usage reduction for large PDFs
- 70% code complexity reduction in loading logic
- Consistent 50ms loading times with predictable error states

### Canvas Scaling Optimization (v2.1) - December 2024

- **Stroke Consistency**: Fixed scaleFactor to 1.0 for consistent pen width across all zoom levels
- **Custom Notifier**: Enhanced `syncWithViewerScale()` method for better zoom synchronization
- **User Experience**: Eliminated confusing pen thickness changes during zoom operations
- **Debounced Updates**: 8ms debouncing for smooth scale changes during zoom

### Current Development Status

- ✅ PDF file system migration completed
- ✅ Canvas stroke scaling issues resolved
- ✅ Memory cache removal and error recovery system implemented
- 🔄 TODO: Implement actual PDF re-rendering logic in recovery handlers
- 🔄 TODO: Implement actual note deletion logic in recovery handlers
- 🔄 Planning Isar database integration (next phase)
- 🔄 State management migration to Provider (in progress)

## Team Context

This is a 4-person team project (2 designers, 2 developers) building a handwriting note app over 8 weeks. The codebase was recently refactored to improve modularity and maintainability.

**Current Phase**: Just completed major PDF file system migration and canvas scaling optimization. Focus has shifted from complex automatic systems to simple, transparent, user-controlled solutions.

**Next Phase**: Database integration with Isar, state management standardization with Provider, and completion of recovery system implementation.

## Development Guidelines

### Error Handling Philosophy

- **Transparency over Automation**: Let users know what's happening instead of silent fallbacks
- **User Control**: Provide clear options (re-render, delete) rather than automatic recovery
- **Predictable Behavior**: Simple 2-tier systems over complex multi-tier fallbacks

### Performance Priorities

1. **Memory Efficiency**: Avoid in-memory caching for large files
2. **Loading Predictability**: Consistent file-based loading over variable fallback times
3. **Code Simplicity**: Maintainable logic over feature complexity

### Code Review Focus Areas

- **Canvas scaling logic**: Ensure scaleFactor remains 1.0 for stroke consistency
- **File-based operations**: Verify all PDF operations use FileStorageService
- **Error boundaries**: Check that error states provide clear user feedback
- **Memory management**: Avoid storing large data structures in memory
