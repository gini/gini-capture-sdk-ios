//
//  ErrorLog+GiniPayApiLib.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 24.08.21.
//

import Foundation
extension ErrorLog {
    func apiLibVerion() -> String {
      return Bundle(identifier: "org.cocoapods.GiniPayApiLib")?.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

