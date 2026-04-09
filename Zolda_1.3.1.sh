#!/bin/sh
printf '\033c\033]0;%s\a' Zelda Roguelite
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Zolda_1.3.1.x86_64" "$@"
