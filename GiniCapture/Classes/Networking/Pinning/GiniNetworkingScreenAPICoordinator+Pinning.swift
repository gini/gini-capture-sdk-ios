//
//  GiniNetworkingScreenAPICoordinator+Pinning.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 07.10.20.
//

import Foundation
import Gini

extension GiniNetworkingScreenAPICoordinator {
    convenience init(client: Client,
                     resultsDelegate: GiniCaptureResultsDelegate,
                     giniConfiguration: GiniConfiguration,
                     publicKeyPinningConfig: [String: Any],
                     documentMetadata: Document.Metadata?,
                     api: APIDomain,
                     trackingDelegate: GiniCaptureTrackingDelegate?) {
        
        let sdk = GiniSDK
            .Builder(client: client,
                     api: api,
                     pinningConfig: publicKeyPinningConfig)
            .build()

        self.init(client: client,
                  resultsDelegate: resultsDelegate,
                  giniConfiguration: giniConfiguration,
                  documentMetadata: documentMetadata,
                  api: api,
                  trackingDelegate: trackingDelegate,
                  sdk: sdk)
    }
}
