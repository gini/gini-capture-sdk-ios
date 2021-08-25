//
//  ErrorLog.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 20.07.21.
//

import Foundation
public struct ErrorLog {
    
    public var deviceModel: String = UIDevice.current.model
    public var osName: String = UIDevice.current.systemName
    public var osVersion: String = UIDevice.current.systemVersion
    public var captureVersion: String = GiniCapture.versionString
    public var description: String
    
    enum CodingKeys: String, CodingKey {
        case deviceModel, osName, osVersion, captureVersion, description
    }
}

// MARK: - Decodable

extension ErrorLog: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.deviceModel = try container.decode(String.self, forKey: .deviceModel)
        self.osName = try container.decode(String.self, forKey: .osName)
        self.osVersion = try container.decode(String.self, forKey: .osVersion)
        self.captureVersion = try container.decode(String.self, forKey: .captureVersion)
        self.description = try container.decode(String.self, forKey: .description)
    }
}
