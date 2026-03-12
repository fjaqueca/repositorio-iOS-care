//
//  TaskView.swift
//  CareAssistance
//
//  Created by The App Master on 24/11/2023.
//

import SwiftUI

struct TaskHomeView: View {
    var body: some View {
        ScrollView {
            Divider()
            Text("Aca van las tareas futuro endpoint")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Tareas")
                        .font(.appTabTitleBold)
                        .foregroundColor(.primaryText)
                }
            }
        }
    }
}

