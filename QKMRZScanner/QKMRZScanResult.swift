//
//  QKMRZScanResult.swift
//  QKMRZScanner
//
//  Created by Matej Dorcak on 16/10/2018.
//

import Foundation
import QKMRZParser

public class QKMRZScanResult: NSObject {
    @objc public let documentImage: UIImage
    @objc public let documentType: String
    @objc public let countryCode: String
    @objc public let surnames: String
    @objc public let givenNames: String
    @objc public let documentNumber: String
    @objc public let nationality: String
    @objc public let birthDate: Date?
    @objc public let sex: String?
    @objc public let expiryDate: Date?
    @objc public let personalNumber: String
    @objc public let personalNumber2: String?
    
    public lazy fileprivate(set) var faceImage: UIImage? = {
        guard let documentImage = CIImage(image: documentImage) else {
            return nil
        }
        
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: CIContext.shared, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])!
        
        guard let face = faceDetector.features(in: documentImage).first else {
            return nil
        }
        
        let increasedFaceBounds = face.bounds.insetBy(dx: -30, dy: -85).offsetBy(dx: 0, dy: 50)
        let faceImage = documentImage.cropped(to: increasedFaceBounds)
        
        guard let cgImage = CIContext.shared.createCGImage(faceImage, from: faceImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }()
    
    init(mrzResult: QKMRZResult, documentImage image: UIImage) {
        documentImage = image
        documentType = mrzResult.documentType
        countryCode = mrzResult.countryCode
        surnames = mrzResult.surnames
        givenNames = mrzResult.givenNames
        documentNumber = mrzResult.documentNumber
        nationality = mrzResult.nationality
        birthDate = mrzResult.birthDate
        sex = mrzResult.sex
        expiryDate = mrzResult.expiryDate
        personalNumber = mrzResult.personalNumber
        personalNumber2 = mrzResult.personalNumber2
    }
}
