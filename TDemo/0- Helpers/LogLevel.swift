//
//  LogLevel.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//

import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class Logger {
    
    static let shared = Logger()
    
    private var isLoggingEnabled = false
    
    private let logFileURL: URL? = {
        let fileManager = FileManager.default
        if let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return docs.appendingPathComponent("app_logs.txt")
        }
        return nil
    }()
    
    private init() {}
    
    func enableLogging(_ isEnabled: Bool) {
        isLoggingEnabled = isEnabled
    }
    
    func log<T>(_ message: T, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        guard isLoggingEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(level.rawValue)] \(fileName):\(line) \(function) - \(message)"
        
        print(logMessage)
//        writeToFile(logMessage)
    }
    
    private func writeToFile(_ message: String) {
        guard let logFileURL = logFileURL else { return }
        let formattedMessage = "\(Date()) - \(message)\n"
        
        if let data = formattedMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: logFileURL, options: .atomic)
            }
        }
    }
    
    func clearLogs() {
        guard let logFileURL = logFileURL else { return }
        try? FileManager.default.removeItem(at: logFileURL)
    }
}

