#!/usr/bin/env bash
# 整书构建脚本（带桌面目录变通）
#
# 背景：在本机上，于桌面工程目录内直接执行 `quarto render --to html` 时，
# pandoc 新写出的 index.html 在 quarto 执行 rename 前即消失（NotFound），
# 疑似桌面同步/安全软件拦截；同一工程复制到非桌面目录渲染则完全正常。
# 因此本脚本采用「暂存区渲染 -> 拷回 _book」的两步流程。
#
# 用法：bash tools/build_book.sh [staging_dir]
set -euo pipefail

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
STAGE="${1:-/tmp/quarto_book_build}"

echo "== 1/3 同步工程到暂存区: $STAGE"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -r "$PROJ"/. "$STAGE"/
rm -rf "$STAGE/_book" "$STAGE/.quarto" "$STAGE/site_libs"

echo "== 2/3 在暂存区渲染"
(cd "$STAGE" && quarto render --to html)

echo "== 3/3 拷回 _book"
mkdir -p "$PROJ/_book"
cp -r "$STAGE/_book/." "$PROJ/_book/"

echo "完成：$PROJ/_book/index.html"
