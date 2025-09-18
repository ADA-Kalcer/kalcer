# Technical Overview

Architecture and implementation details for developers working with the
Arca codebase.

## Overview

Arca is built using modern iOS development practices with SwiftUI, Core
Data, and location services integration for creating an immersive cultural
exploration experience.

## Architecture

### Design Pattern
The app follows **MVVM (Model-View-ViewModel)** architecture:
- **Models**: Core Data entities and business logic
- **Views**: SwiftUI interface components
- **ViewModels**: Data binding and state management
- **Services**: Specialized functionality (location, audio, data)

### Key Frameworks
- **SwiftUI**: User interface and navigation
- **Core Data**: Local data persistence and management
- **Core Location**: GPS tracking and geofencing
- **AVFoundation**: Audio playback and mixing
- **MapKit**: Map display and annotation management

## Core Components

### Data Layer
Core Data entities form the foundation of data persistence:

StatueEntity: Statue information and metadata
BookmarkEntity: User's saved statues
AudioContentEntity: Cached audio content
UserPreferencesEntity: App settings and preferences

### Location Services
- **Real-time tracking**: Continuous location updates for proximity
detection
- **Geofencing**: Automatic statue discovery as users move through areas
- **Background processing**: Location updates when app is inactive
- **Battery optimization**: Adaptive location accuracy based on user
context

### Audio System
- **Background compatibility**: Seamlessly works with music apps
- **Audio mixing**: Automatic volume ducking for clear narration
- **Content caching**: Offline audio storage for reliable playback
- **Interruption handling**: Graceful handling of calls and system audio

## Development Setup

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Apple Developer account (for location services testing)

### Getting Started
1. Clone the repository
2. Open `Arca.xcodeproj` in Xcode
3. Configure signing with your development team
4. Build and run on physical device (location services require hardware)

### Configuration
- **Info.plist**: Location usage descriptions and permissions
- **Entitlements**: Background modes and CloudKit capabilities
- **Build Settings**: Swift language version and deployment targets


## Topics

### Implementation Details
- <doc:Implementation> - Detailed implementation examples and patterns

### API Reference
- ``StatueModel`` - Core statue data structure
- ``LocationManager`` - Location services implementation
- ``AudioManager`` - Audio system architecture
- ``BookmarkService`` - User data management
