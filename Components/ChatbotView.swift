//
//  ChatbotView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 12/01/2023.
//

import SwiftUI

struct ChatbotView: View {
    var body: some View {
        VStack {
            HStack {
                Image("chatbot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40.0, height: 40.0)
                Text("Clínica Virtual")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        
            Divider()
            Spacer()
            
        }
        .padding(.margin)
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView()
    }
}
