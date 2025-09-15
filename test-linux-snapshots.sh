#!/bin/bash
set -e

echo "Testing GRDB.swift Linux compatibility with SQLite snapshots"
echo "============================================================"

# Build and run the test
echo "Building Docker image..."
docker build -f Dockerfile.linux-test -t grdb-linux-snapshot-test .

echo ""
echo "Running tests..."
docker run --rm grdb-linux-snapshot-test

echo ""
echo "✅ Tests passed! The snapshot fix is working correctly."