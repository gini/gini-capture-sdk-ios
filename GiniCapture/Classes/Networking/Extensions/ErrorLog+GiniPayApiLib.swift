//
//  ErrorLog+GiniPayApiLib.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 24.08.21.
//

import Foundation
import GiniPayApiLib

extension ErrorLog {
    
    var apiLibVersion: String {
        Bundle(for: GiniApiLib.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}

