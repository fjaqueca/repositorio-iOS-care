//
//  PrescriptionDetailsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/03/2023.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import SDWebImageSwiftUI

struct PrescriptionDetailsView: View {
    @Environment(\.dismiss) var dismiss
    let prescription: Prescriptions.Prescription
    @State var showAlert: Bool = false
    @State var showSheetView: Bool = false
    @State var alertAuthEvent: AlertAuthEvent?
    @State var isLoading: Bool = false
    @State private var showWebView = false
    @State private var urlToShare: URL?
    @Binding var UIState: PrescriptionUIState
    enum AlertAuthEvent: Identifiable{
        var id: Int{
            hashValue
        }
        case DownloadSucces
        case DownloadError
        case RepeatPrescription
        case RepeatFails
    }
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                ScrollView{
                    VStack(alignment: .leading) {
                        HStack{
                            Button{} label:{
                                Image("agenda-blue")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.presDetail.date.color))
                            }
                            Text(prescription.desdeC ?? "")
                                .font(Font.custom(UIState.presDetail.date.font, size: CGFloat(Int(UIState.presDetail.date.size) ?? 12)))
                                .foregroundColor(Color(hex: UIState.presDetail.date.color))
                        }
                        Text(prescription.Name ?? "Sin nombre")
                            .font(Font.custom(UIState.presDetail.title.font, size: CGFloat(Int(UIState.presDetail.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.presDetail.title.color))
                        // Badge indicador de tipo de documento
                        HStack(spacing: 6) {
                            Image(systemName: "pills.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                            Text("Receta médica")
                                .font(Font.custom("FiraSans-Medium", size: 11))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(hex: "#00B894")))
                        Text(prescription.especialidadDelResponsableC ?? "Sin especialidad")
                            .font(Font.custom(UIState.presDetail.specialty.font, size: CGFloat(Int(UIState.presDetail.specialty.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.presDetail.specialty.color))
                        Text(prescription.profesionalResponsableR?.Name ?? "Dr/Dra")
                            .font(Font.custom(UIState.presDetail.medic.font, size: CGFloat(Int(UIState.presDetail.medic.size) ?? 16)))
                            .foregroundColor(Color(hex: UIState.presDetail.medic.color))
                            .padding(.bottom)
                        
                        infoView
                            .padding(.leading, 1)
                        buttonsBottom
                            
                    }
                    
                    Spacer()
                }
                .alert(item: $alertAuthEvent, content: { tipe in
                    switch tipe{
                    case .DownloadSucces:
                        return Alert(title: Text("Descarga Completa"), message: Text("Archivo guardado en: Archivos > iPhone > \(UIState.presList.textToShare)"), dismissButton: .default(Text("OK")))
                    case .DownloadError:
                        return Alert(title: Text(""), message: Text("Error en la descarga"), dismissButton: .default(Text("OK")))
                    case .RepeatPrescription:
                        return Alert(title: Text(""), message: Text("Receta reenviada con exito"), dismissButton: .default(Text("OK")))
                    case .RepeatFails:
                        return Alert(title: Text(""), message: Text("No se pudo reenviar la receta"), dismissButton: .default(Text("OK")))
                    }
                    
                })
                .padding(.margin)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(UIState.presList.title.text)
                            .font(Font.custom(UIState.presList.title.font, size: CGFloat(Int(UIState.presList.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.presList.title.color))
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image("back")
                                .renderingMode(.template)
                                .tint(Color(hex: UIState.presList.title.color))
                        }
                    }
                }
                
            }
            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.presList.textToShare).\n", self.urlToShare as Any])
            })
            .blur(radius: isLoading ? 3 : 0.000001)
            if isLoading{
                ProgressView()
                    .padding()
            }
                
        }
        .background(
            Group{
                if UIState.presList.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: UIState.presDetail.imageBackground ),
                        content: { image in
                            image
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .aspectRatio(contentMode: .fill)
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                    .eraseToAnyView()
                }
            }
        )
        .navigationLink(isActive: $showWebView) {
            WebView(url: self.urlToShare ?? URL(string: "about:blank")!)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(UIState.presList.title.text)
                            .font(Font.custom(UIState.presList.title.font, size: CGFloat(Int(UIState.presList.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.presList.title.color))
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showWebView = false
                        } label: {
                            Image("back")
                                .renderingMode(.template)
                                .tint(Color(hex: UIState.presList.title.color))
                        }
                    }
                }
        }

    }
    var infoView: some View{
        VStack(alignment: .leading){
            Text(UIState.presDetail.medicine)
                .font(Font.custom(UIState.presDetail.subtitleAtr.font, size: CGFloat(Int(UIState.presDetail.subtitleAtr.size) ?? 16)))
                .foregroundColor(Color(hex: UIState.presDetail.subtitleAtr.color))
            Text(prescription.medicamentoR?.Name ?? "Sin medicamento")
                .font(Font.custom(UIState.presDetail.textAtr.font, size: CGFloat(Int(UIState.presDetail.textAtr.size) ?? 14)))
                .foregroundColor(Color(hex: UIState.presDetail.textAtr.color))
            
            Text(UIState.presDetail.dose)
                .font(Font.custom(UIState.presDetail.subtitleAtr.font, size: CGFloat(Int(UIState.presDetail.subtitleAtr.size) ?? 16)))
                .foregroundColor(Color(hex: UIState.presDetail.subtitleAtr.color))
                .padding(.top)
            Text(prescription.dosisC ?? "Sin dosis")
                .font(Font.custom(UIState.presDetail.textAtr.font, size: CGFloat(Int(UIState.presDetail.textAtr.size) ?? 14)))
                .foregroundColor(Color(hex: UIState.presDetail.textAtr.color))
            
            Text(UIState.presDetail.indications)
                .font(Font.custom(UIState.presDetail.subtitleAtr.font, size: CGFloat(Int(UIState.presDetail.subtitleAtr.size) ?? 16)))
                .foregroundColor(Color(hex: UIState.presDetail.subtitleAtr.color))
                .padding(.top)
            Text(prescription.indicacionesC ?? "Sin indicaciones")
                .font(Font.custom(UIState.presDetail.textAtr.font, size: CGFloat(Int(UIState.presDetail.textAtr.size) ?? 14)))
                .foregroundColor(Color(hex: UIState.presDetail.textAtr.color))
//            SecondaryButton(title: "Ir a Etapa", backgroundColor: .primaryText) {
//                
//            }
            Text(UIState.presDetail.attachedPres)
                .font(Font.custom(UIState.presDetail.subtitleAtr.font, size: CGFloat(Int(UIState.presDetail.subtitleAtr.size) ?? 16)))
                .foregroundColor(Color(hex: UIState.presDetail.subtitleAtr.color))
                .padding(.top)
            
            Button {
                downloadArchive(action: .isOpen)
            } label: {
                
                VStack{
                    if let url = URL(string: UIState.presDetail.svgIconShowArchive){
                        WebImage(url: url) { image in
                                image.resizable() // Control layout like SwiftUI.AsyncImage, you must use this modifier or the view will use the image
                                .scaledToFit()
                                .frame(height: 42)
                                .padding(.margin)
                            } placeholder: {
                                Image("searchImage")
                                    .renderingMode(.template)
                                    .padding(.margin)
                                    .frame(maxWidth: .infinity)
                                    .background(UIState.presDetail.svgIconShowArchiveBackground != "" ? Color(hex: UIState.presDetail.svgIconShowArchiveBackground) : Color.grayLight)
                                    .cornerRadius(.cornerRadius)
                            }
                        
                    }else{
                        Image("searchImage")
                            .renderingMode(.template)
                            .padding(.margin)
                            .frame(maxWidth: .infinity)
                            .background(UIState.presDetail.svgIconShowArchiveBackground != "" ? Color(hex: UIState.presDetail.svgIconShowArchiveBackground) : Color.grayLight)
                            .cornerRadius(.cornerRadius)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(UIState.presDetail.svgIconShowArchiveBackground != "" ? Color(hex: UIState.presDetail.svgIconShowArchiveBackground) : Color.grayLight)
                .cornerRadius(.cornerRadius)
            }
            .padding(.bottom)
        }
    }
    var buttonsBottom: some View{
        HStack{
            Button {
                
                downloadArchive(action: .isDownload)
            } label: {
                HStack{
                    Text(UIState.presDetail.btnDownload.textBtn)
                        .font(Font.custom(UIState.presDetail.btnDownload.fontTextBtn, size: CGFloat(Int(UIState.presDetail.btnDownload.sizeTextBtn) ?? 16)))
                        .foregroundColor(Color(hex: UIState.presDetail.btnDownload.colorTextBtn))
                    Image("pdf")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.presDetail.btnDownload.colorTextBtn))
                }
            }
            .frame(width: 100)
            .padding(5)
            .padding(.vertical)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.presDetail.btnDownload.colorTextBtn), lineWidth: 1)
            )
            Button {
//                showSheetView.toggle()
                downloadArchive(action: .isShare)
            } label: {
                HStack{
                    Text(UIState.presDetail.btnShare.textBtn)
                        .font(Font.custom(UIState.presDetail.btnShare.fontTextBtn, size: CGFloat(Int(UIState.presDetail.btnShare.sizeTextBtn) ?? 16)))
                        .foregroundColor(Color(hex: UIState.presDetail.btnShare.colorTextBtn))
                    Image("share")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.presDetail.btnShare.colorTextBtn))
                }
            }
            .frame(width: 100)
            .padding(5)
            .padding(.vertical)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.presDetail.btnShare.colorTextBtn), lineWidth: 1)
            )
            Button {
                self.isLoading = true
                repeatPrescription()
            } label: {
                HStack{
                    Text(UIState.presDetail.btnRepeat.textBtn)
                        .font(Font.custom(UIState.presDetail.btnRepeat.fontTextBtn, size: CGFloat(Int(UIState.presDetail.btnRepeat.sizeTextBtn) ?? 16)))
                        .foregroundColor(Color(hex: UIState.presDetail.btnRepeat.colorTextBtn))
                    Image("replay")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.presDetail.btnRepeat.colorTextBtn))
                    
                }
            }
            .frame(width: 100)
            .padding(5)
            .padding(.vertical)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.presDetail.btnRepeat.colorTextBtn), lineWidth: 1)
            )
        }
        .padding(1)
    }
    func openArchive(){
        let myUrl = prescription.urlDeLaRecetaC ?? ""
        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
            self.showWebView.toggle()
        }
    }
    func downloadArchive(action: ActionButton) {
        self.isLoading = true
        let rawUrl = prescription.urlDeLaRecetaC ?? ""

        guard !rawUrl.isEmpty else {
            self.isLoading = false
            self.alertAuthEvent = .DownloadError
            return
        }

        let fileName = S3FileHelper.extractFileNameFromUrl(rawUrl)
        let objectKey = S3FileHelper.extractObjectKeyFromUrl(rawUrl)

        // Verificar caché local solo para "Ver PDF" (Descargar siempre re-descarga, igual que Android)
        if action == .isOpen, let cachedFileUrl = S3FileHelper.getCachedFileUrl(fileName: fileName) {
            self.isLoading = false
            handleLocalFile(cachedFileUrl, action: action)
            return
        }

        Task {
            let result = await Network.shared.getPresignedUrl(objectKey: objectKey, filename: fileName)
            switch result {
            case let .success(response):
                guard let presignedUrl = response.url, !response.error else {
                    self.isLoading = false
                    self.alertAuthEvent = .DownloadError
                    return
                }
                do {
                    let localFileUrl = try await S3FileHelper.downloadAndSave(from: presignedUrl, fileName: fileName)
                    self.isLoading = false
                    handleLocalFile(localFileUrl, action: action)
                } catch {
                    self.isLoading = false
                    self.alertAuthEvent = .DownloadError
                }
            case let .failure(error):
                print("❌ [PrescriptionDetail] Error getPresignedUrl: \(error.message)")
                self.isLoading = false
                self.alertAuthEvent = .DownloadError
            }
        }
    }

    func handleLocalFile(_ fileURL: URL, action: ActionButton) {
        switch action {
        case .isOpen:
            self.urlToShare = fileURL
            self.showWebView.toggle()
        case .isDownload:
            self.urlToShare = fileURL
            self.showWebView.toggle()
        case .isShare:
            self.urlToShare = fileURL
            self.showSheetView.toggle()
        }
    }

    func repeatPrescription() {
        Task {
            let result = await Network.shared.postReceta(accountId: prescription.pacienteC ?? "", prescriptionId: prescription.Id ?? "")
            self.isLoading = false
            switch result {
            case .success(_):
                self.showAlert.toggle()
                self.alertAuthEvent = .RepeatPrescription
            case .failure(_):
                self.showAlert.toggle()
                self.alertAuthEvent = .RepeatFails
            }
        }
    }

    enum ActionButton: Identifiable {
        var id: Int { hashValue }
        case isDownload
        case isShare
        case isOpen
    }
}


