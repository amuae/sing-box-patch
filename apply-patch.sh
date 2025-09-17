#!/bin/bash

# Sing-Box Provider Patch Apply Script (多版本支持)
# 用于将 provider 补丁应用到官方 sing-box 源码

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_VERSION="1.13"

# 检查参数
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "使用方法: $0 <sing-box-source-directory> [版本]"
    echo "示例: $0 /path/to/sing-box"
    echo "示例: $0 /path/to/sing-box 1.14"
    echo "默认版本: $DEFAULT_VERSION"
    exit 1
fi

SING_BOX_DIR="$(cd "$1" && pwd)"
PATCH_VERSION="${2:-$DEFAULT_VERSION}"

# 检查目录是否存在
if [ ! -d "$SING_BOX_DIR" ]; then
    echo "错误: 目录 $SING_BOX_DIR 不存在"
    exit 1
fi
PATCH_DIR="$SCRIPT_DIR/patches/$PATCH_VERSION"
SOURCE_DIR="$SCRIPT_DIR/source/$PATCH_VERSION"

# 检查 Go 版本
if command -v go &> /dev/null; then
    GO_VERSION=$(go version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | sed 's/go//')
    REQUIRED_GO_VERSION="1.24.7"
    
    # 版本比较函数
    version_compare() {
        echo "$1 $2" | awk '{
            split($1, a, "\\.");
            split($2, b, "\\.");
            for (i = 1; i <= 3; i++) {
                if (a[i] < b[i]) exit 1;
                if (a[i] > b[i]) exit 0;
            }
            exit 0;
        }'
    }
    
    if ! version_compare "$GO_VERSION" "$REQUIRED_GO_VERSION"; then
        echo "错误: Go 版本过低: $GO_VERSION (要求: >= $REQUIRED_GO_VERSION)"
        echo "sing-box v1.13.0+ 需要 Go 1.24.7 或更高版本"
        echo "请升级 Go 版本: https://golang.org/dl/"
        exit 1
    fi
    
    echo "Go 版本检查通过: $GO_VERSION"
else
    echo "警告: 未找到 Go 编译器，请确保已安装 Go 1.24.7+"
fi

# 检查目标目录是否存在
if [ ! -d "$SING_BOX_DIR" ]; then
    echo "错误: sing-box 源码目录不存在: $SING_BOX_DIR"
    exit 1
fi

# 检查是否是有效的 sing-box 源码目录
if [ ! -f "$SING_BOX_DIR/go.mod" ] || ! grep -q "github.com/sagernet/sing-box" "$SING_BOX_DIR/go.mod"; then
    echo "错误: 指定的目录不是有效的 sing-box 源码目录"
    exit 1
fi

echo "开始应用 sing-box $PATCH_VERSION 版本补丁..."
echo "目标目录: $SING_BOX_DIR"
echo "补丁版本: $PATCH_VERSION"

# 检查补丁目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 补丁目录不存在: $SOURCE_DIR"
    exit 1
fi

# 创建备份
BACKUP_DIR="$(dirname "$SING_BOX_DIR")/$(basename "$SING_BOX_DIR")_backup.$(date +%Y%m%d_%H%M%S)"
echo "创建备份: $BACKUP_DIR"
cp -r "$SING_BOX_DIR" "$BACKUP_DIR"

cd "$SING_BOX_DIR"

echo ""
echo "=== 应用 $PATCH_VERSION 版本源码补丁 ==="
cp -r "$SOURCE_DIR"/* ./
echo "✅ 源码补丁应用完成"

echo ""
echo "=== 验证和清理 ==="

# 检查并添加必要的导入
echo "整理 go.mod 依赖..."
go mod tidy

# 验证编译
echo "验证编译..."
if go build -o /tmp/sing-box-test ./cmd/sing-box; then
    echo "✅ 编译成功!"
    rm -f /tmp/sing-box-test
else
    echo "❌ 编译失败，请检查错误信息"
    echo "备份已保存到: $BACKUP_DIR"
    exit 1
fi

echo ""
echo "🎉 $PATCH_VERSION 版本补丁应用完成!"
echo ""
echo "� 备份位置: $BACKUP_DIR"
echo " 示例配置: $SCRIPT_DIR/examples/"