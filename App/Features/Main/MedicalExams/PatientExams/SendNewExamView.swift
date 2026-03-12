//
//  SendNewExamView.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI
import CachedAsyncImage
import Combine

struct SendNewExamView: View {
    @Environment(\.dismiss) var dismiss
    @State var showAlert: Bool = false
    @State var showSheetView: Bool = false
    @State private var fileExams: [FileExam] = (0..<4).map { _ in FileExam() }
    @State var selectedURL: URL?
    @State var alertAuthEvent: AlertAuthEvent?
    @State var isLoading: Bool = false
    @State var urlImg: [String] = []
    @State private var showWebView = false
    @Binding var UIState: ExamUIState
    @State private var urlToShare: URL?
    @State var examName: String = ""
    @State var isPublished: Bool = false
    @State var fromOrderExam: Bool = false
    let exam: FunctionFilterExamResponse.PatientExams?
    var publisher = PassthroughSubject<Void, Never>()
    @State private var selectedFileExamId: UUID? = nil
    enum FileExamSourceType { case camera, document }
    @State private var selectedSourceType: FileExamSourceType? = nil
    @State private var showSourceDialog = false
    @State private var showFilePicker = false
    @State private var popup: Popup?

    
    enum AlertAuthEvent: Identifiable{
        var id: Int{
            hashValue
        }
        case DownloadSucces
        case DownloadError
        case SuccessPostExam
        case SendFileError
    }
    @State var comment: String = ""
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                ScrollView{
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading) {
                            
                            Text("Nombre del Examen *")
                                .font(Font.custom(UIState.examDetail.medic.font, size: CGFloat(Int(UIState.examDetail.medic.size) ?? 12)))
                                .foregroundColor(Color(hex: UIState.examDetail.medic.color))
                            HStack{
                                TextField("Ingrese el nombre del examen", text: $examName)
                                    .font(Font.custom(UIState.examDetail.title.font, size: CGFloat(Int(UIState.examDetail.title.size) ?? 12)))
                                    .foregroundColor(Color(hex: UIState.examDetail.title.color))
                                    .disabled(isPublished || fromOrderExam)
                                    .textCase(.uppercase)
                                    .autocapitalization(.allCharacters)
                                    .onChange(of: examName) { nuevoTexto in
                                        if nuevoTexto.count > 255 {
                                            examName = String(nuevoTexto.prefix(255))
                                        }
                                    }
                                Text("\(examName.count)/255")
                                    .font(Font.custom(UIState.examDetail.title.font, size: CGFloat(Int(UIState.examDetail.title.size) ?? 12)))
                                    .foregroundColor(Color(hex: UIState.examDetail.title.color))
                            }
                            .padding(.margin)
                            .background {
                                Color.grayLight
                            }
                            .cornerRadius(10)
                        }
                        .task{
                            self.isExamPublished()
                        }
                        
                        infoView
                            .padding(.leading, 1)
                    }
                    Spacer()
                    
                }
                .padding(.margin)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(UIState.examDetail.title.text)
                            .font(Font.custom(UIState.examDetail.title.font, size: CGFloat(Int(UIState.examDetail.title.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.examDetail.title.color))
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
                
                if !isPublished {
                    Button {
                        sendInfo()
                    } label: {
                        Text("Enviar")
                            .foregroundColor(Color(hex: UIState.examFilter.btn2ColorText))
                            .frame(maxWidth: .infinity)
                            .tint(.gray)
                            .frame(height: .buttonTitleHeight)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: UIState.examFilter.btn2ColorBack))
                    .font(.appBodyBold)
                    .disabled(isSendButtonDisabled)
                    .padding(.margin)
                }
                
            }
            .popup(item: $popup)
            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.examList.textToShare).\n", self.urlToShare as Any])
            })
            .sheet(isPresented: $showWebView) {
                if let url = urlToShare {
                    WebView(url: url)
                } else {
                    Text("No hay URL para mostrar")
                }
            }
            .sheet(isPresented: $showFilePicker) {
                if let id = selectedFileExamId,
                   let index = fileExams.firstIndex(where: { $0.id == id }),
                   let source = selectedSourceType {

                    switch source {
                    case .camera:
                        CameraPickerView(sourceType: .photoLibrary) { image in
                            if let data = image.jpegData(compressionQuality: 0.5) {
                                fileExams[index].imgData = data.base64EncodedString()
                                fileExams[index].archiveExtension = "jpg"
                            }
                            resetPickerState()
                        }

                    case .document:
                        DocumentPickerView { url in
                            do {
                                let data = try Data(contentsOf: url)
                                fileExams[index].imgData = data.base64EncodedString()
                                fileExams[index].archiveExtension = url.pathExtension
                            } catch {
                                print("Error al leer archivo: \(error.localizedDescription)")
                            }
                            resetPickerState()
                        }
                    }

                } else {
                    Text("No se pudo cargar el archivo.")
                }
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
            Text(isPublished ? UIState.examDetail.sendedExamText2 : UIState.examDetail.sendedExamText1 )
                .font(Font.custom(UIState.examDetail.sendedExam.font, size: CGFloat(Int(UIState.examDetail.sendedExam.size) ?? 18)))
                .foregroundColor(Color(hex: UIState.examDetail.sendedExam.color))
                .padding(.top)
            
            HStack {
                ForEach($fileExams) { $fileExam in
                    FileRowExam(
                        fileExam: $fileExam,
                        isExamPublish: $isPublished,
                        UIState: $UIState,
                        onSelect: { id in
                            selectedFileExamId = id
                            showSourceDialog = true
                        },
                        onDownload: {
                            downloadArchive(action: .isOpen, urlParameter: fileExam.urlImg)
                        }
                    )
                }
            }
            .confirmationDialog("Elegí el tipo de archivo", isPresented: $showSourceDialog) {
                Button("Galería") {
                    selectedSourceType = .camera
                    showFilePicker = true
                }
                Button("Seleccionar archivo") {
                    selectedSourceType = .document
                    showFilePicker = true
                }
            }
            
            Text("Para adjuntar sus exámenes oprima en los vinculos de arriba. Podrá adjuntar hasta 4 archivos.")
                .font(.appCaption)
                .foregroundColor(Color(hex: UIState.examDetail.sendedExam.color))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            commentRow
        }
    }
    var successPopup: Popup {
        .init(
            image: UIState.popupSuccessSendExam.iconCheck,
            title: UIState.popupSuccessSendExam.successInfo.text1,
            message: UIState.popupSuccessSendExam.successInfo.text2,
            actionTitle: UIState.popupSuccessSendExam.successInfo.btnOk,
            action: {
                dismiss()
                self.publisher.send()
            },
            isCancellable: false,
            cancelTitle: UIState.popupSuccessSendExam.successInfo.btnOk,
            UIStateTitle: UIState.popupSuccessSendExam.titleAtr,
            UIStateMessage: UIState.popupSuccessSendExam.textAtr,
            UIStateButton: UIState.popupSuccessSendExam.btnAtr,
            UIStateCancelButton: nil
        )
    }
    private func resetPickerState() {
        selectedFileExamId = nil
        selectedSourceType = nil
        showFilePicker = false
    }
    func downloadArchive(action : ActionButton, urlParameter: String? = nil){
        self.isLoading = true
        var filterUrl: String?
        if urlParameter == nil{
            //filterUrl = exam.urlDeLaOrdenMedicaC
        }else{
            filterUrl = urlParameter
        }
        
        if let url = filterUrl {
            let pdfName = url.components(separatedBy: "/")
            
            // 🔥 FIREBASE LOGGING: Inicio de descarga de PDF
            FirebaseLogger.shared.log("🔄 Descargando PDF: \(pdfName.last ?? "unknown")")
            
            Task{
                let result = await Network.shared.getPdf(pdfName: pdfName.last ?? "")
                self.isLoading = false
                switch result {
                case let .success(listPres):
                    // 🔥 FIREBASE LOGGING: Descarga exitosa
                    FirebaseLogger.shared.log("✅ PDF descargado exitosamente")
                    createPDF(with: listPres.data, fileName: pdfName.last ?? ".pdf", action: action)
                    
                case let .failure(error):
                    // 🔥 FIREBASE LOGGING: Error con contexto de red
                    FirebaseLogger.shared.log("❌ Error al descargar PDF: \(error.localizedDescription)")
                    FirebaseLogger.shared.recordNetworkError(
                        error,
                        endpoint: "/api/pdf/\(pdfName.last ?? "unknown")",
                        httpCode: (error as? AppError)?.httpCode,
                        method: "GET"
                    )
                    FirebaseLogger.shared.setCustomValues([
                        "pdf_name": pdfName.last ?? "unknown",
                        "error_context": "download_pdf"
                    ])
                    
                    AppStatusManager.error(error)
                }
            }
        }else{
            // 🔥 FIREBASE LOGGING: Error de URL vacía
            FirebaseLogger.shared.log("❌ Error: URL de PDF vacía")
            FirebaseLogger.shared.logAlert(
                title: "Error de Descarga",
                message: "No se encontró la URL del archivo",
                source: "SendNewExamView - downloadArchive"
            )
            
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
                let pdfNameFromUrl = "\(examName)-\(fileName).pdf"
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
    func sendInfo() {
        self.isLoading = true
        
        // 🔥 FIREBASE LOGGING: Inicio de subida de archivos
        let filesCount = fileExams.filter { !$0.imgData.isEmpty }.count
        FirebaseLogger.shared.log("🔄 Iniciando subida de \(filesCount) archivo(s) a S3")
        FirebaseLogger.shared.setCustomValue(examName, forKey: "exam_name")
        
        Task {
            var uploadedCount = 0
            var failedCount = 0
            
            for index in fileExams.indices {
                let file = fileExams[index]
                guard !file.imgData.isEmpty else { continue }

                let result = await Network.shared.postSendS3(base64: file.imgData, archivExtension: file.archiveExtension)

                switch result {
                case let .success(urlString):
                    if let url = urlString.data.first {
                        // Como estamos en una Task, necesitamos actualizar en el main thread
                        await MainActor.run {
                            fileExams[index].urlImg = url
                        }
                        uploadedCount += 1
                        // 🔥 FIREBASE LOGGING: Archivo subido exitosamente
                        FirebaseLogger.shared.log("✅ Archivo \(index + 1) subido a S3")
                    }
                    
                case let .failure(error):
                    failedCount += 1
                    // 🔥 FIREBASE LOGGING: Error con contexto detallado
                    FirebaseLogger.shared.log("❌ Error al subir archivo \(index + 1) a S3: \(error.localizedDescription)")
                    FirebaseLogger.shared.recordNetworkError(
                        error,
                        endpoint: "/api/s3/upload",
                        httpCode: (error as? AppError)?.httpCode,
                        method: "POST"
                    )
                    FirebaseLogger.shared.setCustomValues([
                        "file_index": index,
                        "file_extension": file.archiveExtension,
                        "exam_name": examName,
                        "error_context": "upload_to_s3"
                    ])
                    
                    AppStatusManager.error(error)
                }
            }

            // 🔥 FIREBASE LOGGING: Resumen de subida
            FirebaseLogger.shared.log("📊 Subida completada - Éxito: \(uploadedCount), Fallos: \(failedCount)")

            // Validación final: al menos una URL cargada
            let atLeastOneUploaded = fileExams.contains { !$0.urlImg.isEmpty }

            if atLeastOneUploaded {
                postExam()
            } else {
                // 🔥 FIREBASE LOGGING: Error - ningún archivo subido
                FirebaseLogger.shared.log("❌ Error: Ningún archivo se subió correctamente")
                FirebaseLogger.shared.logErrorPopup(
                    title: "Error al Subir Archivos",
                    message: "No se pudo subir ningún archivo",
                    source: "SendNewExamView - sendInfo"
                )
                
                await MainActor.run {
                    self.alertAuthEvent = .SendFileError
                    self.showAlert.toggle()
                    self.isLoading = false
                }
            }
        }
    }
    func postExam(){
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
        
        // 🔥 FIREBASE LOGGING: Inicio de envío de examen
        FirebaseLogger.shared.log("🔄 Enviando examen: \(examName)")
        FirebaseLogger.shared.setCustomValues([
            "exam_name": examName,
            "has_comment": !comment.isEmpty,
            "files_count": fileExams.filter { !$0.urlImg.isEmpty }.count
        ])
        
        Task{
            let result = await Network.shared.postExams(
                examName: examName.uppercased(),
                accountId: accountId,
                url1: fileExams[0].urlImg,
                url2: fileExams[1].urlImg,
                url3: fileExams[2].urlImg,
                url4: fileExams[3].urlImg,
                comment: comment.uppercased(),
                id: exam?.idOrdenMedicaC ?? ""
            )
            
            switch result {
            case .success:
                // 🔥 FIREBASE LOGGING: Examen enviado exitosamente
                FirebaseLogger.shared.log("✅ Examen enviado exitosamente: \(examName)")
                FirebaseLogger.shared.logEvent("exam_submitted_success", attributes: [
                    "exam_name": examName,
                    "files_count": fileExams.filter { !$0.urlImg.isEmpty }.count,
                    "has_comment": !comment.isEmpty
                ])
                
                popup = successPopup
                self.isPublished = true
                
            case let .failure(error):
                // 🔥 FIREBASE LOGGING: Error al enviar examen
                FirebaseLogger.shared.log("❌ Error al enviar examen: \(error.localizedDescription)")
                FirebaseLogger.shared.recordNetworkError(
                    error,
                    endpoint: "/api/exams",
                    httpCode: (error as? AppError)?.httpCode,
                    method: "POST"
                )
                FirebaseLogger.shared.setCustomValues([
                    "exam_name": examName,
                    "account_id": accountId,
                    "files_count": fileExams.filter { !$0.urlImg.isEmpty }.count,
                    "error_context": "post_exam"
                ])
                
                AppStatusManager.error(error)
            }
            self.isLoading = false
        }
    }
    var isSendButtonDisabled: Bool {
        fileExams.allSatisfy { $0.imgData.isEmpty } || isLoading || examName.isEmpty
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
    func isExamPublished(){
        if (self.isPublished)  {
            self.examName = exam?.nombreDelExamenC ?? ""
            self.fileExams[0].urlImg = exam?.urlExamen1C ?? ""
            self.fileExams[1].urlImg = exam?.urlExamen2C ?? ""
            self.fileExams[2].urlImg = exam?.urlExamen3C ?? ""
            self.fileExams[3].urlImg = exam?.urlExamen4C ?? ""
            self.comment = exam?.comentariosC ?? ""
        }
    }
    var commentRow: some View{
        VStack{
            VStack(alignment: .leading) {
                Text("Comentarios")
                    .font(Font.custom(UIState.examDetail.medic.font, size: CGFloat(Int(UIState.examDetail.medic.size) ?? 12)))
                    .foregroundColor(Color(hex: UIState.examDetail.medic.color))
                Group {
                    ZStack(alignment: .topLeading) {
                        
                        CustomTextEditor(
                            text: $comment,
                            isDisabled: isPublished,
                            font: UIFont(name: UIState.examDetail.title.font, size: CGFloat(Int(UIState.examDetail.title.size) ?? 12)) ?? .systemFont(ofSize: 12),
                            textColor: UIColor(Color(hex: UIState.examDetail.title.color)),
                            textCase: .uppercase
                        )
                        .padding(.margin / 2)
                        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .topLeading)
                        .background{
                            Color.grayLight
                        }
                        .cornerRadius(.cornerRadius)
                        
                        if comment.isEmpty {
                            Text("Ingrese comentarios adicionales (opcional)")
                                .padding(.margin / 2)
                                .foregroundColor(.gray.opacity(0.5))
                                .font(Font.custom(UIState.examDetail.title.font, size: CGFloat(Int(UIState.examDetail.title.size) ?? 12)))
                        }

                    }
                }
                .frame(height: 100)
                .cornerRadius(.cornerRadius)
            }
            
            Text("\(comment.count)/255")
                .font(Font.custom(UIState.examDetail.title.font, size: CGFloat(Int(UIState.examDetail.title.size) ?? 12)))
                .foregroundColor(Color(hex: UIState.examDetail.title.color))
                .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .onChange(of: comment) { newValue in
            if newValue.count > 255 {
                comment = String(newValue.prefix(255))
            }
        }
    }
}


struct FileExam: Identifiable {
    let id: UUID = UUID()
    var imgData: String = ""
    var urlImg: String = ""
    var archiveExtension: String = ""
}



