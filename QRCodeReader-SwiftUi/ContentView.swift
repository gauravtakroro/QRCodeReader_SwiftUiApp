//
//  ContentView.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 24/08/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("qr_code").resizable().frame(width:100, height: 100)
            Text("QR Reader Demo").font(.system(size: 24)).foregroundColor(Color.black)
            Text("please tap bottom button for NFC card/tag scanning").padding(.top, 8).font(.system(size: 14)).foregroundColor(Color.black)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
