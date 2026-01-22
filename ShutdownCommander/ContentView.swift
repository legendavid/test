import SwiftUI

struct ContentView: View {
    @AppStorage("ssh.host") private var host = ""
    @AppStorage("ssh.port") private var port = 22
    @AppStorage("ssh.username") private var username = ""
    @AppStorage("ssh.password") private var password = ""
    @AppStorage("ssh.shutdownCommand") private var shutdownCommand = "sudo /sbin/shutdown -h now"

    @State private var statusMessage = ""
    @State private var isRunning = false
    @State private var isTesting = false

    private let sshClient = SSHClient()

    var body: some View {
        NavigationStack {
            Form {
                Section("连接信息") {
                    TextField("主机地址 (例如 192.168.1.10)", text: $host)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Stepper(value: $port, in: 1...65535) {
                        HStack {
                            Text("端口")
                            Spacer()
                            Text("\(port)")
                                .foregroundColor(.secondary)
                        }
                    }

                    TextField("用户名", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("密码", text: $password)
                }

                Section("关机命令") {
                    TextEditor(text: $shutdownCommand)
                        .frame(minHeight: 80)
                        .font(.body)
                    Text("需要确保目标机器允许该命令执行，可考虑配置 sudo 无密码执行。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section {
                    Button {
                        runShutdown()
                    } label: {
                        HStack {
                            Spacer()
                            if isRunning {
                                ProgressView()
                            } else {
                                Label("立即关机", systemImage: "power.circle.fill")
                                    .fontWeight(.semibold)
                                    .labelStyle(.titleAndIcon)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isRunning || isTesting || host.isEmpty || username.isEmpty || password.isEmpty)
                }

                Section("连接测试") {
                    Button {
                        runConnectionTest()
                    } label: {
                        HStack {
                            Spacer()
                            if isTesting {
                                ProgressView()
                            } else {
                                Label("测试 SSH 连通性", systemImage: "bolt.horizontal.circle.fill")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isRunning || isTesting || host.isEmpty || username.isEmpty || password.isEmpty)
                }

                if !statusMessage.isEmpty {
                    Section("状态") {
                        Text(statusMessage)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("局域网关机")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "desktopcomputer.and.arrow.down")
                            .foregroundColor(.accentColor)
                        Text("局域网关机")
                            .font(.headline)
                    }
                }
            }
        }
    }

    private func runShutdown() {
        isRunning = true
        statusMessage = "正在发送关机指令..."

        let config = SSHConfig(
            host: host,
            port: port,
            username: username,
            password: password,
            shutdownCommand: shutdownCommand
        )

        sshClient.runShutdown(config: config) { result in
            isRunning = false
            switch result {
            case let .success(response):
                statusMessage = response.isEmpty ? "命令已发送。" : response
            case let .failure(error):
                statusMessage = error.localizedDescription
            }
        }
    }

    private func runConnectionTest() {
        isTesting = true
        statusMessage = "正在测试 SSH 连通性..."

        let config = SSHConfig(
            host: host,
            port: port,
            username: username,
            password: password,
            shutdownCommand: shutdownCommand
        )

        sshClient.testConnection(config: config) { result in
            isTesting = false
            switch result {
            case .success:
                statusMessage = "连接成功，认证通过。"
            case let .failure(error):
                statusMessage = error.localizedDescription
            }
        }
    }
}
