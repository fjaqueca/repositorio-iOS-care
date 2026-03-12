//
//  TextView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/05/2023.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.textAlignment = .justified
        textView.font = UIFont(name: "FiraSans-Regular", size: 16)
        textView.textColor = .darkGray
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
