#!/bin/sh
printf '\033c\033]0;%s\a' Zelda Roguelite
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Zolda_1.2.0.x86_64" "$@"
