#!/bin/bash

# Go 1.24.7 快速安装脚本
# 仅用于开发和测试目的

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检测操作系统和架构
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        print_error "不支持的架构: $ARCH"
        exit 1
        ;;
esac

GO_VERSION="1.24.7"
GO_ARCHIVE="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_ARCHIVE}"

print_info "=== Go ${GO_VERSION} 快速安装脚本 ==="
print_info "目标平台: ${OS}/${ARCH}"

# 检查当前 Go 版本
if command -v go &> /dev/null; then
    CURRENT_VERSION=$(go version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | sed 's/go//')
    print_info "当前 Go 版本: $CURRENT_VERSION"
else
    print_info "未检测到 Go 安装"
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
print_info "临时目录: $TEMP_DIR"

# 下载 Go
print_info "下载 Go ${GO_VERSION}..."
cd "$TEMP_DIR"

if command -v wget &> /dev/null; then
    wget "$GO_URL"
elif command -v curl &> /dev/null; then
    curl -LO "$GO_URL"
else
    print_error "需要 wget 或 curl 来下载文件"
    exit 1
fi

# 备份现有安装（如果存在）
if [ -d "/usr/local/go" ]; then
    print_warning "检测到现有 Go 安装，将备份到 /usr/local/go.backup"
    sudo mv /usr/local/go /usr/local/go.backup.$(date +%Y%m%d_%H%M%S)
fi

# 安装新版本
print_info "安装 Go ${GO_VERSION}..."
sudo tar -C /usr/local -xzf "$GO_ARCHIVE"

# 设置环境变量
print_info "配置环境变量..."

# 检查是否已经在 PATH 中
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc
    print_success "已添加 Go 到 ~/.bashrc"
fi

if ! grep -q "/usr/local/go/bin" ~/.profile; then
    echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.profile
    print_success "已添加 Go 到 ~/.profile"
fi

# 为当前会话设置路径
export PATH=/usr/local/go/bin:$PATH

# 验证安装
print_info "验证安装..."
if /usr/local/go/bin/go version; then
    print_success "Go ${GO_VERSION} 安装成功！"
else
    print_error "安装验证失败"
    exit 1
fi

# 清理临时文件
rm -rf "$TEMP_DIR"

print_success "安装完成！"
print_info ""
print_info "请运行以下命令重新加载环境变量："
print_info "  source ~/.bashrc"
print_info ""
print_info "或者重新打开终端。"
print_info ""
print_info "验证安装："
print_info "  go version"
print_info ""
print_info "现在可以使用 sing-box provider patch 项目了："
print_info "  ./build.sh"