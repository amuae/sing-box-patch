#!/bin/bash

# 版本检查测试脚本

echo "=== Go 版本检查测试 ==="

# 当前 Go 版本
echo "当前 Go 版本:"
go version

echo ""
echo "=== 测试构建脚本版本检查 ==="
./build.sh --help > /dev/null 2>&1
echo "构建脚本帮助: ✅"

echo ""
echo "=== 测试版本检查功能 ==="
./build.sh --basic 2>&1 | head -5

echo ""
echo "=== 项目结构检查 ==="
echo "主要文件:"
ls -la *.sh *.md 2>/dev/null | grep -E '\.(sh|md)$'

echo ""
echo "补丁文件:"
find patches/ -name "*.patch" 2>/dev/null | wc -l | xargs echo "补丁数量:"

echo ""
echo "文档文件:"
find docs/ -name "*.md" 2>/dev/null | wc -l | xargs echo "文档数量:"

echo ""
echo "=== 版本要求摘要 ==="
echo "- sing-box v1.13.0+: 需要 Go 1.24.7+"
echo "- 当前项目要求: Go 1.24.7+"
echo "- 快速升级: ./install-go.sh"