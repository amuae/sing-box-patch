#!/bin/bash

# Sing-Box Provider Patch Apply Script
# 用于将 provider 补丁应用到官方 sing-box 源码

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$SCRIPT_DIR/patches"
SOURCE_DIR="$SCRIPT_DIR/source"

# 检查参数
if [ $# -ne 1 ]; then
    echo "使用方法: $0 <sing-box-source-directory>"
    echo "示例: $0 /path/to/sing-box"
    exit 1
fi

SING_BOX_DIR="$1"

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

echo "开始应用 sing-box provider 补丁..."
echo "目标目录: $SING_BOX_DIR"

# 创建备份
BACKUP_DIR="$SING_BOX_DIR.backup.$(date +%Y%m%d_%H%M%S)"
echo "创建备份: $BACKUP_DIR"
cp -r "$SING_BOX_DIR" "$BACKUP_DIR"

cd "$SING_BOX_DIR"

echo ""
echo "=== 第一阶段：复制新文件 ==="

# 1. 复制完整的 provider 实现目录
if [ -d "$SOURCE_DIR/provider" ]; then
    echo "复制 provider 实现..."
    cp -r "$SOURCE_DIR/provider" "$SING_BOX_DIR/"
fi

# 2. 复制其他适配器文件（但不包含provider目录）
if [ -d "$SOURCE_DIR/adapter" ]; then
    echo "复制 adapter 相关文件..."
    # 仅复制文件，不复制provider子目录
    find "$SOURCE_DIR/adapter" -maxdepth 1 -type f -exec cp {} "$SING_BOX_DIR/adapter/" \;
    
    # 复制其他子目录（除了provider）
    for subdir in "$SOURCE_DIR/adapter"/*; do
        if [ -d "$subdir" ] && [ "$(basename "$subdir")" != "provider" ]; then
            mkdir -p "$SING_BOX_DIR/adapter/$(basename "$subdir")"
            cp -r "$subdir"/* "$SING_BOX_DIR/adapter/$(basename "$subdir")/"
        fi
    done
fi

# 3. 复制 adapter/provider.go
if [ -f "$SOURCE_DIR/adapter/provider.go" ]; then
    echo "复制 adapter/provider.go..."
    cp "$SOURCE_DIR/adapter/provider.go" "$SING_BOX_DIR/adapter/"
fi

# 4. 复制 option/provider.go
if [ -f "$SOURCE_DIR/option/provider.go" ]; then
    echo "复制 option/provider.go..."
    mkdir -p "$SING_BOX_DIR/option"
    cp "$SOURCE_DIR/option/provider.go" "$SING_BOX_DIR/option/"
fi

# 5. 复制 common/interrupt 相关文件
if [ -d "$SOURCE_DIR/common/interrupt" ]; then
    echo "复制 common/interrupt..."
    mkdir -p "$SING_BOX_DIR/common"
    cp -r "$SOURCE_DIR/common/interrupt" "$SING_BOX_DIR/common/"
fi

echo ""
echo "=== 第二阶段：应用文件修改 ==="

# 应用修改的函数
apply_source_file() {
    local source_file="$1"
    local target_file="$2"
    
    if [ -f "$SOURCE_DIR/$source_file" ]; then
        echo "应用修改: $target_file"
        # 确保目标目录存在
        mkdir -p "$(dirname "$SING_BOX_DIR/$target_file")"
        cp "$SOURCE_DIR/$source_file" "$SING_BOX_DIR/$target_file"
    else
        echo "警告: 源文件不存在: $SOURCE_DIR/$source_file"
    fi
}

# 应用所有修改过的文件
apply_source_file "option/options.go" "option/options.go"
apply_source_file "option/group.go" "option/group.go"
apply_source_file "protocol/group/selector.go" "protocol/group/selector.go"
apply_source_file "protocol/group/urltest.go" "protocol/group/urltest.go"
apply_source_file "box.go" "box.go"
apply_source_file "adapter/router.go" "adapter/router.go"
apply_source_file "adapter/experimental.go" "adapter/experimental.go"
apply_source_file "experimental/cachefile/cache.go" "experimental/cachefile/cache.go"
apply_source_file "experimental/clashapi/server.go" "experimental/clashapi/server.go"
apply_source_file "experimental/clashapi/provider.go" "experimental/clashapi/provider.go"
apply_source_file "experimental/clashapi/ruleprovider.go" "experimental/clashapi/ruleprovider.go"
apply_source_file "include/registry.go" "include/registry.go"
apply_source_file "constant/proxy.go" "constant/proxy.go"
apply_source_file "constant/rule.go" "constant/rule.go"
apply_source_file "route/rule/rule_set_local.go" "route/rule/rule_set_local.go"
apply_source_file "route/rule/rule_set_remote.go" "route/rule/rule_set_remote.go"
apply_source_file "route/router.go" "route/router.go"
apply_source_file "adapter/outbound/manager.go" "adapter/outbound/manager.go"

echo ""
echo "=== 第三阶段：应用修复补丁 ==="

# 应用新的修复补丁
echo "应用版本修复和验证增强..."
for fix_patch in version-fix provider-validation provider-runtime-fix selector-validation provider-package-fix provider-import-fix; do
    patch_file="$PATCH_DIR/${fix_patch}.patch"
    if [ -f "$patch_file" ]; then
        echo "应用修复补丁: $(basename "$patch_file")"
        if ! git apply --ignore-whitespace "$patch_file" 2>/dev/null; then
            echo "  尝试使用 patch 命令..."
            if ! patch -p1 -f < "$patch_file" 2>/dev/null; then
                echo "  警告: 修复补丁 $(basename "$patch_file") 应用失败，可能已经包含在源码中"
            else
                echo "  ✅ 修复补丁应用成功"
            fi
        else
            echo "  ✅ 修复补丁应用成功"
        fi
    else
        echo "  跳过: $(basename "$patch_file") (文件不存在)"
    fi
done

echo ""
echo "=== 第四阶段：验证和清理 ==="

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
echo "🎉 补丁应用完成!"
echo ""
echo "🚀 新增功能："
echo "  ✅ Provider 订阅支持 (remote, local, inline)"
echo "  ✅ 组别选择器 providers 字段支持"
echo "  ✅ 增强的 ClashAPI (/providers/proxies, /providers/rules)"
echo "  ✅ 手动更新订阅和规则功能"
echo "  ✅ 支持 include/exclude 节点过滤"
echo "  ✅ 支持 use_all_providers 选项"
echo ""
echo "🔧 编译说明："
echo "  **重要**: 需要 Go 1.24.7 或更高版本"
echo "  **CGO**: 默认启用以获得最佳性能和兼容性"
echo "  基础编译: go build -tags \"with_clash_api\" -o sing-box ./cmd/sing-box"
echo "  完整编译: go build -tags \"with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor,with_tailscale\" -o sing-box-full ./cmd/sing-box"
echo "  带版本号: go build -ldflags \"-X 'github.com/sagernet/sing-box/constant.Version=\$(go run github.com/sagernet/sing-box/cmd/internal/read_tag@latest)'\" -tags \"标签\" -o sing-box ./cmd/sing-box"
echo ""
echo "📖 参考资源："
echo "  示例配置: $SCRIPT_DIR/examples/"
echo "  文档说明: $SCRIPT_DIR/docs/"
echo "  自动编译: $SCRIPT_DIR/build.sh"
echo ""
echo "💾 备份位置: $BACKUP_DIR"