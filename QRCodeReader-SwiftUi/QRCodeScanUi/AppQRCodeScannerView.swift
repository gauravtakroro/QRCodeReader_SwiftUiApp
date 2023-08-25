//
//  AppQRCodeScannerView.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 25/08/23.
//

import SwiftUI
import AVFoundation

struct AppQRCodeScannerView: View {
    
    let timer = Timer.publish(every: 0.005, on: .main, in: .common).autoconnect()
    @State var isIncreasing = true
      
    @State var paddingTopOfLine: Double = 140.0
    var capturedImage: CGImage?
    private let frameWidth: CGFloat = UIScreen.main.bounds.width * 0.65
    private let scanBorderImageWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    private let topPaddingForScanView: CGFloat = 140
    private var borderPaddingFromTop: CGFloat {
        return topPaddingForScanView - (scanBorderImageWidth - frameWidth)/2
    }

    private var flashlightButtonTopSpace: CGFloat {
        return scanBorderImageWidth + borderPaddingFromTop + 60
    }
    @Binding var torchOn: Bool

    var body: some View {

        if let img = capturedImage {

            ZStack {
                // camera preview / captured image
                Image(img, scale: 1.0, orientation: .up, label: Text(""))
                    .resizable()
                    .clipped()
                    .ignoresSafeArea()

                ZStack(alignment: .top) {
                    // black Translucent layer
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.7)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        // QR code mask
                        .reverseMask {
                            VStack {
                                Image("qr_code_mask")
                                    .resizable()
                                    .frame(width: frameWidth, height: frameWidth, alignment: .center)
                                    .padding(.top, topPaddingForScanView)

                                Spacer()
                            }
                        }
                    Rectangle().frame(width: scanBorderImageWidth - 20, height: 2).foregroundColor(Color.gray)
                        .padding(.top, paddingTopOfLine)
                        .animation(.spring())
                        .onReceive(timer) { _ in
                            if isIncreasing {
                                paddingTopOfLine += 1.0
                            } else {
                                paddingTopOfLine -= 1.0
                            }
                            if paddingTopOfLine >= (scanBorderImageWidth + topPaddingForScanView - 20) {
                                isIncreasing = false
                            } else if paddingTopOfLine < 120.0 {
                                isIncreasing = true
                            }
                        }
                    VStack {
                        // QR Code blue background overlay
                        Image("qr_scan_overlay_1")
                            .resizable()
                            .frame(width: scanBorderImageWidth, height: scanBorderImageWidth, alignment: .center)
                            .clipped()
                            .padding(.top, borderPaddingFromTop).opacity(0.7)

                        Spacer()
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .center)
            .ignoresSafeArea()
            .overlay(FlashLightScanImageView(torchOn: $torchOn).padding(.top, flashlightButtonTopSpace),
                     alignment: .top)
        } else {
            Color.black
                .ignoresSafeArea()
        }
    }
}

struct AppQRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        AppQRCodeScannerView(torchOn: .constant(false))
    }
}

