//
//  ErrorEvent+ErrorLog.swift
//  GiniCapture
//
//  Created by Alpár Szotyori on 18.09.21.
//

import Foundation
import GiniPayApiLib

extension ErrorEvent {
    
    static func from(_ errorLog: ErrorLog) -> ErrorEvent {
        return ErrorEvent(deviceModel: errorLog.deviceModel,
                          osName: errorLog.osName,
                          osVersion: errorLog.osVersion,
                          captureSdkVersion: errorLog.captureVersion,
                          apiLibVersion: errorLog.apiLibVersion,
                          description: errorLog.description,
                          documentId: nil,
                          originalRequestId: nil)
    }
}
