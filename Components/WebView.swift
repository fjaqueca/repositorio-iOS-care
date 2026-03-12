//
//  WebView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 15/12/2022.
//

import SwiftUI
import WebKit
import SafariServices

struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct SafariWebView: UIViewControllerRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: URL(string: url)!)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context){
        
    }
}
