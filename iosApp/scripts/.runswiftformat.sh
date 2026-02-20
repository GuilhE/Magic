#!/bin/sh

# Define the path to SwiftFormat
SWIFTFORMAT_PATH="/opt/homebrew/bin/swiftformat"

# Check if swiftformat exists at the specified path
if [ ! -f "$SWIFTFORMAT_PATH" ]; then
    echo "SwiftFormat is not installed at $SWIFTFORMAT_PATH"
    echo "To enable code formatting, install it using:"
    echo "brew install swiftformat"
    exit 0  # Exit successfully to not fail the build
fi

# Run SwiftFormat with specified version
"$SWIFTFORMAT_PATH" . --exclude iosApp/Representables --swiftversion 6.0.3

# Even if SwiftFormat fails, we don't want to fail the build
if [ $? -eq 0 ]; then
    echo "SwiftFormat completed successfully"
else
    echo "SwiftFormat encountered some issues, but continuing with build"
fi

exit 0  # Always exit successfully 