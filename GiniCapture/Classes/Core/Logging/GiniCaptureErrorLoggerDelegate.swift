//
//  GiniCaptureErrorLoggerDelegate.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 20.07.21.
//

import Foundation

public protocol GiniCaptureErrorLoggerDelegate: AnyObject {
    func postGiniErrorLog(error: ErrorLog, apiLibVersion: String?)
}
