# ShutdownCommander

一个可安装到 iPhone 的 iOS App，通过 SSH 连接到家中局域网台式机并执行关机命令。关机参数可在 App 内配置。

## 功能

- 保存主机地址、端口、用户名与密码。
- 可自定义关机命令（例如 `sudo /sbin/shutdown -h now`）。
- 一键发送关机指令并显示执行结果。

## 构建方式

1. 使用 Xcode 15+ 创建一个新的 iOS App 项目（SwiftUI）。
2. 将 `ShutdownCommander` 目录中的 Swift 文件复制到项目中。
3. 在 Xcode 中添加 Swift Package 依赖：
   - Package URL: `https://github.com/NMSSH/NMSSH`
   - 版本：`2.2.7` 或最新稳定版。
4. 选择你的真机并运行，即可安装到手机。

## 使用说明

1. 确保 iPhone 与台式机在同一局域网中。
2. 在 App 内输入台式机的 IP、端口、用户名与密码。
3. 根据需要修改关机命令（可以设置为 `sudo /sbin/shutdown -h now` 或其他参数）。
4. 点击「立即关机」发送指令。

## 目标电脑建议配置

- 确保 SSH 服务开启。
- 若使用 `sudo`，建议配置无密码 sudo（仅限关机命令）以避免交互阻塞。

```bash
sudo visudo
# 添加类似行：
# youruser ALL=(ALL) NOPASSWD: /sbin/shutdown
```
