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

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Divider()
                ScrollView {
                    VStack(spacing: 16) {
                        headerCard
                        materialsCard
                        buttonsBottom
                    }
                    .padding(.top, 20)
                    .padding(.bottom, .margin)
                }
                .onAppear {
                    getMaterialData()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(UIState.materialList.title.text != "" ? UIState.materialList.title.text : "Material Educativo")
                        .font(Font.custom(UIState.materialList.title.font.isEmpty ? "FiraSans-Bold" : UIState.materialList.title.font, size: CGFloat(Int(UIState.materialList.title.size) ?? 18)))
                        .bold()
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

            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Header Card (Título + Descripción)
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Título
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(material.Name ?? "")
                        .font(Font.custom(UIState.materialDetail.title.font, size: CGFloat(Int(UIState.materialDetail.title.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.materialDetail.title.color))
                        .multilineTextAlignment(UIState.materialDetail.title.alignment == "center" ? .center : .leading)
                    if UIState.materialDetail.title.alignment != "center" {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            // Descripción
            VStack(alignment: .leading, spacing: 6) {
                Text(material.descripcionC ?? "")
                    .font(Font.custom(UIState.materialDetail.description.font, size: CGFloat(Int(UIState.materialDetail.description.size) ?? 18)))
                    .foregroundColor(Color(hex: UIState.materialDetail.description.color))
                    .multilineTextAlignment(UIState.materialDetail.description.alignment == "center" ? .center : .leading)
                    .frame(maxWidth: .infinity, alignment: UIState.materialDetail.description.alignment == "center" ? .center : .leading)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, .margin)
    }

    // MARK: - Materials Card
    private var materialsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header de sección
            Text("Materiales")
                .font(Font.custom("FiraSans-Medium", size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            // Items de material
            ForEach(materialData.indices, id: \.self) { index in
                VStack(spacing: 0) {
                    materialItemRow(index: index)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    if index < materialData.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }

            Spacer()
                .frame(height: 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, .margin)
    }

    // MARK: - Material Item Row
    @ViewBuilder
    private func materialItemRow(index: Int) -> some View {
        let item = materialData[index]
        VStack(alignment: UIState.materialDetail.atrItems.alignment == "center" ? .center : .leading, spacing: 10) {
            // Nombre del item
            if !item.name.isEmpty {
                HStack {
                    Text(item.name)
                        .font(Font.custom(UIState.materialDetail.atrItems.font, size: CGFloat(Int(UIState.materialDetail.atrItems.size) ?? 18)))
                        .foregroundColor(Color(hex: UIState.materialDetail.atrItems.color))
                        .multilineTextAlignment(UIState.materialDetail.atrItems.alignment == "center" ? .center : .leading)
                    if UIState.materialDetail.atrItems.alignment != "center" {
                        Spacer()
                    }
                }
            }

            // Icono + Botón descargar
            HStack(spacing: 12) {
                // Botón de preview (abre SafariWebView)
                Button {
                    openArchive(urlMaterial: item.url)
                } label: {
                    VStack {
                        if let url = URL(string: item.icon) {
                            WebImage(url: url) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(height: 42)
                                    .padding(.margin)
                            } placeholder: {
                                Image("searchImage")
                                    .padding(.margin)
                            }
                        } else {
                            Image("searchImage")
                                .padding(.margin)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: UIState.materialDetail.atrItems.colorFondoIcono))
                    .cornerRadius(.cornerRadius)
                }

                // Botón descargar (condicional)
                if UIState.materialDetail.btnDownload.show == "Si" {
                    Button {
                        downloadArchive(url: item.url, name: item.name)
                    } label: {
                        HStack {
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
                    .background {
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

    // MARK: - Action Bar (Compartir)
    var buttonsBottom: some View {
        Group {
            if UIState.materialDetail.btnShare.show == "Si" {
                VStack(spacing: 0) {
                    Button {
                        shareEducationalMaterial()
                    } label: {
                        HStack(spacing: 6) {
                            Text(UIState.materialDetail.btnShare.name)
                                .font(Font.custom(UIState.materialDetail.artButtonAction.font, size: CGFloat(Int(UIState.materialDetail.artButtonAction.size) ?? 18)))
                                .multilineTextAlignment(UIState.materialDetail.artButtonAction.alignment == "center" ? .center : .leading)
                                .foregroundColor(Color(hex: UIState.materialDetail.artButtonAction.color))
                            Image("share")
                                .renderingMode(.template)
                                .tint(Color(hex: UIState.materialDetail.artButtonAction.colorFondoIcono))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background {
                        Color(hex: UIState.materialDetail.artButtonAction.colorBackground)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: UIState.materialDetail.artButtonAction.colorBorder), lineWidth: 1)
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal, .margin)
            }
        }
    }

    // MARK: - Functions (sin cambios)
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
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                do {
                    try pdfData?.write(to: actualPath, options: .atomic)
                    DispatchQueue.main.async {
                        self.showAlert.toggle()
                        self.alertAuthEvent = .DownloadSucces
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert.toggle()
                        self.alertAuthEvent = .DownloadError
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertAuthEvent = .DownloadError
                    self.showAlert.toggle()
                }
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
