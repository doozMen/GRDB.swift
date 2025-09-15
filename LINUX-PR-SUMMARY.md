# Pull Request: Fix Linux Compatibility by Conditionally Disabling SQLite Snapshots

## Summary

This PR fixes a critical issue preventing GRDB.swift from building on Linux distributions. The fix adds platform detection to conditionally disable SQLite snapshot features on Linux when using system SQLite.

## The Problem

GRDB fails to build on Linux with linker errors:
```
error: undefined reference to 'sqlite3_snapshot_open'
error: undefined reference to 'sqlite3_snapshot_get'
error: undefined reference to 'sqlite3_snapshot_free'
error: undefined reference to 'sqlite3_snapshot_cmp'
error: undefined reference to 'sqlite3_snapshot_recover'
```

### Root Cause

The current conditional compilation assumes system SQLite has snapshot support:
```swift
#if SQLITE_ENABLE_SNAPSHOT || (!GRDBCUSTOMSQLITE && !GRDBCIPHER)
```

This is true on macOS (Apple compiles SQLite with `SQLITE_ENABLE_SNAPSHOT`) but false on Linux distributions, which compile SQLite without this flag for compatibility and size reasons.

## The Solution

Add `&& !os(Linux)` to the conditional compilation:
```swift
#if SQLITE_ENABLE_SNAPSHOT || (!GRDBCUSTOMSQLITE && !GRDBCIPHER && !os(Linux))
```

## Changes

Modified 5 files to add Linux platform detection:
- `GRDB/Core/DatabasePool.swift` (2 locations)
- `GRDB/Core/DatabaseSnapshotPool.swift`
- `GRDB/Core/WALSnapshot.swift`
- `GRDB/Core/WALSnapshotTransaction.swift`
- `GRDB/ValueObservation/Observers/ValueConcurrentObserver.swift`

## Impact

### What Gets Disabled on Linux
- `DatabasePool.makeSnapshotPool()`
- `WALSnapshot` class
- Snapshot-based optimizations in `ValueConcurrentObserver`

### What Still Works
- All core database functionality
- All query builders and record types
- Standard value observations (with slight timing differences)
- All other GRDB features

### Backward Compatibility
- ✅ No API changes
- ✅ No behavior changes on Apple platforms
- ✅ Linux users can still enable snapshots with custom SQLite builds
- ✅ Existing code continues to work unchanged

## Testing

The fix enables GRDB to build and run on:
- Ubuntu 22.04, 24.04
- Docker containers with Swift 6.1
- No regression on macOS/iOS

## Alternative Solutions Considered

1. **Requiring custom SQLite on Linux**: Too restrictive
2. **Runtime detection**: Not possible with C preprocessor symbols
3. **Disabling features entirely**: Would remove functionality from platforms that support it

## Conclusion

This minimal, targeted fix:
- Solves the Linux compatibility issue
- Maintains all existing functionality on Apple platforms
- Allows advanced Linux users to opt-in with custom builds
- Enables GRDB in server-side Swift applications

The fix properly acknowledges platform differences in SQLite compilation while maintaining GRDB's high-quality database abstraction.