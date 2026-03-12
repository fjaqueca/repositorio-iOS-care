//
//  LegalsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 22/12/2022.
//

import SwiftUI

struct LegalsView: View {
    let kind: Kind
    @State private var value: String?

    public init(_ kind: Kind) {
        self.kind = kind
    }

    var body: some View {
        VStack {
            if let value {
                HTMLView(html: value)
            } else {
                ProgressView()
            }
        }
        .task {
            getLegals()
        }
    }

    enum Kind: Int {
        case privacyPolicies = 0
        case termsAndConditions = 1
    }
}

extension LegalsView {
    func getLegals() {
        Task {
            var agreement = ""
            if let agreementId = AppStatusManager.selectedEnterprise?.empresaC {
                agreement = agreementId
            } else{
#if CareAssistance
    print("Using CareAssistance agreement")
    agreement = "a3yRN0000007kkTYAQ"
#elseif Wellbeing
    print("Using Wellbeing agreement")
    agreement = "a3yRN0000007S7dYAE"
#elseif BCI
    print("Using BCI agreement")
    agreement = "a3yRN000000YiWTYA0"
#elseif PharmaBenefits
    print("Using Pharma Benefits agreement")
    agreement = "a3yRN000000AxwTYAS"
#elseif VCContigo
    print("Using Pharma Benefits agreement")
    agreement = "a3yRN000000Ch7dYAC"
#elseif CareAssistanceMX
    print("Using CareAssistanceMX agreement")
    agreement = "a3yRN000000gzQTYAY"
#elseif Premedic
    print("Using Premedic agreement")
    agreement = "a3yRN0000018NJpYAM"
#elseif ContigoSalud
    print("Using Contigo+Salud agreement")
    agreement = "a3yRN0000017n8HYAQ"
#endif
            }
            let result = await Network.shared.getLegalInformation(agreement: agreement)
            switch result {
                case let .success(legals):
                if kind == .privacyPolicies {
                    value = legals.records?.first?.politicasDePrivacidadR?.contentC ?? ""
                }else {
                    value = legals.records?.first?.terminosYCondicionesR?.contentC ?? ""
                }
                case let .failure(error):
                    AppStatusManager.error(error)
            }
        }
    }
}
