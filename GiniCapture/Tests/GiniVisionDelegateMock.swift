//
//  GiniVisionDelegateMock.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 3/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniVision

final class GiniVisionDelegateMock: GiniCaptureDelegate {
    func didCapture(document: GiniCaptureDocument, networkDelegate: GiniVisionNetworkDelegate) {
        
    }
    
    func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniVisionNetworkDelegate) {
        
    }
    
    func didCancelCapturing() {
        
    }
    
    func didCancelReview(for document: GiniCaptureDocument) {
        
    }
    
    func didCancelAnalysis() {
        
    }
    
}
