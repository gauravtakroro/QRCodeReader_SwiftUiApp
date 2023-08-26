//
//  QRScanFrameManager.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 25/08/23.
//

import Foundation
import AVFoundation

class QRScanFrameManager: NSObject, ObservableObject {
    @Published var currentFrame: CVPixelBuffer?
    @Published var qrScannedCode: String = ""
    
    var qrScanManager: QRScanManager

    let videoOutputQueue = DispatchQueue(
        label: "com.videoOutput.queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)

    override init() {
        qrScanManager = QRScanManager()
        super.init()
        qrScanManager.set(self, queue: videoOutputQueue)
        qrScanManager.setMetaDataDelegate(self, queue: videoOutputQueue)
    }
}

extension QRScanFrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        if let buffer = sampleBuffer.imageBuffer {
            DispatchQueue.main.async {
                self.currentFrame = buffer
            }
        }
    }
}

extension QRScanFrameManager: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        if let first = metadataObjects.first {

            guard let obj = first as? AVMetadataMachineReadableCodeObject else {
                return
            }

            guard let stringValue = obj.stringValue else {
                return
            }
            // we can add validations of stringValue here if needed
            foundCode(code: stringValue)
        } else {
            print("Not able to read the code")
        }
    }

    private func foundCode(code: String) {
        print(code)
        if qrScannedCode != code {
            qrScannedCode = code
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .showQRCodeValue, object: nil, userInfo: [NotificationData.qrCodeValue: self.qrScannedCode])
            }
        }
    }
}
