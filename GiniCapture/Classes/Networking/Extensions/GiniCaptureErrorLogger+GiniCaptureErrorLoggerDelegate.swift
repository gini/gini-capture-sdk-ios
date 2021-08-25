//
//  GiniCaptureErrorLogger+GiniCaptureErrorLoggerDelegate.swift
//  GiniCapture
//
//  Created by Alpár Szotyori on 27.07.21.
//

import Foundation

class GiniErrorLogger: GiniCaptureErrorLoggerDelegate {
    public func handleErrorLog(error: ErrorLog) {
       print("GiniScreenAPICoordinator : Error logged to Gini: \(error) with api lib version \(error.apiLibVerion())")
    }
}
