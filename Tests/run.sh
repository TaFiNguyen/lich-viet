#!/bin/sh
# Compiles the shared calendar core with the test runner and executes it on macOS.
set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${TMPDIR:-/tmp}/lichviet-tests"
swiftc -O "$DIR/Shared/LunarCalendar.swift" "$DIR/Shared/CanChi.swift" "$DIR/Shared/Holidays.swift" "$DIR/Shared/DayInfo.swift" "$DIR/Tests/main.swift" -o "$OUT"
"$OUT"
