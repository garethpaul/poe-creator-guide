#!/usr/bin/env sh

file_link_count() {
  if stat -c '%h' -- "$1" 2>/dev/null; then
    return 0
  fi
  stat -f '%l' "$1" 2>/dev/null
}
