//
//  asdasd.swift
//  CareAssistance
//
//  Created by The App Master on 20/09/2023.
//

import SwiftUI

struct asdasd: View {
    @State var objet: [pruebaSort] = [
        pruebaSort(Id: 2, IsDeleted: true, Name: "2"),
        pruebaSort(Id: 1, IsDeleted: true, Name: "1"),
        pruebaSort(Id: 2, IsDeleted: true, Name: "1"),
        pruebaSort(Id: 3, IsDeleted: true, Name: "2"),
    ]

       var body: some View {
           ScrollView {
               let uniqueIds = Set(objet.compactMap { $0.Id })
               ForEach(Array(uniqueIds).sorted(), id: \.self) { uniqueId in
                   VStack {
                       ForEach(objet.filter { $0.Id == uniqueId }, id: \.self) { sec in
                           Text(sec.Id?.description ?? "")
                       }
                   }
                   .padding(.margin)
                   .overlay(
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .stroke(Color.grayLight, lineWidth: 1)
                        .shadow(color: .shadowLight, radius: 1, x: 1, y: 1)
                   )
                   .cornerRadius(.cornerRadius)
               }
           }
       }
   }

struct asdasd_Previews: PreviewProvider {
    static var previews: some View {
        asdasd()
    }
}

struct pruebaSort: Codable, Hashable{
    let Id: Int?
    let IsDeleted: Bool?
    let Name: String?
}
