//
//  ShareSheet.swift
//  CareAssistance
//
//  Created by The App Master on 01/09/2023.
//

import Foundation
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Optional: You can customize the appearance or behavior of the UIActivityViewController here.
    }
}
