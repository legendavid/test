import Foundation
import NMSSH

final class SSHClient {
    func runShutdown(config: SSHConfig, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let session = NMSSHSession(host: config.host, port: config.port, andUsername: config.username)
            session.connect()

            guard session.isConnected else {
                DispatchQueue.main.async {
                    completion(.failure(SSHClientError.connectionFailed))
                }
                return
            }

            session.authenticate(byPassword: config.password)

            guard session.isAuthorized else {
                session.disconnect()
                DispatchQueue.main.async {
                    completion(.failure(SSHClientError.authenticationFailed))
                }
                return
            }

            var executionError: NSError?
            let response = session.channel.execute(config.shutdownCommand, error: &executionError)
            session.disconnect()

            DispatchQueue.main.async {
                if let executionError = executionError {
                    completion(.failure(SSHClientError.remoteError(executionError.localizedDescription)))
                } else {
                    completion(.success(response ?? ""))
                }
            }
        }
    }
}

enum SSHClientError: LocalizedError {
    case connectionFailed
    case authenticationFailed
    case remoteError(String)

    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "无法连接到主机，请检查地址和端口。"
        case .authenticationFailed:
            return "认证失败，请检查用户名和密码。"
        case let .remoteError(message):
            return "命令执行失败：\(message)"
        }
    }
}
