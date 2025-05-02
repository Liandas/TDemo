//
//  NetworkStatus.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//


import Network

final class NetworkReachabilityImp:NetworkReachability {
    static let shared: NetworkReachability = NetworkReachabilityImp()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private(set) var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            Logger.shared.log("Network Status changed: \(path.status)", level: .debug)
        }
        monitor.start(queue: queue)
    }
}
