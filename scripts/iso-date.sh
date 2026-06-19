#!/usr/bin/env sh

is_valid_iso_date() {
  printf '%s\n' "$1" | awk -F- '
    NF != 3 || length($1) != 4 || length($2) != 2 || length($3) != 2 ||
      $1 !~ /^[0-9]+$/ || $2 !~ /^[0-9]+$/ || $3 !~ /^[0-9]+$/ { exit 1 }
    {
      year = $1 + 0
      month = $2 + 0
      day = $3 + 0
      if (month < 1 || month > 12) exit 1
      days = 31
      if (month == 4 || month == 6 || month == 9 || month == 11) days = 30
      if (month == 2) {
        leap = (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0))
        days = leap ? 29 : 28
      }
      exit !(day >= 1 && day <= days)
    }
  '
}
