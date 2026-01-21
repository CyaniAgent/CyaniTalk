---
trigger: always_on
---

# Flutter Agent Rules - Full Manifest
# For large enterprise projects with all features

version: 4.0.0
template: full

# Remote repository (reads from GitHub)
remote:
  url: https://raw.githubusercontent.com/Ahmed-Fathy-dev/Dart-Flutter-Rules
  branch: main
  repo: https://github.com/Ahmed-Fathy-dev/Dart-Flutter-Rules

# What to include (everything!)
includes:
  # State Management (all options for comparison)
  state_management:
    - riverpod          # ✅ Primary
    - bloc              # ✅ Alternative
    - provider          # ✅ Legacy support
    - getx              # ✅ For reference
    - hooks             # ✅ With Riverpod
    - comparison        # ✅ Comparison guide
  
  # Navigation (all options)
  navigation:
    - go_router                    # ✅ Primary
    - go_router_builder_advanced   # ✅ Type-safe
    - auto_route                   # ✅ Alternative
    - navigator                    # ✅ Basic
    - deep-linking                 # ✅ Deep linking
  
  # Data & Serialization
  data:
    - json-serialization  # ✅ Standard
    - dart-mappable       # ✅ Advanced
    - http-clients        # ✅ Dio
    - local-storage       # ✅ Storage options
    - objectbox           # ✅ High-performance DB
  
  # Architecture
  architecture:
    - feature-based       # ✅ Primary
    - clean-architecture  # ✅ Enterprise
    - project-structure   # ✅ Structure
  
  # UI & Design
  ui:
    - material3-theming      # ✅ Material 3
    - responsive-design      # ✅ Responsive
    - layout-best-practices  # ✅ Layouts
    - common-packages        # ✅ UI packages
    - ui-utilities           # ✅ Utilities
  
  # Core Concepts
  core:
    - dart-fundamentals   # ✅ Dart basics
    - value-equality      # ✅ Equality
    - error-handling      # ✅ Errors
    - async-programming   # ✅ Async/await
  
  # Tools & Build
  tools:
    - build-runner        # ✅ Code generation
  
  # Specialized
  specialized:
    - environment-config  # ✅ Env variables
    - logging             # ✅ Talker logging
    - testing             # ✅ Testing guide

# Priority (what AI reads first)
priority:
  - architecture/feature-based
  - state-management/riverpod
  - navigation/go_router
  - data/json-serialization
  - ui/material3-theming
  - specialized/logging

# AI Instructions
ai_instructions: |
  This is a FULL setup for enterprise Flutter projects.
  
  Architecture:
  - Use feature-based or clean architecture
  - Strict separation of concerns
  - Domain-driven design
  
  State Management:
  - Primary: Riverpod with code generation
  - Alternative: Bloc for complex flows
  - Use flutter_hooks for UI optimization
  
  Navigation:
  - Primary: GoRouter with go_router_builder
  - Type-safe routing is mandatory
  - Full deep linking support
  
  Data:
  - Use dart_mappable for better performance
  - ObjectBox for complex local data
  - Dio with interceptors for HTTP
  
  Quality:
  - Comprehensive error handling
  - Proper logging with Talker
  - Environment-based configuration
  - Full test coverage

# Excluded (nothing - this is full setup)
excludes: []

# Caching
cache:
  enabled: true
  ttl: 43200  # 12 hours (shorter for active development)
  path: .cascade/cache/

# Custom overrides
overrides:
  enabled: true
  path: .cascade/overrides/
  
# Advanced options
advanced:
  # Fetch depth (how many related docs to fetch)
  fetch_depth: 2
  
  # Auto-update check
  auto_update: true
  update_interval: 86400  # Daily
  
  # Offline mode
  offline_fallback: true