//
//  DocumentServiceMock.swift
//  Example Swift
//
//  Created by Enrique del Pozo Gómez on 6/5/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import Gini
@testable import GiniCapture
@testable import Example_Swift

final class DocumentServiceMock: ComponentAPIDocumentServiceProtocol {

    var giniSDK: GiniSDK
    var document: Document?
    var analysisCancellationToken: CancellationToken?
    
    init(sdk: GiniSDK, documentMetadata: Document.Metadata?) {
        self.giniSDK = sdk
    }
    
    func cancelAnalysis() {
        
    }
    
    func remove(document: GiniCaptureDocument) {
        
    }
    
    func resetToInitialState() {
        
    }
    
    func sendFeedback(with updatedExtractions: [Extraction]) {
        
    }
    
    func startAnalysis(completion: @escaping ComponentAPIAnalysisCompletion) {
        
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument]) {
        
    }
    
    func upload(document: GiniCaptureDocument, completion: ComponentAPIUploadDocumentCompletion?) {
        
    }
    
    func update(imageDocument: GiniImageDocument) {
        
    }

}

extension DocumentServiceMock {
    convenience init() {
        self.init(sdk: GiniSDK.Builder(client: Client(id: "id", secret: "secret", domain: "domain")).build(),
                  documentMetadata: nil)
    }
}
