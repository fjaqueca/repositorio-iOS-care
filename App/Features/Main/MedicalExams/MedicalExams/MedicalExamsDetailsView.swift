//
//  MedicalExamsDetailsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/03/2023.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import Combine
import SDWebImageSwiftUI

struct MedicalExamsDetailsView: View {
    @Environment(\.dismiss) var dismiss
    let exam: MedicalExams.Exam
    @State var showAlert: Bool = false
    @State var showSheetView: Bool = false
    @State var showCameraPicker1: Bool = false
    @State var showCameraPicker2: Bool = false
    @State var showCameraPicker3: Bool = false
    @State var showCameraPicker4: Bool = false
    @State var imgData1: String = ""
    @State var imgData2: String = ""
    @State var imgData3: String = ""
    @State var imgData4: String = ""
    @State var imgURL1: String = ""
    @State var imgURL2: String = ""
    @State var imgURL3: String = ""
    @State var imgURL4: String = ""
    @State var selectedURL: URL?
    @State var isExamPublish: Bool = false
    @State var alertAuthEvent: AlertAuthEvent?
    @State var isLoading: Bool = false
    @Binding var isLoadingExam: Bool
    @State var urlImg: [String] = []
    @Binding var isFavorite: Bool
    @State private var showWebView = false
    @Binding var UIState: ExamUIState
    @State private var urlToShare: URL?
    @State private var sendNewExam: Bool = false
    var publisher = PassthroughSubject<Void, Never>()
    enum AlertAuthEvent: Identifiable{
        var id: Int{
            hashValue
        }
        case DownloadSucces
        case DownloadError
        case SuccessPostExam
        case SendFileError
    }
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                ScrollView{
                VStack(alignment: .leading) {
                    
                        VStack(alignment: .leading) {
                            HStack{
                                Button{
                                    
                                } label: {
                                    Image("userdata")
                                        .renderingMode(.template)
                                        .tint(Color(hex:  UIState.examDetail.medic.color))
                                }
                                Text(exam.profesionalResponsableR?.Name ?? "Dr.")
                                    .font(Font.custom(UIState.examDetail.medic.font, size: CGFloat(Int(UIState.examDetail.medic.size) ?? 12)))
                                    .foregroundColor(Color(hex: UIState.examDetail.medic.color))
                            }
                            Text(exam.Name ?? "")
                                .font(Font.custom(UIState.examDetail.prescription.font, size: CGFloat(Int(UIState.examDetail.prescription.size) ?? 18)))
                                .foregroundColor(Color(hex: UIState.examDetail.prescription.color))
                            Text(exam.etapaR?.programR?.Name ?? "")
                                .font(Font.custom(UIState.examDetail.program.font, size: CGFloat(Int(UIState.examDetail.program.size) ?? 18)))
                                .foregroundColor(Color(hex: UIState.examDetail.program.color))
                        }
                    
                    infoView
                        .padding(.leading, 1)
                }
                .onAppear{
                    isExamPublished()
                }
                    Spacer()
                    
                }.alert(item: $alertAuthEvent, content: { tipe in
                    switch tipe{
                    case .DownloadSucces:
                        return Alert(title: Text("Descargar Completa"), message: Text("Archivo guardado en: Archivos > iPhone > \(UIState.examList.textToShare)"), dismissButton: .default(Text("OK")))
                    case .DownloadError:
                        return Alert(title: Text(""), message: Text("Error en la descarga"), dismissButton: .default(Text("OK")))
                    case .SuccessPostExam:
                        return Alert(title: Text(""), message: Text("Examenes subidos con éxito"), dismissButton: .default(Text("OK")))
                    case .SendFileError:
                        return Alert(title: Text(""), message: Text("La imagen excede el tamaño máximo"), dismissButton: .default(Text("OK")))
                    }
                    
                })
                .padding(.margin)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(UIState.examDetail.title.text)
                            .font(Font.custom(UIState.examDetail.title.font, size: CGFloat(Int(UIState.examDetail.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.examDetail.title.color))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            changeFavorite()
                        }) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .renderingMode(.template)
                                .tint(Color(hex: UIState.examDetail.title.color))
                        }

                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image("back")
                                .renderingMode(.template)
                                .tint(Color(hex: UIState.examDetail.title.color))
                        }
                    }
                }
                
            }
            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.examList.textToShare).\n", self.urlToShare as Any])
            })
            .sheet(isPresented: $showWebView) {
                WebView(url: self.urlToShare!)
            }
            .blur(radius: isLoading ? 3 : 0.000001)
            if isLoading{
                ProgressView()
                    .padding()
            }
        }
        .background(
            Group{
                if UIState.examDetail.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: UIState.examDetail.imageBackground ),
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
        
    }
    var infoView: some View{
        VStack(alignment: .leading){
            Text(UIState.examDetail.indicatorTitle.text)
                .font(Font.custom(UIState.examDetail.indicatorTitle.font, size: CGFloat(Int(UIState.examDetail.indicatorTitle.size) ?? 16)))
                .foregroundColor(Color(hex: UIState.examDetail.indicatorTitle.color))
            Text(exam.descripcionC ?? "Sin descripcion")
                .font(Font.custom(UIState.examDetail.indicatorDescription.font, size: CGFloat(Int(UIState.examDetail.indicatorDescription.size) ?? 16)))
                .foregroundColor(Color(hex: UIState.examDetail.indicatorDescription.color))
            Text("Examen adjunto")
                .font(Font.custom(UIState.examDetail.indicatorTitle.font, size: CGFloat(Int(UIState.examDetail.indicatorTitle.size) ?? 16)))
                .foregroundColor(Color(hex: UIState.examDetail.indicatorTitle.color))
                .padding(.top)
            
            Button {
                downloadArchive(action: .isOpen)
            } label: {
                
                VStack{
                    if let url = URL(string: UIState.examDetail.svgIconShowArchive){
                        WebImage(url: url) { image in
                                image.resizable() // Control layout like SwiftUI.AsyncImage, you must use this modifier or the view will use the image
                                .scaledToFit()
                                .frame(height: 42)
                                .padding(.margin)
                            } placeholder: {
                                Image("searchImage")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.examDetail.indicatorTitle.color))
                                    .padding(.margin)
                                    .frame(maxWidth: .infinity)
                                    .background(UIState.examDetail.svgIconShowArchiveBackground != "" ? Color(hex: UIState.examDetail.svgIconShowArchiveBackground) : Color.grayLight)
                                    .cornerRadius(.cornerRadius)
                            }
                        
                    }else{
                        Image("searchImage")
                            .renderingMode(.template)
                            .tint(Color(hex: UIState.examDetail.indicatorTitle.color))
                            .padding(.margin)
                            .frame(maxWidth: .infinity)
                            .background(UIState.examDetail.svgIconShowArchiveBackground != "" ? Color(hex: UIState.examDetail.svgIconShowArchiveBackground) : Color.grayLight)
                            .cornerRadius(.cornerRadius)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(UIState.examDetail.svgIconShowArchiveBackground != "" ? Color(hex: UIState.examDetail.svgIconShowArchiveBackground) : Color.grayLight)
                .cornerRadius(.cornerRadius)
            }
            .padding(.bottom)
            buttonsBottom
                .padding(.bottom)
            if isExamPublish{
                Button {
                    sendNewExam = true
                } label: {
                    /*Text(UIState.btnAddSeeExam.btnSeeExam.textBtn != "" ? UIState.btnAddSeeExam.btnSeeExam.textBtn : "+ Subir Examen4444")*/
                    Text("Subir Examen4444")
                        .foregroundColor(Color(hex: UIState.btnAddSeeExam.btnSeeExam.colorTextBtn))
                    .frame(maxWidth: .infinity)
                    .tint(.gray)
                    .frame(height: .buttonTitleHeight)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: UIState.btnAddSeeExam.btnSeeExam.colorButton))
                .font(Font.custom(UIState.btnAddSeeExam.btnSeeExam.fontTextBtn, size: CGFloat(Int(UIState.btnAddSeeExam.btnSeeExam.sizeTextBtn) ?? 18)))
            }else{
                Button {
                    sendNewExam = true
                } label: {
                    /*Text(UIState.btnAddSeeExam.btnAddExam.textBtn != "" ? UIState.btnAddSeeExam.btnAddExam.textBtn : "+ Subir Examen55555")*/
                    Text("Subir Examen5555")
                        .foregroundColor(Color(hex: UIState.btnAddSeeExam.btnAddExam.colorTextBtn))
                    .frame(maxWidth: .infinity)
                    .tint(.gray)
                    .frame(height: .buttonTitleHeight)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: UIState.btnAddSeeExam.btnAddExam.colorButton))
                .font(Font.custom(UIState.btnAddSeeExam.btnAddExam.fontTextBtn, size: CGFloat(Int(UIState.btnAddSeeExam.btnAddExam.sizeTextBtn) ?? 18)))
            }
            
            
        }
        .onReceive(publisher, perform: { _ in
                    DispatchQueue.main.async {
                        dismiss()
                    }
                })
        .navigationLink(isActive: $sendNewExam) {
            if isExamPublish {
                SendNewExamView(UIState: $UIState, examName: exam.Name ?? "", isPublished: true, exam: medicExamToPatientExam(), publisher: self.publisher)
            }else{
                SendNewExamView(UIState: $UIState, examName: exam.Name ?? "", fromOrderExam: true, exam: medicExamToPatientExam(), publisher: self.publisher)
            }
        }
    }
    var buttonsBottom: some View{
        HStack{
            Button {
                downloadArchive(action: .isDownload)
            } label: {
                HStack{
                    Text(UIState.examDetail.btnDownload.textBtn)
                        .font(Font.custom(UIState.examDetail.btnDownload.fontTextBtn, size: CGFloat(Int(UIState.examDetail.btnDownload.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.examDetail.btnDownload.colorTextBtn))
                    Image("pdf")
                        .renderingMode(.template)
                        .tint(Color(hex:  UIState.examDetail.btnDownload.colorTextBtn))
                }
            }
            .padding(5)
            .padding(.vertical)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.examDetail.btnDownload.colorTextBtn), lineWidth: 1)
                )
            Button {
//                showSheetView.toggle()
                downloadArchive(action: .isShare)
            } label: {
                HStack{
                    Text(UIState.examDetail.btnShare.textBtn)
                        .font(Font.custom(UIState.examDetail.btnShare.fontTextBtn, size: CGFloat(Int(UIState.examDetail.btnShare.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.examDetail.btnShare.colorTextBtn))
                    Image("share")
                        .renderingMode(.template)
                        .tint(Color(hex:  UIState.examDetail.btnDownload.colorTextBtn))
                }
            }
            .padding(5)
            .padding(.vertical)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.examDetail.btnShare.colorTextBtn), lineWidth: 1)
                )
        }
    }
  
    func downloadArchive(action : ActionButton, urlParameter: String? = nil){
        self.isLoading = true
        let fileName = UIState.examList.textToShare
        var filterUrl: String?
        if urlParameter == nil{
            filterUrl = exam.urlDeLaOrdenMedicaC
        }else{
            filterUrl = urlParameter
        }
        
        if let url = filterUrl {
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
            if let url = URL(string: urlString) {
                let pdfData = try? Data.init(contentsOf: url)
                let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                let pdfNameFromUrl = "\(exam.Name ?? "Sin nombre")-\(fileName).pdf"
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
    func isExamPublished(){
        self.imgURL1 = exam.url1C ?? ""
        self.imgURL2 = exam.url2C ?? ""
        self.imgURL3 = exam.url3C ?? ""
        self.imgURL4 = exam.url4C ?? ""
        if !imgURL1.isEmpty || !imgURL2.isEmpty || !imgURL3.isEmpty || !imgURL4.isEmpty{
            self.isExamPublish = true
        }
        
    }
    func changeFavorite(){
        let data = !isFavorite
        self.isLoading = true
        Task {
            let result = await Network.shared.postFavorite(registerId: exam.Id ?? "", objet: exam.attributes?.type ?? "", data: data)
            switch result {
                case .success:
                self.isFavorite = data
                self.isLoadingExam = true
                print("success")
                case let .failure(error):
                    AppStatusManager.error(error)
            }
            self.isLoading = false
        }
    }
    func openArchive(){
        let myUrl = exam.urlDeLaOrdenMedicaC ?? ""
        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
            self.showWebView.toggle()
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
    func medicExamToPatientExam() -> FunctionFilterExamResponse.PatientExams{
        return FunctionFilterExamResponse.PatientExams(attributes: nil, pacienteC: exam.pacienteC, Id: nil, nombreDelExamenC: exam.Name, urlExamen1C: exam.url1C, urlExamen2C: exam.url2C, urlExamen3C: exam.url3C, urlExamen4C: exam.url4C, comentariosC: exam.comment, CreatedDate: nil, idOrdenMedicaC: exam.Id)
    }
}
