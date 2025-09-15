# Provider Support Documentation

## 🚀 概述

Provider 是对 sing-box 的扩展功能，允许你从远程订阅、本地文件或内联配置中动态加载和管理出站节点。这个功能特别适合需要管理多个订阅源或希望实现节点自动更新的用户。

## ✨ 核心特性

- **🌐 远程订阅**: 自动从URL获取和更新节点配置
- **📁 本地文件**: 从本地JSON文件加载节点配置
- **📝 内联配置**: 直接在配置中定义节点
- **🔄 自动更新**: 支持定时更新远程订阅
- **❤️ 健康检查**: 自动检测节点可用性
- **🎯 选择器集成**: 与Selector/URLTest无缝配合

## 📋 配置格式

### 基础结构

```json
{
  "providers": [
    {
      "tag": "provider-name",
      "type": "remote|local|inline",
      // 类型特定配置...
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy",
      "outbounds": [
        "provider://provider-name",
        "direct-outbound"
      ]
    }
  ]
}
```

### 1. 远程Provider (Remote)

从远程URL获取节点配置，支持多种订阅格式。

```json
{
  "tag": "remote-subscription",
  "type": "remote",
  "remote_url": "https://example.com/subscription",
  "download_interval": "24h",
  "download_ua": "clash.meta",
  "download_detour": "direct",
  "includes": ["🇺🇸", "🇯🇵"],
  "excludes": ["过期", "维护"],
  "health_check": {
    "enable": true,
    "url": "https://www.gstatic.com/generate_204",
    "interval": "10m"
  }
}
```

**参数说明:**
- `remote_url`: 订阅链接
- `download_interval`: 更新间隔 (如: "1h", "24h", "7d")
- `download_ua`: 下载时使用的User-Agent
- `download_detour`: 下载时使用的出站标签
- `includes`: 包含规则 (支持正则表达式)
- `excludes`: 排除规则 (支持正则表达式)
- `health_check`: 健康检查配置

### 2. 本地Provider (Local)

从本地文件加载节点配置。

```json
{
  "tag": "local-nodes",
  "type": "local", 
  "path": "./configs/local-outbounds.json",
  "includes": ["香港", "台湾"],
  "excludes": ["测试"],
  "health_check": {
    "enable": true,
    "url": "https://www.gstatic.com/generate_204",
    "interval": "5m"
  }
}
```

**本地文件格式 (local-outbounds.json):**
```json
{
  "outbounds": [
    {
      "tag": "hk-01",
      "type": "shadowsocks",
      "server": "hk.example.com",
      "server_port": 8388,
      "method": "aes-256-gcm",
      "password": "password"
    }
  ]
}
```

### 3. 内联Provider (Inline)

直接在配置中定义节点。

```json
{
  "tag": "inline-nodes",
  "type": "inline",
  "outbounds": [
    {
      "tag": "direct-hk",
      "type": "shadowsocks", 
      "server": "hk.example.com",
      "server_port": 8388,
      "method": "aes-256-gcm",
      "password": "password"
    },
    {
      "tag": "direct-us",
      "type": "vmess",
      "server": "us.example.com",
      "server_port": 443,
      "uuid": "uuid-here",
      "security": "auto"
    }
  ],
  "includes": ["direct-.*"],
  "health_check": {
    "enable": false
  }
}
```

## 🎯 选择器集成

Provider可以与Selector和URLTest组无缝集成：

```json
{
  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy-select",
      "outbounds": [
        "provider://remote-subscription",
        "provider://local-nodes", 
        "provider://inline-nodes",
        "direct"
      ]
    },
    {
      "type": "urltest",
      "tag": "auto-select",
      "outbounds": [
        "provider://remote-subscription"
      ],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "10m"
    }
  ]
}
```

## ⚙️ 高级配置

### 健康检查配置

```json
{
  "health_check": {
    "enable": true,
    "url": "https://www.gstatic.com/generate_204",
    "interval": "10m",
    "timeout": "5s",
    "lazy": false,
    "expected_status": 204
  }
}
```

- `enable`: 是否启用健康检查
- `url`: 检查URL
- `interval`: 检查间隔
- `timeout`: 超时时间
- `lazy`: 是否延迟检查
- `expected_status`: 期望的HTTP状态码

### 过滤规则

支持正则表达式的包含和排除规则：

```json
{
  "includes": [
    "🇭🇰|香港|HK|Hong Kong",
    "🇺🇸|美国|US|United States",
    "Premium.*"
  ],
  "excludes": [
    "过期|到期|Expire",
    "官网|群组|Website",
    "测试|Test.*",
    "x0\\.|x0\\d"
  ]
}
```

## 📝 完整配置示例

```json
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "providers": [
    {
      "tag": "机场订阅",
      "type": "remote",
      "remote_url": "https://example.com/subscription?token=xxx",
      "download_interval": "6h",
      "download_ua": "clash.meta",
      "includes": ["🇭🇰", "🇺🇸", "🇯🇵"],
      "excludes": ["过期", "维护", "x0\\."],
      "health_check": {
        "enable": true,
        "url": "https://www.gstatic.com/generate_204",
        "interval": "10m"
      }
    },
    {
      "tag": "本地备用",
      "type": "local",
      "path": "./backup-nodes.json",
      "health_check": {
        "enable": true,
        "interval": "15m"
      }
    }
  ],
  "inbounds": [
    {
      "tag": "mixed-in",
      "type": "mixed",
      "listen": "127.0.0.1",
      "listen_port": 2080
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": [
        "auto",
        "provider://机场订阅",
        "provider://本地备用",
        "direct"
      ]
    },
    {
      "tag": "auto",
      "type": "urltest",
      "outbounds": [
        "provider://机场订阅"
      ],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "10m"
    },
    {
      "tag": "direct",
      "type": "direct"
    }
  ],
  "route": {
    "rule_set": [],
    "rules": [
      {
        "domain_suffix": [
          ".cn"
        ],
        "outbound": "direct"
      }
    ],
    "final": "proxy",
    "auto_detect_interface": true
  }
}
```

## 🔧 命令行工具

### 配置验证

```bash
./sing-box format -c config.json
```

### 配置检查

```bash  
./sing-box check -c config.json
```

### 运行服务

```bash
./sing-box run -c config.json
```

### 查看Provider状态

在运行时，可以通过日志查看Provider状态：

```
INFO provider/remote[机场订阅]: updated outbound provider 机场订阅, outbound count: 15
INFO provider/remote[机场订阅]: health check started
INFO outbound/urltest[auto]: updated latency: hk-01(45ms) us-02(150ms)
```

## 🐛 故障排除

### 常见问题

1. **Provider无法加载**
   - 检查网络连接和URL可访问性
   - 验证订阅格式是否正确
   - 查看日志中的错误信息

2. **节点不出现在选择器中**
   - 检查`includes`和`excludes`规则
   - 确认Provider标签在选择器中正确引用
   - 验证Provider是否成功加载节点

3. **自动更新不工作**
   - 检查`download_interval`设置
   - 确认网络连接稳定
   - 查看更新日志

### 日志调试

启用详细日志：

```json
{
  "log": {
    "level": "debug",
    "timestamp": true
  }
}
```

### 手动测试连接

```bash
# 测试订阅URL
curl -v "https://example.com/subscription"

# 测试健康检查URL  
curl -v "https://www.gstatic.com/generate_204"
```

## 🔄 迁移指南

### 从原生配置迁移

原配置：
```json
{
  "outbounds": [
    {
      "tag": "hk-01",
      "type": "shadowsocks",
      "server": "hk.example.com"
    },
    {
      "tag": "us-01", 
      "type": "vmess",
      "server": "us.example.com"
    }
  ]
}
```

迁移后：
```json
{
  "providers": [
    {
      "tag": "my-nodes",
      "type": "inline",
      "outbounds": [
        {
          "tag": "hk-01",
          "type": "shadowsocks", 
          "server": "hk.example.com"
        },
        {
          "tag": "us-01",
          "type": "vmess",
          "server": "us.example.com"
        }
      ]
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": ["provider://my-nodes"]
    }
  ]
}
```

## 📚 技术细节

### Provider生命周期

1. **初始化**: 解析Provider配置
2. **加载**: 获取节点数据 (远程下载/本地读取)
3. **过滤**: 应用includes/excludes规则
4. **健康检查**: 定期检测节点可用性
5. **更新**: 定时更新远程订阅
6. **集成**: 提供节点给选择器组

### 性能优化

- Provider采用异步加载，不阻塞启动
- 健康检查使用连接池，减少资源消耗
- 远程订阅支持增量更新
- 自动清理不可用节点

### 安全考虑

- 远程下载支持代理和User-Agent设置
- 本地文件访问有路径验证
- 配置解析有格式验证
- 网络请求有超时保护

---

🎉 **享受Provider带来的便利！** 如有问题，请查看项目Issues或提交反馈。