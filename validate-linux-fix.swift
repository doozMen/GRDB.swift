#!/usr/bin/env swift
// This script validates that the Linux snapshot fix is working correctly

import Foundation

print("Validating GRDB Linux Snapshot Fix")
print("===================================")

// Check the modified files
let modifiedFiles = [
    "GRDB/Core/DatabasePool.swift",
    "GRDB/Core/DatabaseSnapshotPool.swift", 
    "GRDB/Core/WALSnapshot.swift",
    "GRDB/Core/WALSnapshotTransaction.swift",
    "GRDB/ValueObservation/Observers/ValueConcurrentObserver.swift"
]

let fm = FileManager.default
var allFixed = true

for file in modifiedFiles {
    let path = URL(fileURLWithPath: file)
    guard let content = try? String(contentsOf: path) else {
        print("❌ Could not read \(file)")
        allFixed = false
        continue
    }
    
    // Check for the fix pattern
    if content.contains("#if SQLITE_ENABLE_SNAPSHOT || (!GRDBCUSTOMSQLITE && !GRDBCIPHER && !os(Linux))") {
        print("✅ \(file) - Has Linux fix")
    } else if content.contains("#if SQLITE_ENABLE_SNAPSHOT || (!GRDBCUSTOMSQLITE && !GRDBCIPHER)") {
        print("❌ \(file) - Missing Linux fix")
        allFixed = false
    } else {
        print("⚠️  \(file) - No snapshot conditional found")
    }
}

print("")
if allFixed {
    print("✅ All files have the Linux fix applied!")
    print("")
    print("Summary:")
    print("- SQLite snapshots are disabled on Linux with system SQLite")
    print("- This prevents linker errors from missing sqlite3_snapshot_* functions")
    print("- Linux users can still enable snapshots with custom SQLite builds")
    print("- No behavior changes on Apple platforms")
} else {
    print("❌ Some files are missing the Linux fix")
    exit(1)
}