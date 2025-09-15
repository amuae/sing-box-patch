# amuae-sing-box# sing-box



基于官方 [SagerNet/sing-box](https://github.com/SagerNet/sing-box) 的Provider支持版本，集成了 [yelnoo/sing-box](https://github.com/yelnoo/sing-box) 的Provider功能。The universal proxy platform.



## 🚀 特性[![Packaging status](https://repology.org/badge/vertical-allrepos/sing-box.svg)](https://repology.org/project/sing-box/versions)



本仓库通过补丁系统为官方sing-box添加了以下Provider支持功能：## Documentation



### 📦 Provider类型https://sing-box.sagernet.org

- **远程Provider**: 支持从URL获取订阅链接

- **本地Provider**: 支持从本地文件读取配置  ## License

- **内联Provider**: 直接在配置中定义outbound列表

```

### 🔧 核心功能Copyright (C) 2022 by nekohasekai <contact-sagernet@sekai.icu>

- ✅ **健康检查**: 自动监控节点健康状态

- ✅ **自动更新**: 定时更新远程订阅This program is free software: you can redistribute it and/or modify

- ✅ **节点过滤**: 支持正则表达式过滤it under the terms of the GNU General Public License as published by

- ✅ **增强组**: Selector/URLTest组支持Provider数据源the Free Software Foundation, either version 3 of the License, or

- ✅ **配置验证**: 扩展的配置选项和验证(at your option) any later version.



## 🛠️ 构建方式This program is distributed in the hope that it will be useful,

but WITHOUT ANY WARRANTY; without even the implied warranty of

### 自动构建 (推荐)MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

GNU General Public License for more details.

使用GitHub Actions自动从官方最新源码构建：

You should have received a copy of the GNU General Public License

1. 进入仓库的 [Actions页面](../../actions)along with this program. If not, see <http://www.gnu.org/licenses/>.

2. 选择 "Build sing-box with Provider Support" 工作流

3. 点击 "Run workflow"In addition, no derivative work may use the name or imply association

4. 配置构建参数：with this application without prior consent.

   - **上游仓库**: 默认 `SagerNet/sing-box````
   - **分支/标签**: 默认 `dev-next`，可选择特定版本如 `v1.13.0-alpha.14`
   - **版本后缀**: 默认 `-provider`
   - **构建平台**: 选择要构建的平台

### 支持平台

- **Linux**: AMD64, ARM64
- **Windows**: AMD64
- **Android**: ARM64

### 手动构建

```bash
# 1. 克隆官方sing-box仓库
git clone -b dev-next https://github.com/SagerNet/sing-box.git
cd sing-box

# 2. 下载并应用补丁
curl -O https://raw.githubusercontent.com/amuae/sing-box/main/apply-patches.sh
curl -L https://github.com/amuae/sing-box/archive/main.tar.gz | tar -xz --strip-components=1 amuae-sing-box-main/patches
chmod +x apply-patches.sh
./apply-patches.sh

# 3. 构建
go build -tags "with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,with_clash_api,with_tailscale" ./cmd/sing-box
```

## 📋 配置示例

### Provider配置

```json
{
  "providers": [
    {
      "tag": "remote-provider",
      "type": "remote",
      "url": "https://example.com/subscription",
      "update_interval": "24h",
      "health_check": {
        "enable": true,
        "url": "https://www.google.com/generate_204",
        "interval": "10m"
      }
    },
    {
      "tag": "local-provider", 
      "type": "local",
      "path": "/path/to/config.json"
    },
    {
      "tag": "inline-provider",
      "type": "inline",
      "outbounds": [
        {
          "tag": "direct",
          "type": "direct"
        }
      ]
    }
  ],
  "outbounds": [
    {
      "tag": "auto",
      "type": "selector",
      "providers": ["remote-provider", "local-provider"],
      "default": "direct"
    }
  ]
}
```

### URLTest组配置

```json
{
  "outbounds": [
    {
      "tag": "fastest",
      "type": "urltest",
      "providers": ["remote-provider"],
      "url": "https://www.google.com/generate_204",
      "interval": "5m",
      "tolerance": 50
    }
  ]
}
```

## 🔄 自动化流程

### 工作流程设计

1. **初始化环境**: 设置Go环境和构建工具
2. **获取源码**: 从指定的官方仓库拉取最新源码
3. **应用补丁**: 自动应用保存的Provider支持补丁
4. **构建二进制**: 为四个目标平台构建优化的二进制文件
5. **创建Release**: 自动创建GitHub Release并上传构建产物
6. **清理环境**: 删除临时文件和构建缓存

### 补丁系统

本仓库使用补丁系统来保持与官方代码的兼容性：

- `patches/new-files/`: 新增的Provider相关文件
- `patches/modifications/`: 对现有文件的修改补丁
- `apply-patches.sh`: 自动应用补丁的脚本

## 📚 技术细节

### Provider架构

```
Provider Interface
├── Remote Provider (订阅管理)
├── Local Provider (本地文件)
└── Inline Provider (内联配置)

Enhanced Groups  
├── Selector (支持Provider)
└── URLTest (支持Provider)

Health Check System
├── 节点健康监控
├── 自动故障切换
└── 定时健康检查
```

### 集成的文件

**新增文件**:
- `adapter/provider.go` - Provider接口定义
- `adapter/provider/` - Provider实现
- `constant/provider.go` - Provider常量
- `option/provider.go` - Provider配置选项
- `provider/` - Provider具体实现

**修改文件**:
- `box.go` - 核心服务集成
- `option/options.go` - 主配置结构
- `option/group.go` - 组配置扩展
- `include/registry.go` - 服务注册
- `protocol/group/` - 组实现增强

## 🔗 相关链接

- [官方sing-box](https://github.com/SagerNet/sing-box)
- [yelnoo/sing-box](https://github.com/yelnoo/sing-box) (Provider功能来源)
- [Release页面](../../releases) - 下载预编译版本

## 📄 许可证

本项目遵循与官方sing-box相同的许可证。补丁代码基于yelnoo/sing-box的实现。

---

> 🤖 **自动化构建**  
> 本仓库不包含完整源码，只保存Provider支持的补丁。  
> 每次构建都会从官方仓库拉取最新源码并自动应用补丁。