//
//  AccountingDocumentService.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/14/19.
//

import Foundation
import GiniPayApiLib

public final class AccountingDocumentService: DocumentServiceProtocol {
    public var metadata: Document.Metadata?
    public var document: Document?
    public var analysisCancellationToken: CancellationToken?
    let documentService: GiniPayApiLib.AccountingDocumentService
    
    init(lib: GiniApiLib, metadata: Document.Metadata?) {
        self.metadata = metadata
        self.documentService = lib.documentService()
    }
    
    public func cancelAnalysis() {
        if let document = document {
            delete(document)
        }
        
        analysisCancellationToken?.cancel()
        resetToInitialState()
    }
    
    public func remove(document: GiniCaptureDocument) {
        // You can only remove the current document, since multipage is not supported
        if let document = self.document {
            delete(document)
        }
    }
    
    public func resetToInitialState() {
        analysisCancellationToken = nil
        document = nil
    }
    
    public func sendFeedback(with updatedExtractions: [Extraction]) {
        guard let document = document else { return }
        documentService.submitFeedback(for: document, with: updatedExtractions) { result in
            switch result {
            case .success:
                Log(message: "Feedback sent with \(updatedExtractions.count) extractions",
                    event: "🚀")
            case .failure(let error):
                Log(message: "Error sending feedback for document with id: \(document.id) error: \(error)",
                    event: .error)
            }
        }
    }
    
    public func startAnalysis(completion: @escaping AnalysisCompletion) {
        fetchExtractions(completion: completion)
    }
    
    public func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument]) {
        // No need to sort documents since there is only one
    }
    
    public func upload(document: GiniCaptureDocument, completion: UploadDocumentCompletion?) {
        let fileName = "Document-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document,
                       fileName: fileName) { result in
            switch result {
            case .success(let createdDocument):
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    public func update(imageDocument: GiniImageDocument) {
        // Nothing must be updated.
    }
    
}

// MARK: Fileprivate

fileprivate extension AccountingDocumentService {
    func createDocument(from document: GiniCaptureDocument,
                        fileName: String,
                        docType: Document.DocType? = nil,
                        completion: @escaping UploadDocumentCompletion) {
        Log(message: "Creating document...", event: "📝")
        
        documentService.createDocument(with: document.data,
                                       fileName: fileName,
                                       docType: docType,
                                       metadata: metadata) { result in
                                        switch result {
                                        case .success(let createdDocument):
                                            Log(message: "Created document with id: \(createdDocument.id) " +
                                                "for vision document \(document.id)", event: "📄")
                                            
                                            self.document = createdDocument
                                            completion(.success(createdDocument))
                                        case .failure(let error):
                                            Log(message: "Document creation failed", event: .error)
                                            completion(.failure(error))
                                        }
            
        }
    }
    
    func delete(_ document: Document) {
        documentService.delete(document) { result in
            switch result {
            case .success:
                self.document = nil

                Log(message: "Deleted document with id: \(document.id)", event: "🗑")
            case .failure:
                Log(message: "Error deleting document with id: \(document.id)", event: .error)
            }
            
        }
    }
    
    func fetchExtractions(completion: @escaping AnalysisCompletion) {
        guard let document = document else { return }
        Log(message: "Starting analysis for document with id \(document.id)", event: "🔎")
        
        if analysisCancellationToken == nil {
            analysisCancellationToken = CancellationToken()
        }
        
        documentService.extractions(for: document,
                                    cancellationToken: analysisCancellationToken!,
                                    completion: handleResults(completion: completion))
    }
}
