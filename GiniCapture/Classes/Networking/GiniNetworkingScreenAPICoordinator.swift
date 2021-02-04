//
//  GiniNetworkingScreenAPICoordinator.swift
//  GiniCapture
//
//  Created by Alpár Szotyori on 25.06.19.
//

import Foundation
import Gini

/**
 The GiniCaptureResultsDelegate protocol defines methods that allow you to handle the analysis result.
 */
@objc public protocol GiniCaptureResultsDelegate: class {
    
    /**
     Called when the analysis finished with results
     
     - parameter result: Contains the analysis result
     - parameter sendFeedbackBlock: Block used to send feeback once the results have been corrected
     */
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult,
                                         sendFeedbackBlock: @escaping ([String: Extraction]) -> Void)
    
    /**
     Called when the analysis finished without results.
     
     - parameter showingNoResultsScreen: Indicated if the `ImageAnalysisNoResultsViewController` has been shown
     */
    func giniCaptureAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool)
    
    /**
     Called when the analysis was cancelled.
     */
    func giniCaptureDidCancelAnalysis()
}

final class GiniNetworkingScreenAPICoordinator: GiniScreenAPICoordinator {
    
    weak var resultsDelegate: GiniCaptureResultsDelegate?
    private let documentService: DocumentServiceProtocol
    
    init(client: Client,
         resultsDelegate: GiniCaptureResultsDelegate,
         giniConfiguration: GiniConfiguration,
         documentMetadata: Document.Metadata?,
         api: APIDomain,
         trackingDelegate: GiniCaptureTrackingDelegate?,
         sdk : GiniSDK) {

        self.documentService = GiniNetworkingScreenAPICoordinator.documentService(with: sdk,
                                                                                  documentMetadata: documentMetadata,
                                                                                  giniConfiguration: giniConfiguration,
                                                                                  for: api)
        
        super.init(withDelegate: nil,
                   giniConfiguration: giniConfiguration)
        
        self.visionDelegate = self
        self.resultsDelegate = resultsDelegate
        self.trackingDelegate = trackingDelegate
    }
    
    convenience init(client: Client,
                     resultsDelegate: GiniCaptureResultsDelegate,
                     giniConfiguration: GiniConfiguration,
                     documentMetadata: Document.Metadata?,
                     api: APIDomain,
                     userApi: UserDomain,
                     trackingDelegate: GiniCaptureTrackingDelegate?) {
        
        let sdk = GiniSDK
            .Builder(client: client, api: api, userApi: userApi)
            .build()

        self.init(client: client,
                  resultsDelegate: resultsDelegate,
                  giniConfiguration: giniConfiguration,
                  documentMetadata: documentMetadata,
                  api: api,
                  trackingDelegate: trackingDelegate,
                  sdk: sdk)
    }
    
    private static func documentService(with sdk: GiniSDK,
                                        documentMetadata: Document.Metadata?,
                                        giniConfiguration: GiniConfiguration,
                                        for api: APIDomain) -> DocumentServiceProtocol {
        switch api {
        case .default, .gym, .custom:
            return DocumentService(sdk: sdk, metadata: documentMetadata)
        case .accounting:
            if giniConfiguration.multipageEnabled {
                preconditionFailure("The accounting API does not support multipage")
            }
            return AccountingDocumentService(sdk: sdk, metadata: documentMetadata)
        }
    }
    
    func deliver(result: ExtractionResult, analysisDelegate: AnalysisDelegate) {
        let hasExtactions = result.extractions.count > 0
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if hasExtactions {
                let images = self.pages.compactMap { $0.document.previewImage }
                let extractions: [String: Extraction] = Dictionary(uniqueKeysWithValues: result.extractions.compactMap {
                    guard let name = $0.name else { return nil }
                    
                    return (name, $0)
                })
                
                let result = AnalysisResult(extractions: extractions, images: images, candidates: result.candidates)
                
                let documentService = self.documentService
                
                self.resultsDelegate?
                    .giniCaptureAnalysisDidFinishWith(result: result) { updatedExtractions in
                        
                        documentService.sendFeedback(with: updatedExtractions.map { $0.value })
                        documentService.resetToInitialState()
                }
            } else {
                self.resultsDelegate?
                    .giniCaptureAnalysisDidFinishWithoutResults(analysisDelegate.tryDisplayNoResultsScreen())
                self.documentService.resetToInitialState()
            }
        }
    }
}

// MARK: - Networking methods

extension GiniNetworkingScreenAPICoordinator {
    fileprivate func startAnalysis(networkDelegate: GiniCaptureNetworkDelegate) {
        self.documentService.startAnalysis { result in
            switch result {
            case .success(let extractions):
                self.deliver(result: extractions, analysisDelegate: networkDelegate)
            case .failure(let error):

                guard error != .requestCancelled else { return }
                
                networkDelegate.displayError(withMessage: .localized(resource: AnalysisStrings.analysisErrorMessage),
                                             andAction: {
                    self.startAnalysis(networkDelegate: networkDelegate)
                })
            }
        }
    }

    fileprivate func upload(document: GiniCaptureDocument,
                            didComplete: @escaping (GiniCaptureDocument) -> Void,
                            didFail: @escaping (GiniCaptureDocument, Error) -> Void) {
        documentService.upload(document: document) { result in
            switch result {
            case .success:
                didComplete(document)
            case .failure(let error):
                didFail(document, error)
            }
        }
    }

    fileprivate func uploadAndStartAnalysis(document: GiniCaptureDocument,
                                            networkDelegate: GiniCaptureNetworkDelegate,
                                            uploadDidFail: @escaping () -> Void) {
        self.upload(document: document, didComplete: { _ in
            self.startAnalysis(networkDelegate: networkDelegate)
        }, didFail: { _, error in
            let error = error as? GiniCaptureError ?? AnalysisError.documentCreation

            guard let analysisError = error as? AnalysisError, case analysisError = AnalysisError.cancelled else {
                networkDelegate.displayError(withMessage: error.message, andAction: {
                    uploadDidFail()
                })
                return
            }
        })
    }
}

// MARK: - GiniCaptureDelegate

extension GiniNetworkingScreenAPICoordinator: GiniCaptureDelegate {
    func didCancelCapturing() {
        resultsDelegate?.giniCaptureDidCancelAnalysis()
    }

    func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
        // The EPS QR codes are a special case, since they don0t have to be analyzed by the Gini API and therefore,
        // they are ready to be delivered after capturing them.
        if let qrCodeDocument = document as? GiniQRCodeDocument,
            let format = qrCodeDocument.qrCodeFormat,
            case .eps4mobile = format {
            let result = qrCodeDocument.extractedParameters.compactMap {
                Extraction(box: nil, candidates: nil,
                           entity: QRCodesExtractor.epsCodeUrlKey,
                           value: $0.value,
                           name: QRCodesExtractor.epsCodeUrlKey)
                }
            let extractionResult = ExtractionResult(extractions: result, candidates: [:])
            
            self.deliver(result: extractionResult, analysisDelegate: networkDelegate)
            return
        }

        // When an non reviewable document or an image in multipage mode is captured,
        // it has to be uploaded right away.
        if giniConfiguration.multipageEnabled || !document.isReviewable {
            if !document.isReviewable {
                self.uploadAndStartAnalysis(document: document, networkDelegate: networkDelegate, uploadDidFail: {
                    self.didCapture(document: document, networkDelegate: networkDelegate)
                })
            } else if giniConfiguration.multipageEnabled {
                // When multipage is enabled the document updload result should be communicated to the network delegate
                upload(document: document,
                       didComplete: networkDelegate.uploadDidComplete,
                       didFail: networkDelegate.uploadDidFail)
            }
        }
    }

    func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
        // It is necessary to check the order when using multipage before
        // creating the composite document
        if giniConfiguration.multipageEnabled {
            documentService.sortDocuments(withSameOrderAs: documents)
        }

        // And review the changes for each document recursively.
        for document in (documents.compactMap { $0 as? GiniImageDocument }) {
            documentService.update(imageDocument: document)
        }

        // In multipage mode the analysis can be triggered once the documents have been uploaded.
        // However, in single mode, the analysis can be triggered right after capturing the image.
        // That is why the document upload shuld be done here and start the analysis afterwards
        if giniConfiguration.multipageEnabled {
            self.startAnalysis(networkDelegate: networkDelegate)
        } else {
            self.uploadAndStartAnalysis(document: documents[0], networkDelegate: networkDelegate, uploadDidFail: {
                self.didReview(documents: documents, networkDelegate: networkDelegate)
            })
        }
    }

    func didCancelReview(for document: GiniCaptureDocument) {
        documentService.remove(document: document)
    }

    func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        if pages.type == .image {
            documentService.cancelAnalysis()
        } else {
            documentService.resetToInitialState()
        }
    }
}
