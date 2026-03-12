//
//  CustomTextEditor.swift
//  CareAssistance
//
//  Created by The App Master on 07/08/2025.
//

import Foundation

import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var isDisabled: Bool
    var font: UIFont
    var textColor: UIColor
    var textCase: Text.Case?

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator

        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocorrectionType = .yes
        textView.autocapitalizationType = .allCharacters

        textView.font = font
        textView.textColor = textColor
        textView.isScrollEnabled = true
        textView.isEditable = !isDisabled

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = textCase == .uppercase ? text.uppercased() : text
        }

        uiView.isEditable = !isDisabled
        uiView.font = font
        uiView.textColor = textColor
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

