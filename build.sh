#!/bin/bash

# Sing-Box Provider 补丁项目自动化编译脚本
# 用法: ./build.sh [sing-box源码路径] [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
SING_BOX_VERSION="v1.13.0-alpha.15"
BUILD_TAGS="with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor,with_tailscale"
OUTPUT_NAME="sing-box-full"

# 函数定义
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Sing-Box Provider 补丁项目自动化编译脚本

用法:
    $0 [选项]

选项:
    -s, --source PATH       指定 sing-box 源码路径 (默认: 自动下载)
    -v, --version VERSION   指定 sing-box 版本 (默认: $SING_BOX_VERSION)
    -t, --tags TAGS         指定编译标签 (默认: 全功能标签)
    -o, --output NAME       指定输出文件名 (默认: $OUTPUT_NAME)
    --basic                 编译基础版本 (仅包含 clash_api)
    --clean                 编译前清理临时文件
    -h, --help             显示此帮助信息

示例:
    $0                                  # 自动下载并编译完整版本
    $0 -s /path/to/sing-box             # 使用指定的源码路径编译
    $0 --basic                          # 编译基础版本
    $0 -v v1.12.0 --clean               # 指定版本并清理编译

EOF
}

# 解析命令行参数
SING_BOX_PATH=""
BASIC_BUILD=false
CLEAN_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            SING_BOX_PATH="$2"
            shift 2
            ;;
        -v|--version)
            SING_BOX_VERSION="$2"
            shift 2
            ;;
        -t|--tags)
            BUILD_TAGS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_NAME="$2"
            shift 2
            ;;
        --basic)
            BASIC_BUILD=true
            BUILD_TAGS="with_clash_api"
            OUTPUT_NAME="sing-box-basic"
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$SCRIPT_DIR"

print_info "=== Sing-Box Provider 补丁编译开始 ==="
print_info "补丁目录: $PATCH_DIR"
print_info "目标版本: $SING_BOX_VERSION"
print_info "编译标签: $BUILD_TAGS"
print_info "输出文件: $OUTPUT_NAME"

# 检查必要工具
if ! command -v go &> /dev/null; then
    print_error "Go 编译器未找到，请先安装 Go 语言环境"
    exit 1
fi

# 检查 Go 版本
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
    print_error "Go 版本过低: $GO_VERSION (要求: >= $REQUIRED_GO_VERSION)"
    print_error "sing-box v1.13.0+ 需要 Go 1.24.7 或更高版本"
    print_error "请升级 Go 版本: https://golang.org/dl/"
    exit 1
fi

print_info "Go 版本检查通过: $GO_VERSION"

if ! command -v git &> /dev/null; then
    print_error "Git 未找到，请先安装 Git"
    exit 1
fi

# 如果未指定源码路径，自动下载
if [[ -z "$SING_BOX_PATH" ]]; then
    print_info "未指定源码路径，开始自动下载 sing-box 源码..."
    
    TEMP_DIR=$(mktemp -d)
    SING_BOX_PATH="$TEMP_DIR/sing-box"
    
    git clone --depth 1 --branch "$SING_BOX_VERSION" https://github.com/SagerNet/sing-box.git "$SING_BOX_PATH"
    print_success "源码下载完成: $SING_BOX_PATH"
fi

# 检查源码路径
if [[ ! -d "$SING_BOX_PATH" ]]; then
    print_error "源码路径不存在: $SING_BOX_PATH"
    exit 1
fi

if [[ ! -f "$SING_BOX_PATH/go.mod" ]]; then
    print_error "无效的 sing-box 源码目录: $SING_BOX_PATH"
    exit 1
fi

# 清理编译 (如果需要)
if [[ "$CLEAN_BUILD" == true ]]; then
    print_info "清理编译环境..."
    cd "$SING_BOX_PATH"
    go clean -cache -modcache -i -r
    rm -f sing-box*
fi

# 应用补丁
print_info "应用 Provider 补丁..."

# 检查是否有补丁文件存在
if [[ -d "$PATCH_DIR/source" ]]; then
    # 使用源码文件方式
    print_info "使用源码文件方式应用补丁..."
    cp -r "$PATCH_DIR/source"/* "$SING_BOX_PATH/"
    print_success "源码文件复制完成"
elif [[ -d "$PATCH_DIR/patches" ]] && [[ -f "$PATCH_DIR/apply-patch.sh" ]]; then
    # 使用补丁文件方式
    print_info "使用补丁文件方式应用补丁..."
    cd "$PATCH_DIR"
    ./apply-patch.sh "$SING_BOX_PATH"
    print_success "补丁应用完成"
else
    print_error "未找到补丁文件或源码文件"
    exit 1
fi

# 编译
print_info "开始编译 sing-box..."
cd "$SING_BOX_PATH"

# 检查 Go 版本
GO_VERSION=$(go version | grep -oE 'go[0-9]+\.[0-9]+')
print_info "Go 版本: $GO_VERSION"

# 获取版本信息
print_info "获取版本信息..."
VERSION=$(CGO_ENABLED=0 go run github.com/sagernet/sing-box/cmd/internal/read_tag@latest 2>/dev/null || echo "${SING_BOX_VERSION#v}")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
print_info "程序版本: $VERSION"
print_info "Git提交: $COMMIT"

# 设置编译环境变量 - 强制启用 CGO
export CGO_ENABLED=1
print_info "CGO: 启用 (推荐设置，更好的性能和兼容性)"
export GOOS=${GOOS:-$(go env GOOS)}
export GOARCH=${GOARCH:-$(go env GOARCH)}
# 移除 GOTOOLCHAIN=local 限制，使用自动工具链管理
unset GOTOOLCHAIN

# 设置 ldflags
LDFLAGS="-X 'github.com/sagernet/sing-box/constant.Version=$VERSION' -s -w -buildid="

print_info "编译环境: $GOOS/$GOARCH"
print_info "编译标签: $BUILD_TAGS"
print_info "LDFLAGS: $LDFLAGS"

# 执行编译
if [[ -n "$BUILD_TAGS" ]]; then
    go build -v -trimpath -tags "$BUILD_TAGS" -ldflags "$LDFLAGS" -o "$OUTPUT_NAME" ./cmd/sing-box
else
    go build -v -trimpath -ldflags "$LDFLAGS" -o "$OUTPUT_NAME" ./cmd/sing-box
fi

if [[ $? -eq 0 ]]; then
    print_success "编译完成!"
    
    # 显示编译结果
    if [[ -f "$OUTPUT_NAME" ]]; then
        FILE_SIZE=$(du -h "$OUTPUT_NAME" | cut -f1)
        print_info "编译产物: $SING_BOX_PATH/$OUTPUT_NAME ($FILE_SIZE)"
        
        # 复制到补丁项目的 build 目录
        mkdir -p "$PATCH_DIR/build"
        cp "$OUTPUT_NAME" "$PATCH_DIR/build/"
        print_success "已复制到: $PATCH_DIR/build/$OUTPUT_NAME"
        
        # 测试编译结果
        print_info "测试编译结果..."
        ./"$OUTPUT_NAME" version
        
        if [[ $? -eq 0 ]]; then
            print_success "编译测试通过!"
        else
            print_warning "编译测试失败，但文件已生成"
        fi
        
        # 显示使用说明
        cat << EOF

${GREEN}=== 编译完成 ===${NC}

编译产物位置:
  - $PATCH_DIR/build/$OUTPUT_NAME

使用方法:
  1. 配置文件: 参考 $PATCH_DIR/examples/ 目录下的示例
  2. 启动命令: ./$OUTPUT_NAME run -c config.json
  3. ClashAPI: http://127.0.0.1:9090 (如果启用)

获取帮助:
  ./$OUTPUT_NAME help

EOF
    else
        print_error "未找到编译产物"
        exit 1
    fi
else
    print_error "编译失败"
    exit 1
fi

# 清理临时目录
if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
    print_info "清理临时文件..."
    rm -rf "$TEMP_DIR"
fi

print_success "=== 所有操作完成 ==="