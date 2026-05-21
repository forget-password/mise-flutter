#!/usr/bin/env bash

if [ -z "${FLUTTER_STORAGE_BASE_URL}" ]; then
  if curl -sI --connect-timeout 2 https://storage.googleapis.com >/dev/null; then
    FLUTTER_STORAGE_BASE_URL="https://storage.googleapis.com"
  else
    echo "Warning: storage.googleapis.com is unreachable. Falling back to storage.flutter-io.cn" >&2
    FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
  fi
fi

export FLUTTER_STORAGE_BASE_URL
