//
//  GiniCaptureErrorLogger.swift
//  GiniCapture
//
//  Created by Alpár Szotyori on 27.07.21.
//

import Foundation

class GiniCaptureErrorLogger: GiniCaptureErrorLoggerDelegate {
    var isGiniLoggingOn = true
    var customErrorLogger: GiniCaptureErrorLoggerDelegate? = nil
    func postGiniErrorLog(error: ErrorLog, apiLibVersion: String? = "") {
        if isGiniLoggingOn {
            print("GiniScreenAPICoordinator : Error logged to Gini: \(error)")
        }
        if let customErrorLogger = customErrorLogger {
            customErrorLogger.postGiniErrorLog(error: error, apiLibVersion: error.apiLibVerion())
        }
    }
}
