# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - 2024-09-15

### ✨ Added
- **完整Provider支持系统**
  - Remote Provider: 远程订阅自动获取和更新
  - Local Provider: 本地文件配置加载
  - Inline Provider: 内联节点定义
- **智能健康检查**
  - 自动节点可用性监控
  - 可配置的检查间隔和超时
  - 支持自定义检查URL和期望状态码
- **高级节点过滤**
  - 正则表达式includes/excludes规则
  - 灵活的节点筛选机制
- **增强选择器组**
  - Selector组原生支持Provider数据源
  - URLTest组自动选择最快Provider节点
  - 无缝集成现有outbound配置

### 🔧 Enhanced
- **自动化构建流程**
  - GitHub Actions完整CI/CD管道
  - 多平台构建支持 (Linux AMD64/ARM64, Windows AMD64, Android ARM64)
  - 自动Release管理和构建产物分发
- **配置验证系统**
  - 扩展的配置选项验证
  - Provider配置语法检查
  - 运行时配置热重载支持
- **补丁管理系统**
  - 模块化补丁结构
  - 自动补丁应用脚本
  - 与官方代码的完全兼容性

### 📚 Documentation
- **完整文档体系**
  - Provider详细配置文档 (PROVIDER.md)
  - 快速使用指南 (QUICKSTART.md)
  - 配置示例和最佳实践
- **示例配置文件**
  - 完整配置示例 (config-example.json)
  - 本地节点示例 (backup-nodes.json)
  - 多Provider组合示例

### 🏗️ Architecture
- **Provider核心实现**
  - `common/provider/` - Provider接口和基础实现
  - `adapter/provider.go` - Provider适配器
  - `option/provider.go` - Provider配置选项
- **增强组件**
  - 增强的Selector/URLTest组实现
  - 健康检查系统集成
  - 配置解析和验证扩展

### 🔄 Build System
- **补丁文件结构**
  - `patches/new-files/` - 新增的Provider相关文件 (14个文件)
  - `patches/modifications/` - 现有文件修改补丁 (10个补丁)
  - `apply-patches.sh` - 自动补丁应用脚本
- **GitHub Actions工作流**
  - 自动环境准备和源码获取
  - Provider补丁自动应用和验证
  - 多平台并行构建和测试
  - 自动Release创建和清理

### 🎯 Features
- **远程订阅管理**
  - 支持多种订阅格式解析
  - 可配置的更新间隔和User-Agent
  - 通过指定outbound代理更新
- **本地配置支持**
  - JSON格式本地配置文件
  - 文件变更自动检测
  - 路径安全验证
- **内联节点定义**
  - 直接在配置中定义outbound
  - 支持所有sing-box outbound类型
  - 简化小规模部署配置

### 🛠️ Technical Details
- **Go版本**: 兼容Go 1.23.1
- **构建标签**: 使用官方推荐的feature标签
- **平台支持**: Linux, Windows, Android多平台
- **性能优化**: 异步Provider加载，连接池健康检查

### 📦 Distribution
- **预编译版本**: 通过GitHub Releases自动分发
- **构建产物**: 压缩包含二进制文件、许可证和README
- **版本管理**: 自动版本标签和Release notes生成

---

## 基于版本

本项目基于以下开源项目：

- **[SagerNet/sing-box](https://github.com/SagerNet/sing-box)** - 官方sing-box项目
- **[yelnoo/sing-box](https://github.com/yelnoo/sing-box)** - Provider功能的原始实现

### 兼容性

- ✅ **完全兼容**: 与官方sing-box配置100%兼容
- ✅ **扩展支持**: 新增Provider配置选项，向后兼容
- ✅ **功能增强**: 在不破坏原有功能的基础上增加新特性
- ✅ **API稳定**: 保持与官方API的一致性

---

> 📅 **更新频率**: 本项目会跟随官方sing-box的更新节奏  
> 🔄 **自动化**: 通过CI/CD系统自动构建和发布  
> 🧪 **测试**: 每次构建都包含完整的功能验证测试