# sing-box 多版本补丁项目

为 sing-box 添加 Provider 订阅功能，支持多版本。

## 功能特性

- Provider 订阅支持 (Remote/Local/Inline)
- 组别选择器增强 (providers 字段)
- ClashAPI 扩展 (/providers/proxies)
- 节点过滤 (include/exclude)

## 项目结构

```
├── source/1.13/       # 1.13 版本源码
├── source/1.14/       # 1.14 版本源码 (预留)
├── patches/1.13/      # 1.13 版本补丁 (预留)
├── build-1.13.sh      # 1.13 专用构建脚本
└── apply-patch.sh     # 多版本补丁应用
```

## 快速使用

```bash
# 自动编译 1.13 版本
./build-1.13.sh

# 手动应用补丁
git clone https://github.com/SagerNet/sing-box.git
cd sing-box && git checkout v1.13.0-alpha.15
/path/to/sing-box-patch/apply-patch.sh . 1.13
go build -tags "with_clash_api,with_quic" -o sing-box ./cmd/sing-box
```

## 版本支持

| 版本 | 状态 | 构建脚本 |
|------|------|----------|
| 1.13.x | ✅ 完整支持 | build-1.13.sh |
| 1.14.x | 🚧 预留 | - |

## 环境要求

- Go ≥ 1.24.7 (sing-box 1.13+ 必须)
- CGO 启用 (推荐)

## 新版本适配

```bash
# 创建新版本
mkdir -p source/1.14 patches/1.14
cp -r source/1.13/* source/1.14/
cp build-1.13.sh build-1.14.sh
# 编辑 build-1.14.sh 中的版本号
```

## API 使用

```bash
# 查看 Provider
curl http://127.0.0.1:9090/providers/proxies

# 手动更新
curl -X PUT http://127.0.0.1:9090/providers/proxies/{name}
```



基于 yelnoo/sing-box 的补丁项目，为官方 sing-box 添加完整的 Provider 订阅功能。这是一个基于 yelnoo/sing-box 的补丁项目，为官方 sing-box 添加完整的 Provider 订阅功能，包括远程订阅、本地配置文件和内联节点支持。



## 📋 环境要求## 📋 环境要求



- **Go 版本**: 1.24.7 或更高版本 ⚠️ **必须**- **Go 版本**: 1.24.7 或更高版本 ⚠️ **必须**

- **Git**: 用于获取源码和应用补丁- **Git**: 用于获取源码和应用补丁

- **操作系统**: Linux / macOS / Windows

### 🚀 快速升级 Go

> **重要**: 由于 sing-box v1.13.0+ 的 go.mod 要求，本项目现在只支持 Go 1.24.7 及以上版本。

```bash> 

./install-go.sh> 📖 **详细说明**: [Go 版本要求说明](docs/go-version-requirements.md)

source ~/.bashrc

go version### 🚀 快速升级 Go (Linux/macOS)

```

如果您的 Go 版本过低，可以使用我们提供的快速安装脚本：

## 🚀 快速开始

```bash

### 自动编译# 下载并安装 Go 1.24.7

./install-go.sh

```bash

# 编译完整版本# 重新加载环境变量

./build.shsource ~/.bashrc



# 编译基础版本# 验证版本

./build.sh --basicgo version

``````# 编译 (包含所#### 3. 编译 (包含所有功能)

```bash

### 手动编译cd /path/to/sing-box



```bash# 编译完整版本 (推荐) - 包含 Tailscale 支持

# 1. 获取官方源码go build -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=$(go run github.com/sagernet/sing-box/cmd/internal/read_tag@latest)'" -tags "with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor,with_tailscale" -o sing-box-full ./cmd/sing-box

git clone https://github.com/SagerNet/sing-box.git

cd sing-box# 或编译基础版本 (不含 Tailscale)

git checkout v1.13.0-alpha.15go build -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=$(go run github.com/sagernet/sing-box/cmd/internal/read_tag@latest)'" -tags "with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor" -o sing-box-basic ./cmd/sing-box



# 2. 应用补丁# 最小版本 (仅 ClashAPI)

/path/to/sing-box-patch/apply-patch.sh $(pwd)go build -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=$(go run github.com/sagernet/sing-box/cmd/internal/read_tag@latest)'" -tags "with_clash_api" -o sing-box-minimal ./cmd/sing-box

```

# 3. 编译

go build -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=$(go run github.com/sagernet/sing-box/cmd/internal/read_tag@latest)'" -tags "with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor,with_tailscale" -o sing-box-full ./cmd/sing-box> **版本对比**：

```> - **完整版** (~46MB)：包含所有功能，支持 Tailscale、WireGuard、DHCP 等

> - **基础版** (~25MB)：包含 ClashAPI 和基础代理功能，适合轻量部署

## ✨ 功能特性>

> **重要**: 本项目已完全采用 CGO 启用模式以获得最佳性能和兼容性sh

- **🌐 远程订阅**: 支持从URL自动获取节点配置cd /path/to/sing-box

- **📁 本地文件**: 支持从本地文件读取节点配置  

- **📝 内联配置**: 支持直接在配置中定义节点列表# 编译完整版本 (推荐)

- **🎯 增强选择器**: 支持 include/exclude 过滤go build -tags "with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor,with_tailscale" -o sing-box-full ./cmd/sing-box

- **🛠️ ClashAPI**: 完整的 Provider 管理端点

# 或编译基础版本

## 📝 配置示例go build -tags "with_clash_api" -o sing-box-basic ./cmd/sing-box

```rNet/sing-box 添加 providers 订阅功能和增强的 ClashAPI 支持，实现与 yelnoo/sing-box 的完全兼容。

查看 `examples/` 目录下的配置示例。

## ✨ 功能特性

## 🧪 支持的版本

### 🔗 Providers 订阅支持

| sing-box 版本 | Go 版本要求 | 测试状态 |- **🌐 远程订阅 (Remote)**：支持从URL自动获取节点配置，自动更新间隔配置

|-------------|-----------|---------|- **📁 本地文件 (Local)**：支持从本地文件读取节点配置，支持文件监听

| v1.13.0-alpha.15 | **≥ 1.24.7** | ✅ 推荐 |- **📝 内联配置 (Inline)**：支持直接在配置中定义节点列表

| v1.13.0-alpha.11 | **≥ 1.24.7** | ✅ 支持 |

### 🎯 增强的组别选择器

## 📄 许可证- **📡 providers 字段**：在 selector/urltest 等组别中通过 providers 字段调用订阅中的节点

- **🔍 过滤支持**：支持 include/exclude 正则表达式过滤节点名称

本项目采用与 sing-box 相同的 **GPL-3.0** 许可证。- **🔄 自动选择**：支持自动使用所有可用的 provider 节点
- **⚖️ 负载均衡**：支持 urltest 等负载均衡策略

### 🛠️ ClashAPI 功能增强
- **📊 Provider 管理**：`/providers/proxies` 端点用于管理代理提供者
- **📋 提供者信息**：查看提供者状态、节点数量、更新时间等
- **🔄 手动更新**：支持手动触发订阅更新 (`PUT /providers/{name}`)
- **❤️ 健康检查**：支持对 provider 中的节点进行延迟测试
- **🎮 节点切换**：支持通过 API 切换选择器的当前节点

### 🎉 测试验证
- ✅ **编译测试**：完整测试了所有补丁文件的编译
- ✅ **功能测试**：验证了 provider 订阅、节点过滤、选择器等功能
- ✅ **API测试**：验证了 ClashAPI 的所有相关端点
- ✅ **兼容性测试**：确保与 yelnoo/sing-box 配置格式完全兼容

## 📁 项目结构

```
sing-box-provider-patch/
├── README.md                    # 📖 项目说明文档
├── apply-patch.sh              # 🔧 补丁应用脚本
├── build/                      # 🏗️ 编译产物目录
│   └── sing-box-full           # 编译好的二进制文件 (包含所有功能)
├── source/                     # 📂 完整源码文件
│   ├── adapter/                # 适配器相关代码
│   ├── common/                 # 通用功能代码
│   ├── constant/               # 常量定义
│   ├── experimental/           # 实验性功能 (ClashAPI等)
│   ├── include/                # 模块注册
│   ├── option/                 # 配置选项
│   ├── protocol/               # 协议组选择器
│   ├── provider/               # 🔗 Provider核心实现
│   └── route/                  # 路由增强
├── patches/                    # 📦 Git补丁文件目录
│   ├── adapter/                # 适配器相关补丁
│   ├── experimental/           # 实验性功能补丁
│   ├── include/                # 注册相关补丁
│   ├── option/                 # 配置选项补丁
│   ├── protocol/               # 协议组补丁
│   └── provider/               # Provider实现补丁
├── examples/                   # 📋 配置示例
│   ├── inline-provider.json    # 内联 Provider 配置示例
│   ├── remote-provider.json    # 远程 Provider 配置示例
│   └── complete-config.json    # 完整配置示例
└── docs/                       # 📚 详细文档
    ├── provider-guide.md       # Provider 使用指南
    ├── clashapi-guide.md       # ClashAPI 使用指南
    └── build-guide.md          # 编译指南
```

## 🚀 快速开始

### 方式一：使用预编译版本 (推荐)

```bash
# 1. 下载本项目
git clone https://github.com/yourusername/sing-box-provider-patch.git
cd sing-box-provider-patch

# 2. 直接使用预编译的二进制文件
chmod +x build/sing-box-full
./build/sing-box-full version

# 3. 使用示例配置启动
./build/sing-box-full run -c examples/complete-config.json
```

### 方式二：手动编译

#### 1. 获取官方源码
```bash
git clone https://github.com/SagerNet/sing-box.git
cd sing-box
git checkout v1.13.0-alpha.15  # 推荐使用的版本
```

#### 2. 应用补丁
```bash
# 克隆补丁项目
git clone https://github.com/yourusername/sing-box-provider-patch.git

# 应用补丁 (自动模式)
cd sing-box-provider-patch
./apply-patch.sh /path/to/sing-box

# 或者手动复制源码文件
cp -r source/* /path/to/sing-box/
```

#### 3. 编译 (包含所有功能)
```bash
cd /path/to/sing-box

# 编译完整版本 (推荐)
go build -tags "with_dhcp,with_wireguard,with_shadowsocksr,with_utls,with_reality,with_clash_api,with_quic,with_grpc,with_v2ray_api,with_gvisor" -o sing-box-full ./cmd/sing-box

# 或编译基础版本
go build -tags "with_clash_api" -o sing-box-basic ./cmd/sing-box
```

## 📝 配置示例

### 1. 远程 Provider 配置
```json
{
  "providers": [
    {
      "type": "remote",
      "tag": "my-subscription",
      "url": "https://example.com/subscription",
      "update_interval": "24h",
      "health_check": {
        "enabled": true,
        "url": "https://www.google.com/generate_204",
        "interval": "10m"
      }
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy",
      "providers": ["my-subscription"],
      "exclude": "测试|过期",
      "default": "auto"
    }
  ]
}
```

### 2. 内联 Provider 配置
```json
{
  "providers": [
    {
      "type": "inline",
      "tag": "manual-nodes",
      "outbounds": [
        {
          "type": "vless",
          "tag": "香港节点",
          "server": "hk.example.com",
          "server_port": 443,
          "uuid": "your-uuid-here",
          "tls": { "enabled": true }
        }
      ]
    }
  ],
  "outbounds": [
    {
      "type": "selector", 
      "tag": "国外",
      "providers": ["manual-nodes"],
      "include": "香港|美国|日本"
    }
  ]
}
```

### 3. 多 Provider 混合配置
```json
{
  "providers": [
    {
      "type": "remote",
      "tag": "订阅A", 
      "url": "https://sub1.example.com/link"
    },
    {
      "type": "remote",
      "tag": "订阅B",
      "url": "https://sub2.example.com/link"  
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "国外",
      "providers": ["订阅A", "订阅B"],
      "exclude": "家宽|测试"
    },
    {
      "type": "selector", 
      "tag": "国内",
      "outbounds": ["直连"],
      "providers": ["订阅A"],
      "include": "家宽|直连"
    }
  ]
}
```

### 4. ClashAPI 使用示例
```bash
# 查看所有 Provider 状态
curl http://127.0.0.1:9090/providers/proxies

# 查看特定选择器状态  
curl http://127.0.0.1:9090/proxies/国外

# 切换选择器节点
curl -X PUT -H "Content-Type: application/json" \
  -d '{"name": "香港节点"}' \
  http://127.0.0.1:9090/proxies/国外

# 手动更新 Provider
curl -X PUT http://127.0.0.1:9090/providers/my-subscription
```

## 🧪 支持的版本

该补丁已在以下 sing-box 版本上测试通过：

| sing-box 版本 | Go 版本要求 | 测试状态 | 说明 |
|-------------|-----------|---------|-----|
| v1.13.0-alpha.15 | **≥ 1.24.7** | ✅ 完全支持 | **推荐版本**，最新功能支持 |
| v1.13.0-alpha.11 | **≥ 1.24.7** | ✅ 完全支持 | 已测试版本，功能完整 |
| v1.12.x 系列 | ≥ 1.21.0 | ⚠️ 部分支持 | 功能完整，但建议升级 |
| v1.11.x 系列 | ≥ 1.21.0 | ⚠️ 部分支持 | 需要少量调整 |
| v1.10.x 系列 | ≥ 1.20.0 | ❌ 不支持 | 架构差异较大 |

> **重要提醒**: v1.13.0+ 版本强制要求 Go 1.24.7+，这是 sing-box 官方的硬性要求。

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个项目！

### 开发流程
1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

### 问题反馈
- **Bug 报告**：请提供详细的错误信息和复现步骤
- **功能请求**：请描述期望的功能和使用场景
- **问题咨询**：可以在 Discussions 中提问

## 📄 许可证

本项目采用与 sing-box 相同的 **GPL-3.0** 许可证。

## ⭐ 致谢

- 感谢 [SagerNet/sing-box](https://github.com/SagerNet/sing-box) 提供优秀的核心框架
- 感谢 [yelnoo/sing-box](https://github.com/yelnoo/sing-box) 提供 Provider 功能的原始实现
- 感谢所有为这个项目做出贡献的开发者

---

**🌟 如果这个项目对您有帮助，请给个 Star ⭐！**