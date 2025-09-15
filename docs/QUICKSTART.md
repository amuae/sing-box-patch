# 快速使用指南

## 🚀 快速开始

### 1. 下载预编译版本

访问 [Releases页面](../releases) 下载对应平台的版本：

- **Linux AMD64**: `sing-box-*-linux-amd64.tar.gz`
- **Linux ARM64**: `sing-box-*-linux-arm64.tar.gz`  
- **Windows AMD64**: `sing-box-*-windows-amd64.zip`
- **Android ARM64**: `sing-box-*-android-arm64.tar.gz`

### 2. 解压和安装

```bash
# Linux/macOS
tar -xzf sing-box-*-linux-amd64.tar.gz
cd sing-box-*-linux-amd64/
chmod +x sing-box

# Windows (使用PowerShell)
Expand-Archive sing-box-*-windows-amd64.zip
cd sing-box-*-windows-amd64/
```

### 3. 创建配置文件

复制示例配置并修改：

```bash
# 复制示例配置
cp examples/config-example.json config.json

# 编辑配置文件
nano config.json  # 或使用其他编辑器
```

**需要修改的主要部分：**

1. **替换订阅链接**：
   ```json
   {
     "tag": "机场订阅",
     "type": "remote", 
     "remote_url": "https://your-provider.com/subscription?token=your-token"
   }
   ```

2. **调整过滤规则**（可选）：
   ```json
   {
     "includes": ["🇭🇰", "🇺🇸", "🇯🇵"],
     "excludes": ["过期", "测试"]
   }
   ```

3. **修改监听端口**（可选）：
   ```json
   {
     "listen_port": 2080  // 改为你需要的端口
   }
   ```

### 4. 验证配置

```bash
# 格式化配置（检查语法）
./sing-box format -c config.json

# 验证配置
./sing-box check -c config.json
```

### 5. 运行服务

```bash
# 前台运行（调试用）
./sing-box run -c config.json

# 后台运行（Linux/macOS）
nohup ./sing-box run -c config.json > singbox.log 2>&1 &

# 查看日志
tail -f singbox.log
```

### 6. 配置客户端

在你的浏览器或应用中设置代理：

- **HTTP/HTTPS代理**: `127.0.0.1:2080`
- **SOCKS5代理**: `127.0.0.1:2080`

## 📋 常用配置模式

### 🌐 纯远程订阅

最简单的配置，只使用远程订阅：

```json
{
  "providers": [
    {
      "tag": "main",
      "type": "remote",
      "remote_url": "https://example.com/subscription"
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": ["provider://main", "direct"]
    }
  ]
}
```

### 🔄 自动选择最快节点

使用URLTest自动选择延迟最低的节点：

```json
{
  "outbounds": [
    {
      "tag": "auto",
      "type": "urltest", 
      "outbounds": ["provider://main"],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "10m"
    }
  ]
}
```

### 📁 多Provider组合

结合远程订阅和本地备用：

```json
{
  "providers": [
    {
      "tag": "primary",
      "type": "remote",
      "remote_url": "https://provider1.com/sub"
    },
    {
      "tag": "backup", 
      "type": "local",
      "path": "./backup.json"
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "type": "selector",
      "outbounds": [
        "provider://primary",
        "provider://backup"
      ]
    }
  ]
}
```

## 🔧 进阶配置

### ❤️ 健康检查

启用自动健康检查，及时发现不可用节点：

```json
{
  "health_check": {
    "enable": true,
    "url": "https://www.gstatic.com/generate_204",
    "interval": "10m",
    "timeout": "5s"
  }
}
```

### 🎯 节点过滤

使用正则表达式精确控制节点：

```json
{
  "includes": [
    "🇭🇰|香港|HK|Hong Kong",
    "Premium.*",
    ".*x1\\."
  ],
  "excludes": [
    "过期|到期|Expire",
    "x0\\.|x0\\d",
    "测试|Test.*"
  ]
}
```

### ⏰ 更新策略

配置合适的更新间隔：

```json
{
  "download_interval": "6h",     // 每6小时更新
  "download_ua": "clash.meta",   // 使用特定UA
  "download_detour": "direct"    // 通过直连更新
}
```

## 🛠️ 管理和维护

### 📊 查看运行状态

```bash
# 检查进程
ps aux | grep sing-box

# 查看端口
netstat -tlnp | grep 2080

# 实时日志
tail -f singbox.log
```

### 🔄 重载配置

```bash
# 停止服务
pkill sing-box

# 验证新配置
./sing-box check -c config.json

# 重新启动
./sing-box run -c config.json
```

### 🗂️ 系统服务（Linux）

创建systemd服务：

```bash
# 创建服务文件
sudo tee /etc/systemd/system/sing-box.service > /dev/null <<EOF
[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target

[Service]
User=nobody
WorkingDirectory=/opt/sing-box
ExecStart=/opt/sing-box/sing-box run -c /opt/sing-box/config.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
sudo systemctl enable sing-box
sudo systemctl start sing-box
sudo systemctl status sing-box
```

## 🐛 问题排查

### ❌ 常见错误

1. **配置格式错误**
   ```bash
   ./sing-box format -c config.json
   ```

2. **端口被占用**
   ```bash
   netstat -tlnp | grep 2080
   sudo lsof -i :2080
   ```

3. **网络连接问题**
   ```bash
   curl -v "https://www.gstatic.com/generate_204"
   ```

4. **订阅更新失败**
   - 检查订阅链接是否可访问
   - 确认网络连接正常
   - 查看详细日志信息

### 📝 调试模式

启用详细日志：

```json
{
  "log": {
    "level": "debug",
    "timestamp": true
  }
}
```

## 📚 更多资源

- **[完整文档](PROVIDER.md)** - Provider详细配置说明
- **[官方文档](https://sing-box.sagernet.org)** - sing-box官方文档
- **[配置示例](../examples/)** - 更多配置模板
- **[GitHub Issues](../issues)** - 问题反馈和讨论

---

💡 **小贴士**: 建议先在测试环境验证配置，确认无误后再部署到生产环境。