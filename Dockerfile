# Test GRDB.swift on Linux
FROM swift:6.1-noble AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Package files first for better caching
COPY Package.swift Package.resolved ./

# Resolve dependencies
RUN swift package resolve

# Copy source code
COPY Sources ./Sources
COPY Tests ./Tests
COPY GRDB ./GRDB
COPY SQLiteCustom ./SQLiteCustom

# Run tests
CMD ["swift", "test", "--parallel"]