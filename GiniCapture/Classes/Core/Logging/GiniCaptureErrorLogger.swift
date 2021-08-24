//
//  GiniCaptureErrorLogger.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 24.08.21.
//

import Foundation
public class GiniCaptureErrorLogger {
    var isGiniLoggingOn = true
    var customErrorLogger: GiniCaptureErrorLoggerDelegate? = nil
}
