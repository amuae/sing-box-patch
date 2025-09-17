# 配置示例说明

本目录包含了各种 Provider 配置的示例文件，帮助您快速开始使用 sing-box Provider 功能。

## 📁 文件说明

### 基础配置示例

- **`remote-provider.json`** - 远程订阅配置示例
  - 演示如何配置远程订阅源
  - 包含健康检查和自动更新设置
  - 展示基本的选择器和过滤配置

- **`local-provider.json`** - 本地文件配置示例  
  - 演示如何从本地文件读取节点配置
  - 适用于手动维护节点列表的场景
  - 需要配合 `nodes.json` 文件使用

- **`inline-provider.json`** - 内联配置示例
  - 演示如何直接在配置中定义节点
  - 适用于少量固定节点的场景
  - 配置更加简洁直观

- **`complete-config.json`** - 完整功能配置示例
  - 展示多 Provider 混合使用
  - 包含完整的路由规则和分流配置
  - 演示高级功能如 TUN 模式、DNS 配置等

### 辅助文件

- **`nodes.json`** - 本地节点配置文件
  - 与 `local-provider.json` 配合使用
  - 展示标准的节点配置格式
  - 支持 VLESS、Shadowsocks、Trojan 等协议

## 🚀 快速使用

### 1. 选择合适的配置

根据您的需求选择对应的配置文件：

```bash
# 使用远程订阅
./sing-box run -c examples/remote-provider.json

# 使用本地文件
./sing-box run -c examples/local-provider.json  

# 使用内联配置
./sing-box run -c examples/inline-provider.json

# 使用完整配置
./sing-box run -c examples/complete-config.json
```

### 2. 自定义配置

修改配置文件中的以下关键部分：

#### 远程订阅配置
```json
{
  "providers": [
    {
      "type": "remote",
      "tag": "my-subscription",
      "url": "https://your-subscription-url-here",  // 替换为您的订阅地址
      "update_interval": "24h"
    }
  ]
}
```

#### 本地文件配置
```json
{
  "providers": [
    {
      "type": "local", 
      "tag": "local-nodes",
      "path": "/path/to/your/nodes.json"  // 替换为您的节点文件路径
    }
  ]
}
```

#### 内联节点配置
```json
{
  "providers": [
    {
      "type": "inline",
      "tag": "manual-nodes",
      "outbounds": [
        // 在这里添加您的节点配置
      ]
    }
  ]
}
```

### 3. 节点过滤配置

所有示例都展示了如何使用 `include` 和 `exclude` 过滤器：

```json
{
  "type": "selector",
  "tag": "filtered-nodes",
  "providers": ["your-provider"],
  "include": "香港|美国|日本",     // 包含关键词
  "exclude": "测试|过期|剩余流量" // 排除关键词
}
```

## 🔧 配置要点

### Provider 类型对比

| 类型 | 优势 | 使用场景 |
|------|------|----------|
| **remote** | 自动更新，支持多种订阅格式 | 机场订阅，定期更新的节点 |
| **local** | 本地控制，支持文件监听 | 自建节点，手动维护 |
| **inline** | 配置简洁，无外部依赖 | 少量固定节点，快速测试 |

### 选择器配置

- **selector**: 手动选择节点
- **urltest**: 自动选择延迟最低的节点
- **providers**: 指定使用哪些 Provider
- **include/exclude**: 正则表达式过滤节点名称

### ClashAPI 配置

所有示例都包含 ClashAPI 配置，启用后可以：

- 通过 Web 界面管理节点
- 查看 Provider 状态和节点信息
- 手动更新订阅和切换节点
- 进行延迟测试和健康检查

访问地址：`http://127.0.0.1:9090`

## 🛠️ 故障排除

### 常见问题

1. **订阅获取失败**
   - 检查网络连接和订阅地址
   - 确认订阅格式是否支持
   - 查看日志输出获取详细错误信息

2. **节点连接失败**
   - 检查节点配置是否正确
   - 确认网络环境是否支持对应协议
   - 使用 ClashAPI 进行延迟测试

3. **过滤器不生效**
   - 检查正则表达式语法
   - 确认节点名称是否包含预期关键词
   - 使用 ClashAPI 查看实际的节点列表

### 调试技巧

- 设置日志级别为 `debug` 获取详细信息
- 使用 ClashAPI 查看实时状态
- 检查配置文件语法是否正确

## 📚 进一步学习

- [Provider 详细指南](../docs/provider-guide.md)
- [ClashAPI 使用指南](../docs/clashapi-guide.md)
- [编译指南](../docs/build-guide.md)

## 💡 提示

- 建议从简单的配置开始，逐步添加功能
- 定期备份您的配置文件
- 关注项目更新获取新功能和修复