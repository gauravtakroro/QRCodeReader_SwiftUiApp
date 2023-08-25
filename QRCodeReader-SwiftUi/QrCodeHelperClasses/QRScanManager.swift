//
//  QRScanManager.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 25/08/23.
//

import Foundation
import AVFoundation

class QRScanManager: ObservableObject {

    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }

    @Published var error: CameraError?

    var captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.qrscanner.Session")

    private let videoOutput = AVCaptureVideoDataOutput()
    private let metaDataOutput = AVCaptureMetadataOutput()
    var status = Status.unconfigured

    init() {
        configure()
    }

    private func configure() {

        checkPermissions()
        sessionQueue.async {
            self.configureCaptureSession()
            self.captureSession.startRunning()
        }
    }

    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }

    private func checkPermissions() {

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in

                if !authorized {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                }
                self.sessionQueue.resume()
            }

        case .restricted:
            status = .unauthorized
            set(error: .restrictedAuthorization)

        case .denied:
            status = .unauthorized
            set(error: .deniedAuthorization)

        case .authorized:
            break

        @unknown default:
            status = .unauthorized
            set(error: .unknownAuthorization)
        }
    }

    private func configureCaptureSession() {
        guard status == .unconfigured else {
            return
        }
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Video device not available")
            set(error: .cameraUnavailable)
            status = .failed
            return
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            } else {
                set(error: .cannotAddInput)
                status = .failed
                return
            }
        } catch {
            set(error: .createCaptureInput(error))
            status = .failed
            return
        }

        if self.captureSession.canAddOutput(metaDataOutput) {
            self.captureSession.addOutput(metaDataOutput)
            metaDataOutput.metadataObjectTypes = [.qr]
        } else {
            set(error: .cannotAddOutput)
            status = .failed
            return
        }

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
        } else {
            set(error: .cannotAddOutput)
            status = .failed
            return
        }

        status = .configured
    }

    func set(
        _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }

    func setMetaDataDelegate(
        _ delegate: AVCaptureMetadataOutputObjectsDelegate,
        queue: DispatchQueue
    ) {
        sessionQueue.async {
            self.metaDataOutput.setMetadataObjectsDelegate(delegate, queue: queue)
        }
    }
}

enum CameraError {

    case deniedAuthorization
    case cannotAddOutput
    case createCaptureInput(Error)
    case cannotAddInput
    case cameraUnavailable
    case restrictedAuthorization
    case unknownAuthorization
}

