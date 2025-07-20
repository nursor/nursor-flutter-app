import Foundation

@objc public protocol NursorCoreServiceProtocol {
    func startService(reply: @escaping (Bool, Error?) -> Void)
    func stopService(reply: @escaping (Bool, Error?) -> Void)
}