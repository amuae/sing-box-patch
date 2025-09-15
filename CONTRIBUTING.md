# 贡献指南

感谢您对amuae-sing-box项目的关注！我们欢迎各种形式的贡献。

## 🤝 贡献方式

### 🐛 报告问题
- 使用GitHub Issues报告bug
- 提供详细的复现步骤和环境信息
- 附上相关的配置文件和日志（注意隐私信息）

### 💡 功能建议
- 在Issues中描述新功能的使用场景
- 说明功能的必要性和实现思路
- 讨论对现有功能的影响

### 🔧 代码贡献
- Fork本仓库
- 创建功能分支
- 提交Pull Request

## 📋 开发指南

### 🏗️ 项目结构

```
amuae-sing-box/
├── patches/                 # 补丁文件
│   ├── new-files/          # 新增文件
│   └── modifications/      # 修改补丁
├── .github/workflows/      # CI/CD配置
├── docs/                   # 文档
├── examples/              # 配置示例
└── apply-patches.sh       # 补丁应用脚本
```

### 🔄 开发流程

1. **环境准备**
   ```bash
   # 克隆仓库
   git clone https://github.com/amuae/amuae-sing-box.git
   cd amuae-sing-box
   
   # 克隆上游sing-box
   git clone https://github.com/SagerNet/sing-box.git test-env
   cd test-env
   git checkout dev-next
   ```

2. **应用补丁**
   ```bash
   # 复制补丁文件
   cp -r ../patches .
   cp ../apply-patches.sh .
   
   # 应用补丁
   chmod +x apply-patches.sh
   ./apply-patches.sh
   ```

3. **开发和测试**
   ```bash
   # 构建测试
   go build -tags "with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,with_clash_api,with_tailscale" ./cmd/sing-box
   
   # 配置测试
   ./sing-box format -c ../examples/config-example.json
   ./sing-box check -c ../examples/config-example.json
   ```

### 📦 补丁创建

如果需要修改现有功能：

1. **创建修改补丁**
   ```bash
   # 在sing-box目录中
   git diff > ../patches/modifications/your-feature.patch
   ```

2. **添加新文件**
   ```bash
   # 将新文件复制到patches/new-files/
   cp new-file.go ../patches/new-files/relative/path/
   ```

3. **更新apply-patches.sh**
   ```bash
   # 在脚本中添加新的补丁应用逻辑
   ```

### 🧪 测试要求

在提交PR前，请确保：

- [ ] 补丁能在干净环境中正确应用
- [ ] 代码能成功编译
- [ ] Provider功能正常工作
- [ ] 配置文件验证通过
- [ ] 不破坏现有功能

## 📝 提交规范

### Commit Message格式

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**类型 (type):**
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `patch`: 补丁更新
- `ci`: CI/CD相关
- `refactor`: 代码重构

**示例:**
```
feat(provider): 添加健康检查超时配置

- 支持自定义健康检查超时时间
- 默认值为5秒
- 向后兼容现有配置

Closes #123
```

### Pull Request模板

```markdown
## 📋 变更描述
简要描述此PR的改动。

## 🎯 变更类型
- [ ] Bug修复
- [ ] 新功能
- [ ] 文档更新
- [ ] 补丁更新
- [ ] CI/CD改进

## 🧪 测试情况
- [ ] 本地测试通过
- [ ] 补丁应用正常
- [ ] 功能验证完成
- [ ] 配置兼容性确认

## 📚 相关Issue
关联的Issue编号（如果有）

## 📝 额外说明
其他需要说明的内容
```

## 🔍 代码审查

### 审查要点
- 代码质量和规范
- 功能完整性
- 向后兼容性
- 安全性考虑
- 文档完整性

### 审查流程
1. 自动化测试检查
2. 代码质量审查
3. 功能测试验证
4. 文档审查
5. 最终批准和合并

## 🐛 问题调试

### 常见问题

1. **补丁应用失败**
   - 检查目标文件是否存在
   - 确认补丁格式正确
   - 验证上游代码版本

2. **编译错误**
   - 检查Go版本兼容性
   - 确认依赖包完整
   - 查看详细错误信息

3. **功能异常**
   - 启用debug日志
   - 检查配置文件语法
   - 验证网络连接

### 调试技巧

```bash
# 详细构建信息
go build -v -x

# 运行时调试
./sing-box run -c config.json --debug

# 补丁调试
git apply --check patch-file
```

## 📞 联系方式

- **GitHub Issues**: 技术问题和功能讨论
- **Pull Requests**: 代码贡献
- **Discussions**: 一般性讨论和交流

## 📄 许可证

通过贡献代码，您同意您的贡献将按照项目的许可证进行授权。

---

🙏 **感谢您的贡献！** 每一个贡献都让这个项目变得更好。