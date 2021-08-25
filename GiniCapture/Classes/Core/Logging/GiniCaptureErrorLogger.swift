//
//  GiniCaptureErrorLogger.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 24.08.21.
//

import Foundation

public class GiniCaptureErrorLogger: GiniCaptureErrorLoggerDelegate {
    var isGiniLoggingOn = true
    var customErrorLogger: GiniCaptureErrorLoggerDelegate? = nil
    var giniErrorLogger: GiniCaptureErrorLoggerDelegate? = nil
    public func postGiniErrorLog(error: ErrorLog) {
        if isGiniLoggingOn {
            giniErrorLogger?.postGiniErrorLog(error: error)
        }
        if let customErrorLogger = customErrorLogger {
            customErrorLogger.postGiniErrorLog(error: error)
        }
    }
}
