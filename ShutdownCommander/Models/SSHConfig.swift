import Foundation

struct SSHConfig: Equatable {
    var host: String
    var port: Int
    var username: String
    var password: String
    var shutdownCommand: String

    static let empty = SSHConfig(
        host: "",
        port: 22,
        username: "",
        password: "",
        shutdownCommand: "sudo /sbin/shutdown -h now"
    )
}
