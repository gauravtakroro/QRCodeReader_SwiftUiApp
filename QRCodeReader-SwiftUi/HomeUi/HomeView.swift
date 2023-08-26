//
//  HomeView.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 24/08/23.
//

import SwiftUI

struct HomeView: View {
    
    @State var showQRCodeScanView: Bool = false
    @State var scannedQrCodeValue: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: QRCodeScanView(viewModel: QRCodeScanViewModel()), isActive: $showQRCodeScanView
                ) {
                    // QRCodeScanView(viewModel: QRCodeScannerViewModel())
                    EmptyView()
                }.isDetailLink(false)
                Spacer()
                Group {
                    Image("qr_code").resizable().frame(width:100, height: 100)
                    Text("QR Reader Demo").font(.system(size: 24)).foregroundColor(Color.black)
                    Text("please tap bottom button for NFC card/tag scanning").padding(.top, 8).font(.system(size: 14)).foregroundColor(Color.black)
                    if scannedQrCodeValue.isEmpty {
                        Text("No QR Code is scanned yet.").font(.system(size: 20)).foregroundColor(Color.gray.opacity(0.8))
                            .padding(.top, 24)
                    } else {
                        VStack {
                            Text("Most Recent Scanned QR Code Value").foregroundColor(Color.black).padding(.top, 24)
                            if UtilMethods.verifyUrl(urlString: scannedQrCodeValue) {
                                Button {
                                    UtilMethods.launchLinkWithSafari(urlString: scannedQrCodeValue)
                                } label: {
                                    Text(scannedQrCodeValue).foregroundColor(Color.blue).underline().multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true).font(.system(size: 16))
                                }
                            } else {
                                Button {
                                    UIPasteboard.general.string = scannedQrCodeValue
                                    
                                } label: {
                                    Text(scannedQrCodeValue).foregroundColor(Color.black).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true).font(.system(size: 16))
                                }
                            }
                        }.frame(alignment: .center)
                    }
                    Spacer()
                    Button {
                        // launch Camera for QR Code Scanning
                        showQRCodeScanView = true
                    } label: {
                        ZStack {
                            Color("BlueColor")
                            HStack {
                                Image("qr_code")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Tap here for QR Code Scan").font(.system(size: 14)).foregroundColor(Color.white)
                            }
                        }.cornerRadius(16).padding(.horizontal, 36)
                            .frame(height: 55)
                    }.padding(.bottom, 16).frame(alignment: .bottom)
                }.padding()
            }.onReceive(NotificationCenter.default.publisher(for: .showQRCodeValue)) { data in
                guard let userInfo = data.userInfo, let qrCodeValue = userInfo[NotificationData.qrCodeValue] else {
                    return
                }
                scannedQrCodeValue = qrCodeValue as! String
            }
        }
    }
}


