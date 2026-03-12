//
//  EducationalMaterialDetailsView.swift
//  CareAssistance
//
//  Created by The App Master on 09/02/2024.
//

import SwiftUI
import CachedAsyncImage
import SDWebImageSwiftUI

struct EducationalMaterialDetailsView: View {
    let material: EducationalMaterial.EducationalMaterialRecords
    @Environment(\.dismiss) var dismiss
    @Binding var isFavorite: Bool
    @Binding var isLoadingMaterial: Bool
    @State var isLoading: Bool = false
    @State private var showWebView = false
    @State private var showSheetShare = false
    @State var urlWebView: String = ""
    @State var alertAuthEvent: AlertAuthEvent?
    @State var showAlert: Bool = false
    @State var stringShare: String = ""
    @State var materialData: [MaterialData] = []
    @Binding var UIState: EducationalMaterialUIState
    enum AlertAuthEvent: Identifiable{
        var id: Int{
            hashValue
        }
        case DownloadSucces
        case DownloadError
    }
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                ScrollView{
                    VStack(alignment: .center, spacing: 20) {
                        HStack{
                            Text(material.Name ?? "")
                                .font(Font.custom(UIState.materialDetail.title.font, size: CGFloat(Int(UIState.materialDetail.title.size) ?? 18)))
                                .foregroundColor(Color(hex: UIState.materialDetail.title.color))
                                .multilineTextAlignment(UIState.materialDetail.title.alignment == "center" ? .center : .leading)
                            if UIState.materialDetail.title.alignment != "center" {
                                Spacer()
                            }
                        }
                        
                        Text(material.descripcionC ?? "")
                            .font(Font.custom(UIState.materialDetail.description.font, size: CGFloat(Int(UIState.materialDetail.description.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.materialDetail.description.color))
                            .multilineTextAlignment(UIState.materialDetail.description.alignment == "center" ? .center : .leading)
                        
                        webViewButtons
                        
                        buttonsBottom
                    }
                }
                .padding(.margin)
                .onAppear{
                    getMaterialData()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(UIState.materialList.title.text != "" ? UIState.materialList.title.text : "Material Educativo")
                        .font(Font.custom(UIState.materialList.title.font, size: CGFloat(Int(UIState.materialList.title.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.materialList.title.color))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        changeFavorite()
                    }) {
                       
                                
                            
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .foregroundColor( isFavorite ? Color(hex: UIState.materialList.btnFavorite.active) : Color(hex: UIState.materialList.btnFavorite.inActive))
                        
                    }

                }
            
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.template)
                            .tint(Color(hex: UIState.materialList.colorBackArrow))
                    }
                }
                
            }
            .alert(item: $alertAuthEvent, content: { tipe in
                switch tipe{
                case .DownloadSucces:
                    return Alert(title: Text("Descargar Completa"), message: Text("Archivo guardado en: Archivos > iPhone > App"), dismissButton: .default(Text("OK")))
                case .DownloadError:
                    return Alert(title: Text(""), message: Text("Error en la descarga"), dismissButton: .default(Text("OK")))
                }
                
            })
            .onChange(of: urlWebView){ newValue in
                if newValue != ""{
                    self.showWebView.toggle()
                }
            }
            .sheet(isPresented: $showSheetShare, content: {
               ShareSheet(activityItems: ["¡Hola! Este Material Educativo fue compartido desde la App, puedes acceder ingresando los siguientes enlaces:\n\(stringShare)"])
            })
            .sheet(isPresented: $showWebView) {
                SafariWebView(url: urlWebView)
                    .onAppear{
                        urlWebView = ""
                    }
            }
            .blur(radius: isLoading ? 3 : 0.000001)
            if isLoading{
                ProgressView()
                    .padding()
            }
        }
        .navigationBarBackButtonHidden()
    }
    var webViewButtons: some View{
        VStack(spacing: 20){
            
            ForEach($materialData, id: \.self) { material in
                VStack(alignment: UIState.materialDetail.atrItems.alignment == "center" ? .center : .leading){
                    HStack{
                        if material.name.wrappedValue != ""{
                            
                        
                        Text(material.name.wrappedValue)
                            .font(Font.custom(UIState.materialDetail.atrItems.font, size: CGFloat(Int(UIState.materialDetail.atrItems.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.materialDetail.atrItems.color))
                            .multilineTextAlignment(UIState.materialDetail.atrItems.alignment == "center" ? .center : .leading)
                        if UIState.materialDetail.btnDownload.show == "Si"{
                            Button {
                                
                            } label: {
                                HStack{
                                    Text(UIState.materialDetail.btnDownload.name)
                                        .font(Font.custom(UIState.materialDetail.artButtonAction.font, size: CGFloat(Int(UIState.materialDetail.artButtonAction.size) ?? 18)))
                                        .padding(.horizontal, 5)
                                        .padding(.horizontal)
                                }
                                .hidden()
                            }
                            .padding(.horizontal, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: .cornerRadius)
                                    .stroke(Color.primaryText, lineWidth: 1)
                            )
                            .hidden()
                            }
                        }
                    }
                    
                    HStack{
                        Button {
                            openArchive(urlMaterial: material.url.wrappedValue)
                        } label: {
                            VStack{
                                if let url = URL(string: material.icon.wrappedValue){
                                    WebImage(url: url) { image in
                                            image.resizable() // Control layout like SwiftUI.AsyncImage, you must use this modifier or the view will use the image
                                            .scaledToFit()
                                            .frame(height: 42)
                                            .padding(.margin)
                                        } placeholder: {
                                            Image("searchImage")
                                                .padding(.margin)
                                        }
                                    
                                }else{
                                    Image("searchImage")
                                        .padding(.margin)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: UIState.materialDetail.atrItems.colorFondoIcono))
                            .cornerRadius(.cornerRadius)
                        }
                        if UIState.materialDetail.btnDownload.show == "Si"{
                            Button {
                                downloadArchive(url: material.url.wrappedValue, name: material.name.wrappedValue)
                            } label: {
                                HStack(){
                                    Text(UIState.materialDetail.btnDownload.name)
                                        .font(Font.custom(UIState.materialDetail.artButtonAction.font, size: CGFloat(Int(UIState.materialDetail.artButtonAction.size) ?? 18)))
                                        .foregroundColor(Color(hex: UIState.materialDetail.artButtonAction.color))
                                        .multilineTextAlignment(UIState.materialDetail.artButtonAction.alignment == "center" ? .center : .leading)
                                        .padding(5)
                                        .padding(.horizontal)
                                }
                                
                            }
                            .padding(5)
                            .padding(.vertical)
                            .background{
                                Color(hex: UIState.materialDetail.artButtonAction.colorBackground)
                                    .cornerRadius(.cornerRadius)
                                    
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: .cornerRadius)
                                    .stroke(Color(hex: UIState.materialDetail.artButtonAction.colorBorder), lineWidth: 1)
                            )
                        }
                        
                    }
                }
                }
            
        }
        .padding(10)
    }
    
    var buttonsBottom: some View{
        HStack{
            Button {
                shareEducationalMaterial()
            } label: {
                HStack{
                    Text(UIState.materialDetail.btnShare.name)
                        .font(Font.custom(UIState.materialDetail.artButtonAction.font, size: CGFloat(Int(UIState.materialDetail.artButtonAction.size) ?? 18)))
                        .multilineTextAlignment(UIState.materialDetail.artButtonAction.alignment == "center" ? .center : .leading)
                        .foregroundColor(Color(hex: UIState.materialDetail.artButtonAction.color))
                        .padding(.horizontal, 5)
                        .padding(.horizontal)
                    Image("share")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.materialDetail.artButtonAction.colorFondoIcono))
                }
                .hidden(UIState.materialDetail.btnShare.show == "Si" ? false : true)
            }
            .padding(5)
            .padding(.vertical)
            .background{
                Color(hex: UIState.materialDetail.artButtonAction.colorBackground)
                    .cornerRadius(.cornerRadius)
                    
            }
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.materialDetail.artButtonAction.colorBorder), lineWidth: 1)
                )
            .hidden(UIState.materialDetail.btnShare.show == "Si" ? false : true)
            Spacer()
        }
        .padding(10)
    }
    func openArchive(urlMaterial: String){
        if let url = URL(string: "\(urlMaterial)"), !url.absoluteString.isEmpty {
            self.urlWebView = urlMaterial
        }
    }
    func shareEducationalMaterial(){
        self.stringShare = ""
        self.isLoading = true
        if let urls = material.url1C?.components(separatedBy: ";") {
            for url in urls {
                self.stringShare += "\(url)\n"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isLoading = false
                self.showSheetShare.toggle()
            }
        }
    }
    func changeFavorite(){
        let data = !isFavorite
        self.isLoading = true
        Task {
            let result = await Network.shared.postFavorite(registerId: material.Id ?? "", objet: material.attributes?.type ?? "", data: data)
            switch result {
                case .success:
                self.isFavorite = data
                self.isLoadingMaterial = true
                print("success")
                case let .failure(error):
                    AppStatusManager.error(error)
            }
            self.isLoading = false
        }
    }
    func downloadArchive(url: String, name: String){
        self.isLoading = true
        let fileName = "Material Educativo \(name)"
        savePdf(urlString: url, fileName: fileName)
    }
    func savePdf(urlString:String, fileName:String) {
        DispatchQueue.global(qos: .background).async  {
            if let url = URL(string: urlString) {
                let pdfData = try? Data.init(contentsOf: url)
                let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                let pdfNameFromUrl = "\(material.Name ?? "")-\(fileName).pdf"
                let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                self.isLoading = false
                do {
                    try pdfData?.write(to: actualPath, options: .atomic)
                    self.showAlert.toggle()
                    self.alertAuthEvent = .DownloadSucces
                } catch {
                    self.showAlert.toggle()
                    self.alertAuthEvent = .DownloadError
                }
            }else{
                self.isLoading = false
                self.alertAuthEvent = .DownloadError
                self.showAlert.toggle()
            }
        }
    }
    func getMaterialData(){
        if let urls = material.url1C?.components(separatedBy: ";") {
            for url in urls {
                self.materialData.append(MaterialData(url: url))
            }
        }
        if let names = material.nombresC?.components(separatedBy: ";") {
            if let icons = material.iconosC?.components(separatedBy: ";") {
                for index in names.indices {
                    materialData[index].name = names[index]
                    materialData[index].icon = icons[index]
                }
            }
        }
        print(self.materialData)
    }
    struct MaterialData: Hashable{
        var url: String = ""
        var name: String = ""
        var icon: String = ""
    }
}
