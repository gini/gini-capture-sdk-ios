//
//  GiniQRCodeDocument.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

/**
 A Gini Vision document made from a QR code.
 
 The Gini Vision Library supports the following QR code formats:
 - Bezahlcode (http://www.bezahlcode.de).
 - Stuzza (AT) and GiroCode (DE) (https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation).
 - EPS E-Payment (https://eservice.stuzza.at/de/eps-ueberweisung-dokumentation/category/5-dokumentation.html).
 
 */
@objc final public class GiniQRCodeDocument: NSObject, GiniVisionDocument {
    public var type: GiniVisionDocumentType = .qrcode
    public lazy var data: Data = {
        return self.paymentInformation ?? Data(count: 0)
    }()
    public var id: String
    public lazy var previewImage: UIImage? = {
        return UIImage(qrData: self.data)
    }()
    public var isReviewable: Bool = false
    public var isImported: Bool = false
    
    fileprivate lazy var paymentInformation: Data? = {
        let jsonDict: [String: Any] = ["qrcode": self.scannedString, "paymentdata": self.extractedParameters]
        
        return try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
    }()
    fileprivate let scannedString: String
    lazy var extractedParameters: [String: String] = QRCodesExtractor
        .extractParameters(from: self.scannedString, withFormat: self.qrCodeFormat)
    fileprivate let epc06912LinesCount = 12
    lazy var qrCodeFormat: QRCodesFormat? = {
        if self.scannedString.starts(with: "bank://") {
            return .bezahl
        } else if self.scannedString.starts(with: "epspayment://") {
            return .eps4mobile
        } else if let lines = Optional(self.scannedString.splitlines),
            lines.count > 9 &&
            (lines[1] == "001" || lines[1] == "002") &&
            (lines[2] == "1" || lines[2] == "2") {
                return .epc06912
        } else {
            return nil
        }
    }()
    
    init(scannedString: String) {
        self.scannedString = scannedString
        self.id = UUID().uuidString
        super.init()
    }    
}

// MARK: Equatable

extension GiniQRCodeDocument {
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? GiniQRCodeDocument {
            return self.scannedString == object.scannedString
        }
        return false
    }
}
