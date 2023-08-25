//
//  FlashLightScanImageView.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 25/08/23.
//

import SwiftUI
import AVFoundation

struct FlashLightScanImageView: View {

    @Binding var torchOn: Bool

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 30, style: .circular)
                .frame(width: 120, height: 60, alignment: .center)
                .foregroundColor(Color.black)
                .opacity(0.6)

            Button {
                print("flashlight button tapped")
                torchOn.toggle()
                UtilMethods.toggleTorch(torchOn: torchOn)
            } label: {
                FlashLightView()
            }
            .padding()
        }
    }
}

struct FlashLightScanImageView_Previews: PreviewProvider {
    static var previews: some View {
        FlashLightScanImageView(torchOn: .constant(false))
    }
}

struct FlashLightView: View {

    var body: some View {

        VStack {
            Image(systemName: "bolt")
            .renderingMode(.template)
            .foregroundColor(Color.white)
            Text("Flash Light")
                .font(.system(size: 12))
                .foregroundColor(Color.white)
        }
    }
}

struct ScanImageView: View {

    var body: some View {

        VStack {
            Image(systemName: "photo")
            Text("Scan Image")
                .font(.footnote)
                .foregroundColor(.white)
        }
    }
}

