//
//  HTMLView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/12/2022.
//

import SwiftUI
import WebKit

struct HTMLView: UIViewRepresentable {
    let html: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}

