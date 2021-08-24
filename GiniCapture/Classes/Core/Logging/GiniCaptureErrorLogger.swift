//
//  GiniCaptureErrorLogger.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 24.08.21.
//

import Foundation

public class GiniCaptureErrorLogger: GiniCaptureErrorLoggerDelegate  {
    var isGiniLoggingOn = true
    var customErrorLogger: GiniCaptureErrorLoggerDelegate? = nil
    public func postGiniErrorLog(error: ErrorLog, apiLibVersion: String?) {
        if isGiniLoggingOn {
            print("GiniScreenAPICoordinator : Error logged to Gini: \(error)")
        }
        if let customErrorLogger = customErrorLogger {
            customErrorLogger.postGiniErrorLog(error: error, apiLibVersion: "")
        }
    }
}
