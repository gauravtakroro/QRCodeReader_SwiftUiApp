//
//  Notification+Extension.swift
//  QRCodeReader-SwiftUi
//
//  Created by Gaurav Tak on 26/08/23.
//

import Foundation

enum NotificationData: String {
    case qrCodeValue
}

extension Notification.Name {
    static let showQRCodeValue = Notification.Name("showQRCodeValue")
}
