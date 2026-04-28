# Core Architecture - SOLID Principles

This directory follows Clean Architecture and SOLID principles to ensure maintainability, testability, and scalability.

## Directory Structure

```
core/
├── domain/           # Business logic layer (no dependencies on frameworks)
│   ├── entities/     # Pure business objects
│   ├── repositories/ # Abstract repository interfaces
│   └── services/     # Business logic service interfaces
├── data/             # Data access layer
│   ├── datasources/  # Concrete data source implementations
│   ├── models/       # Data transfer objects
│   ├── repositories/ # Repository implementations
│   └── services/     # Service implementations
├── presentation/     # UI state management
│   └── providers/    # State management (ChangeNotifier, etc.)
├── di/               # Dependency injection
│   └── dependency_injection.dart
└── config/           # App configuration
```

## SOLID Principles Applied

### 1. Single Responsibility Principle (SRP)
Each class has one reason to change:
- **Entities**: Pure data, no logic
- **Services**: Single business logic concern (e.g., color generation, category mapping)
- **Repositories**: Data coordination only
- **Providers**: UI state management only
- **Datasources**: Data access only

### 2. Open/Closed Principle (OCP)
- Classes are open for extension but closed for modification
- New datasources can be added without modifying repositories
- New services can be added without changing existing code

### 3. Liskov Substitution Principle (LSP)
- Any implementation can be substituted with another
- FirebaseToolDatasource can be replaced with MockToolDatasource for testing

### 4. Interface Segregation Principle (ISP)
- Small, focused interfaces
- Clients depend only on methods they use
- Example: ToolRepository has only methods needed by providers

### 5. Dependency Inversion Principle (DIP)
- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces)
- Example: Provider depends on ToolRepository (interface), not ToolRepositoryImpl

## Layer Responsibilities

### Domain Layer
- **Entities**: Pure business objects (ToolEntity, CategoryEntity)
- **Repository Interfaces**: Define data operations contracts
- **Service Interfaces**: Define business logic contracts
- **No dependencies** on Flutter, Firebase, or other frameworks

### Data Layer
- **Datasources**: Concrete implementations (Firebase, REST, etc.)
- **Models**: Data transfer objects for mapping
- **Repository Implementations**: Coordinate between datasources and services
- **Service Implementations**: Business logic (color generation, category mapping)

### Presentation Layer
- **Providers**: UI state management using ChangeNotifier
- **No business logic** - delegates to repositories and services

### Dependency Injection
- Centralized dependency configuration
- Follows DIP by injecting abstractions
- Easy to swap implementations for testing

## Migration Notes

The old `core/models/tool_model.dart` and `core/providers/tool_provider.dart` are being replaced with:
- `core/domain/entities/` - Pure business entities
- `core/data/repositories/` - Data coordination
- `core/presentation/providers/` - UI state only

To migrate:
1. Update imports to use new entities instead of old models
2. Initialize DependencyInjection in main.dart
3. Replace old providers with refactored versions
4. Update feature widgets to use new entity types
