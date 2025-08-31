//
//  DebugLog.swift
//  EverForm
//
//  Debug logging utility for development traces
//  Assumption: Simple console logging for now, can extend to file/remote later
//

import Foundation

struct DebugLog {
    static func d(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("🔍 [\(fileName):\(line)] \(function) - \(message)")
        #endif
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("ℹ️ [\(fileName):\(line)] \(function) - \(message)")
        #endif
    }
}
