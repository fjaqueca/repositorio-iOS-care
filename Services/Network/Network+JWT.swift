//
//  Network+JWT.swift
//  CareAssistance
//
//  Created by Lara Dubs on 27/09/2022.
//

import Foundation
import CryptoKit

extension Data {
    func urlSafeBase64EncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension Network {
    var tokenUnauthenticated: String {
        let secret = "secret"
        let privateKey = SymmetricKey(data: Data(secret.utf8))

        guard let headerJSONData = try? JSONEncoder().encode(Header()) else { return "" }
        let headerBase64String = headerJSONData.urlSafeBase64EncodedString()

        guard let payloadJSONData = try? JSONEncoder().encode(Payload()) else { return "" }
        let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()

        let toSign = Data((headerBase64String + "." + payloadBase64String).utf8)

        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
        let signatureBase64String = Data(signature).urlSafeBase64EncodedString()

        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
        return token
    }

    private struct Header: Encodable {
        let alg = "HS256"
        let typ = "JWT"
    }

    private struct Payload: Encodable {
        let authorization = "allow"
    }
}
