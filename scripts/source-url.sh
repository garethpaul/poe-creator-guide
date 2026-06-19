#!/usr/bin/env sh

is_canonical_poe_docs_url() {
  url=$1
  case "$url" in
    https://creator.poe.com/docs/*) ;;
    *) return 1 ;;
  esac

  path=${url#https://creator.poe.com/docs/}
  [ -n "$path" ] || return 1
  case "$path" in
    */|*//*|.|..|./*|../*|*/.|*/..|*/./*|*/../*|*%*) return 1 ;;
  esac
  case "$path" in
    *[!A-Za-z0-9._/-]*) return 1 ;;
  esac
}
