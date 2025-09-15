# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GRDB.swift is a SQLite database toolkit focused on application development. It provides SQL generation, database observation, robust concurrency, and migration support.

## Build and Test Commands

### Common Development Tasks

```bash
# Run all tests (except performance)
make test

# Quick smoke test before PRs
make smokeTest

# Run Swift Package Manager tests
make test_SPM

# Run performance tests
make test_performance

# Generate documentation
make doc

# Clean build artifacts
make clean
```

### Running Individual Tests

```bash
# Swift Package Manager
swift test --filter TestClassName/testMethodName

# Example:
swift test --filter GRDBTests.DatabaseQueueTests/testDatabaseQueueCreation
```

## Architecture Overview

### Core Database Types

- **DatabaseQueue**: Serial database access for single-threaded usage
- **DatabasePool**: Concurrent reads with serial writes (uses WAL mode)
- **DatabaseSnapshot**: Read-only database snapshots for consistent reads

### Record Protocols

All model types should conform to appropriate protocols:
- `FetchableRecord`: For reading from database
- `PersistableRecord`: For writing to database  
- `TableRecord`: Associates record with a table name
- `Codable`: Leverage automatic coding for simple models

### Query Building

GRDB uses a type-safe query interface:
```swift
// Fetch players with high scores
let players = try Player
    .filter(Player.Columns.score > 1000)
    .order(Player.Columns.score.desc)
    .fetchAll(db)
```

### Concurrency Model

- All database access happens within closures
- Readers don't block readers
- Writers don't block readers (in WAL mode)
- Always use `try dbQueue.write { db in ... }` or `try dbQueue.read { db in ... }`

## Testing Guidelines

- Base test class: `GRDBTestCase` provides database setup/teardown
- Tests use XCTest framework (not Swift Testing)
- Test files are in `Tests/GRDBTests/`
- Always run `make smokeTest` before committing

## Development Workflow

1. Work on `development` branch (not `master`)
2. Run tests before committing: `make smokeTest`
3. Follow existing code patterns for consistency
4. Update documentation for public API changes
5. Wrap documentation at column 76

## Key Patterns

### Error Handling
- SQLite errors throw `DatabaseError`
- API misuse throws descriptive Swift errors
- Always provide context in error messages

### SQL Safety
- Use parameterized queries to prevent injection
- Prefer query interface over raw SQL when possible
- Use `Column` types for compile-time safety

### Memory Management
- Statements are automatically finalized
- Database connections clean up on deinit
- Be careful with retained database connections in closures