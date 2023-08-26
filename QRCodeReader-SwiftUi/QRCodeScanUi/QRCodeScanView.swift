//
//  QRCodeScanView.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 25/08/23.
//

import SwiftUI
import AVFoundation

struct QRCodeScanView: View {
    private let rotationChangePublisher = NotificationCenter.default
           .publisher(for: UIDevice.orientationDidChangeNotification)
    @State private var isOrientationLocked = true
    
    @StateObject var viewModel: QRCodeScanViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {

        ZStack(alignment: .top) {
            
            AppQRCodeScannerView(capturedImage: viewModel.frame, torchOn: $viewModel.torchOn)
            
            VStack {
                Spacer()
                cameraPermissionAlert()
                Spacer()
            }

            ZStack(alignment: .top) {
                VStack {
                    Button(action: {
                        self.mode.wrappedValue.dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .renderingMode(.template).foregroundColor(Color.white)
                                .padding(.top, 10)
                            Spacer()
                        }
                        .padding()
                    })
                    Spacer()
                }
                Text("Scan QR Code")
                    .foregroundColor(Color.white)
                    .font(.system(size: 24))
                    .padding(.top, 20)
                if viewModel.showQRCodeValueBottomView {
                    Spacer()
                    VStack {
                        Text("Scanned QR Code Value").foregroundColor(Color.black).padding(.top, 20)
                        HStack {
                            Spacer()
                            if UtilMethods.verifyUrl(urlString: viewModel.qrCodeValue) {
                                Button {
                                    UtilMethods.launchLinkWithSafari(urlString: viewModel.qrCodeValue)
                                } label: {
                                    Text(viewModel.qrCodeValue).foregroundColor(Color.blue).underline().font(.system(size: 16))
                                }
                            } else {
                                Button {
                                    UIPasteboard.general.string = viewModel.qrCodeValue

                                } label: {
                                    Text(viewModel.qrCodeValue).foregroundColor(Color.black).font(.system(size: 16))
                                }
                            }
                            Spacer()
                            Button {
                                viewModel.showQRCodeValueBottomView = false
                            } label: {
                                Image("x_icon").resizable().frame(width: 16, height: 16)
                            }.frame(alignment: .trailing).padding(.trailing, 24)
                            
                        }.padding(.bottom, 20).padding(.horizontal, 12).frame(width: UIScreen.main.bounds.width)
                    }.background(Color.white).frame( maxHeight: .infinity, alignment: .bottom)
                }
            }
            .padding(.top, 30)
        }
        
        .onAppear(perform: {
            viewModel.startQRCodeScanSession()
        })
        .onDisappear(perform: {
            viewModel.stopQRCodeScanSession()
            viewModel.torchOn = false
            UtilMethods.toggleTorch(torchOn: false)
        })
        .onChange(of: viewModel.qrCodeValue, perform: { _ in
            viewModel.showQRCodeValueBottomView = true
            print("Scanned qrCodeValue------> \(viewModel.qrCodeValue)")
        })
        .onReceive(rotationChangePublisher) { _ in
            // This is called when there is a orientation change
            // You can set back the orientation to the one you like even
            // if the user has turned around their phone to use another
            // orientation.
            if isOrientationLocked {
                changeOrientation(to: .portrait)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private func cameraPermissionAlert() -> some View {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .denied:
            
            return AnyView(Button {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }

            } label: {
                Text("Turn On Camera Permission")
                    .lineLimit(2)
                    .padding()
            })
            
        default:
            return AnyView(EmptyView())
        }
    }
    
    func changeOrientation(to orientation: UIInterfaceOrientation) {
        // tell the app to change the orientation
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        print("Changing to", orientation.isPortrait ? "Portrait" : "Landscape")
    }
}

