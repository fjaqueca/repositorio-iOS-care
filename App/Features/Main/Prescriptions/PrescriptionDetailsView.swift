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
                        return Alert(title: Text("Descargar Completa"), message: Text("Archivo guardado en: Archivos > iPhone > \(UIState.presList.textToShare)"), dismissButton: .default(Text("OK")))
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
        .sheet(isPresented: $showWebView) {
            WebView(url: self.urlToShare!)
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
    func downloadArchive(action : ActionButton){
        self.isLoading = true
        if let url = prescription.urlDeLaRecetaC {
            let pdfName = url.components(separatedBy: "/")
            Task{
                let result = await Network.shared.getPdf(pdfName: pdfName.last ?? "")
                self.isLoading = false
                switch result {
                    case let .success(listPres):
                        createPDF(with: listPres.data, fileName: pdfName.last ?? ".pdf", action: action)
                    case let .failure(error):
                        AppStatusManager.error(error)
                    
                }
            }
        }else{
            self.isLoading = false
            self.alertAuthEvent = .DownloadError
            self.showAlert.toggle()
            
        }
    }
    
    func savePdf(urlString:String, fileName:String) {
        DispatchQueue.global(qos: .background).async  {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "\(prescription.Name ?? "Sin nombre")-\(fileName).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            self.isLoading = false
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved! ")
                print(actualPath.path)
                self.showAlert.toggle()
                self.alertAuthEvent = .DownloadSucces
                //                openFile(at: actualPath)
                //file is downloaded in app data container, I can find file from x code > devices > MyApp > download Container >This container has the file
            } catch {
                print("PDF no guardado: \(error)")
                self.showAlert.toggle()
                self.alertAuthEvent = .DownloadError
            }
        }
    }
    func repeatPrescription(){
        Task{
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
    
    /// Creates a PDF file from a Base64 encoded string
    func createPDF(with base64Info: String, fileName: String, action: ActionButton) {
        DispatchQueue.global(qos: .background).async {
            // Decodificar la cadena Base64 a Data
            guard let base64Data = Data(base64Encoded: base64Info, options: .ignoreUnknownCharacters) else {
                print("Error: La cadena Base64 no es válida.")
                return
            }
            
            // Obtener la ruta de documentos
            let documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            
            // Usa un nombre de archivo seguro.
            let pdfFileName = fileName.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: " ", with: "_")
            let fileURL = documentsURL.appendingPathComponent(pdfFileName)
            
            do {
                // Intentar escribir los datos en la ruta especificada
                try base64Data.write(to: fileURL, options: .atomic)
                print("PDF creado exitosamente en: \(fileURL.path)")
                switch action {
                    case .isDownload:
                        self.alertAuthEvent = .DownloadSucces
                        self.showAlert.toggle()
                    case .isShare:
                        self.urlToShare = fileURL
                        self.showSheetView.toggle()
                    case .isOpen:
                        //createPDF(with: listPres.data, fileName: pdfName.last ?? ".pdf")
                        self.urlToShare = fileURL
                        self.showWebView.toggle()
                    }
                
            } catch let error {
                print("Failed to write the PDF data due to: \(error.localizedDescription)")
                self.alertAuthEvent = .DownloadError
                self.showAlert.toggle()
            }
        }
    }
    
    enum ActionButton: Identifiable{
        var id: Int{
            hashValue
        }
        case isDownload
        case isShare
        case isOpen
    }
}


