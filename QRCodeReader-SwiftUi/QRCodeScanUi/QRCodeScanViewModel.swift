//
//  QRCodeScanViewModel.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 25/08/23.
//

import Foundation
import AVFoundation
import VideoToolbox

protocol QRCodeScanViewModelProtocol: ObservableObject {
     
    var frame: CGImage? { get set }
    var qrScanFrameManager: QRScanFrameManager { get set }
    var torchOn: Bool { get set }
    var qrCodeValue: String { get set }
    var showQRCoddeValueBottomView: Bool { get set }
    func setupSubscriptions()
    func startQRCodeScanSession()
    func stopQRCodeScanSession()
}

class QRCodeScanViewModel: QRCodeScanViewModelProtocol {
    @Published var torchOn: Bool = false
    @Published var frame: CGImage?
    @Published var qrCodeValue: String = ""
    @Published var showQRCoddeValueBottomView: Bool = false
    internal var qrScanFrameManager = QRScanFrameManager()
    
    init() {
        setupSubscriptions()
    }

    func setupSubscriptions() {

        qrScanFrameManager.$currentFrame
            .receive(on: RunLoop.main)
            .compactMap { buffer in

                if buffer != nil {
                    var cgImage: CGImage?
                    VTCreateCGImageFromCVPixelBuffer(buffer!, options: nil, imageOut: &cgImage)
                    return cgImage
                } else {
                    return nil
                }
            }
            .assign(to: &$frame)

        qrScanFrameManager.qrScannedCode = ""

        qrScanFrameManager.$qrScannedCode
            .receive(on: RunLoop.main)
            .assign(to: &$qrCodeValue)
    }
    
    func stopQRCodeScanSession() {
        qrScanFrameManager.qrScanManager.captureSession.stopRunning()
    }
    
    func startQRCodeScanSession() {
        self.qrCodeValue = ""
        if qrScanFrameManager.qrScanManager.status == .configured {
            qrScanFrameManager.qrScanManager.captureSession.startRunning()
        }
    }
}

