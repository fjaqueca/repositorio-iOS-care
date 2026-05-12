//
//  String+Extensions.swift
//  CareAssistance
//
//  Created by Lara Dubs on 03/08/2022.
//

import Foundation

extension String {
    subscript(idx: Int) -> String {
        guard idx >= 0 && idx < count else { return "" }
        return String(self[index(startIndex, offsetBy: idx)])
    }
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
    func getCleanedURL() -> URL? {
        guard self.isEmpty == false else {
            return nil
        }
        if let url = URL(string: self) {
            return url
        } else {
            if let urlEscapedString = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) , let escapedURL = URL(string: urlEscapedString){
                return escapedURL
            }
        }
        return nil
     }
    func htmlToString() -> String {
        guard let data = self.data(using: .utf16),
              let attributed = try? NSAttributedString(data: data,
                                                       options: [.documentType: NSAttributedString.DocumentType.html],
                                                       documentAttributes: nil) else {
            return self
        }
        return attributed.string
    }
}
