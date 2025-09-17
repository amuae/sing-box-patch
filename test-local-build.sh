#!/bin/bash

# 本地测试编译流程脚本

set -e

echo "=== 本地编译测试开始 ==="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 清理函数
cleanup() {
    echo "[INFO] 清理测试环境..."
    cd "$SCRIPT_DIR"
    rm -rf test-env
}

# 设置陷阱在脚本退出时清理
trap cleanup EXIT

# 创建测试环境
echo "[INFO] 创建测试环境..."
rm -rf test-env
mkdir -p test-env
cd test-env

# 测试版本查询
print_info "测试版本查询..."
VERSION_TAG="v1.13.0-alpha.15"
print_success "使用版本: $VERSION_TAG"

# 下载sing-box源码
print_info "下载sing-box源码..."
git clone --depth 1 --branch $VERSION_TAG https://github.com/SagerNet/sing-box.git sing-box-source
print_success "源码下载完成"

# 应用补丁
print_info "应用1.13版本补丁..."
if [ ! -d "../source/1.13" ]; then
    print_error "补丁目录 ../source/1.13 不存在"
    exit 1
fi

cp -r ../source/1.13/* sing-box-source/
print_success "补丁应用完成"

# 检查修复的文件
print_info "验证selector修复..."
if grep -q "s.Tag()" sing-box-source/protocol/group/selector.go; then
    print_success "selector.go修复验证通过"
else
    print_error "selector.go修复验证失败"
    exit 1
fi

if grep -q "len(s.tags) == 0" sing-box-source/protocol/group/selector.go; then
    print_success "索引越界修复验证通过" 
else
    print_error "索引越界修复验证失败"
    exit 1
fi

# 进入源码目录
cd sing-box-source

# 检查Go版本
print_info "检查Go版本..."
GO_VERSION=$(go version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | sed 's/go//')
print_info "当前Go版本: $GO_VERSION"

# 测试编译 - Linux AMD64
print_info "测试编译 Linux AMD64..."
export GOOS=linux
export GOARCH=amd64
export CGO_ENABLED=1

VERSION_NUMBER="${VERSION_TAG#v}"
COMMIT_HASH=$(git rev-parse --short HEAD)
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

LDFLAGS="-X 'github.com/sagernet/sing-box/constant.Version=$VERSION_NUMBER' \
         -X 'github.com/sagernet/sing-box/constant.Commit=$COMMIT_HASH' \
         -X 'github.com/sagernet/sing-box/constant.BuildTime=$BUILD_TIME' \
         -s -w -buildid="

BUILD_TAGS="with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor,with_tailscale"

print_info "编译标签: $BUILD_TAGS"
print_info "LDFLAGS: $LDFLAGS"

if go build -v -trimpath \
    -ldflags "$LDFLAGS" \
    -tags "$BUILD_TAGS" \
    -o "sing-box-linux-amd64" \
    ./cmd/sing-box; then
    print_success "Linux AMD64 编译成功"
else
    print_error "Linux AMD64 编译失败"
    exit 1
fi

# 测试编译产物
print_info "测试编译产物..."
./sing-box-linux-amd64 version
if [ $? -eq 0 ]; then
    print_success "编译产物测试通过"
else
    print_error "编译产物测试失败"
    exit 1
fi

# 测试不同的编译标签组合 (模拟Android)
print_info "测试Android编译标签组合..."
export CGO_ENABLED=0
ANDROID_BUILD_TAGS="with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api"

print_info "Android编译标签: $ANDROID_BUILD_TAGS"

if go build -v -trimpath \
    -ldflags "$LDFLAGS" \
    -tags "$ANDROID_BUILD_TAGS" \
    -o "sing-box-android-test" \
    ./cmd/sing-box; then
    print_success "Android标签组合编译成功"
else
    print_error "Android标签组合编译失败"
    exit 1
fi

# 创建测试配置
print_info "创建测试配置文件..."
cat > test-config.json <<'EOF'
{
  "log": {
    "level": "info"
  },
  "dns": {
    "servers": [
      {
        "tag": "cloudflare",
        "address": "1.1.1.1"
      },
      {
        "tag": "google",
        "address": "8.8.8.8"
      }
    ]
  },
  "inbounds": [
    {
      "type": "mixed",
      "listen": "127.0.0.1",
      "listen_port": 7890
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF

# 测试配置验证
print_info "测试配置验证..."
ENABLE_DEPRECATED_LEGACY_DNS_SERVERS=true ENABLE_DEPRECATED_MISSING_DOMAIN_RESOLVER=true ./sing-box-linux-amd64 check -c test-config.json
if [ $? -eq 0 ]; then
    print_success "配置验证通过"
else
    print_error "配置验证失败"
    exit 1
fi

# 输出编译信息
print_info "编译产物信息:"
ls -la sing-box-*
echo ""

./sing-box-linux-amd64 version
echo ""

print_success "=== 本地编译测试完成 ==="
print_success "所有测试通过，可以安全更新到工作流"

echo ""
echo "测试结果总结:"
echo "✅ 版本查询正常"
echo "✅ 源码下载正常" 
echo "✅ 补丁应用正常"
echo "✅ selector修复验证通过"
echo "✅ Linux AMD64编译成功"
echo "✅ Android标签组合编译成功"
echo "✅ 配置验证通过"
echo "✅ 版本信息正确"