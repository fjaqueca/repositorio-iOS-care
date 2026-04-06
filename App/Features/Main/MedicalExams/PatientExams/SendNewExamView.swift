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

    enum AlertAuthEvent: Identifiable {
        var id: Int { hashValue }
        case DownloadSucces
        case DownloadError
        case SuccessPostExam
        case SendFileError
    }

    @State var comment: String = ""

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Divider()

                ScrollView {
                    VStack(spacing: 16) {
                        // Card 1: Nombre del Examen
                        examNameCard

                        // Card 2: Examenes enviados (file attachments)
                        fileAttachmentCard

                        // Card 3: Comentarios
                        commentCard
                    }
                    .padding(.horizontal, .margin)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }

                // Save button
                if !isPublished {
                    saveButton
                }
            }
            .popup(item: $popup)
            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["\u{00A1}Hola! Estos documentos fueron compartidos desde la App \(UIState.examList.textToShare).\n", self.urlToShare as Any])
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

            if isLoading {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(accentColor)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Exámenes Médicos")
                    .font(Font.custom("FiraSans-Bold", size: 18))
                    .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("back")
                        .renderingMode(.template)
                        .tint(.black)
                }
            }
        }
        .task {
            self.isExamPublished()
        }
        .background(
            Group {
                if UIState.examDetail.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: UIState.examDetail.imageBackground),
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

    // MARK: - Card 1: Nombre del Examen
    private var examNameCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title
            Text("Nombre del Examen *")
                .font(Font.custom("FiraSans-Bold", size: 15))
                .foregroundColor(.primary)

            // Subtitle
            Text("Identifique el examen que desea subir")
                .font(Font.custom("FiraSans-Regular", size: 12))
                .foregroundColor(.gray)

            // Input field with accent border and counter inside
            HStack {
                TextField("Ingrese el nombre del examen", text: $examName)
                    .font(Font.custom("FiraSans-Regular", size: 14))
                    .foregroundColor(.primary)
                    .disabled(isPublished || fromOrderExam)
                    .textCase(.uppercase)
                    .autocapitalization(.allCharacters)
                    .onChange(of: examName) { nuevoTexto in
                        if nuevoTexto.count > 255 {
                            examName = String(nuevoTexto.prefix(255))
                        }
                    }

                Spacer(minLength: 8)

                Text("\(examName.count)/255")
                    .font(Font.custom("FiraSans-Regular", size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(accentColor.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Card 2: Examenes enviados
    private var fileAttachmentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title in accent color
            Text(isPublished ? (UIState.examDetail.sendedExamText2.isEmpty ? "Exámenes enviados" : UIState.examDetail.sendedExamText2) : (UIState.examDetail.sendedExamText1.isEmpty ? "Exámenes enviados" : UIState.examDetail.sendedExamText1))
                .font(Font.custom("FiraSans-Bold", size: 15))
                .foregroundColor(accentColor)

            // Subtitle
            Text("Para adjuntar sus exámenes oprima en los vínculos de arriba. Podrá adjuntar hasta 4 archivos.")
                .font(Font.custom("FiraSans-Regular", size: 12))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)

            // File cards grid (2x2)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Card 3: Comentarios
    private var commentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title
            Text("Comentarios")
                .font(Font.custom("FiraSans-Bold", size: 15))
                .foregroundColor(.primary)

            // Subtitle
            Text("Agregue notas o instrucciones adicionales")
                .font(Font.custom("FiraSans-Regular", size: 12))
                .foregroundColor(.gray)

            // Text area
            ZStack(alignment: .topLeading) {
                CustomTextEditor(
                    text: $comment,
                    isDisabled: isPublished,
                    font: UIFont(name: "FiraSans-Regular", size: 14) ?? .systemFont(ofSize: 14),
                    textColor: UIColor(.primary),
                    textCase: .uppercase
                )
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 120, alignment: .topLeading)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.5), lineWidth: 1)
                )

                if comment.isEmpty {
                    Text("Ingrese comentarios adicionales (opcional)")
                        .padding(12)
                        .foregroundColor(.gray.opacity(0.45))
                        .font(Font.custom("FiraSans-Regular", size: 14))
                        .allowsHitTesting(false)
                }
            }

            // Counter
            HStack {
                Spacer()
                Text("\(comment.count)/255")
                    .font(Font.custom("FiraSans-Regular", size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .onChange(of: comment) { newValue in
            if newValue.count > 255 {
                comment = String(newValue.prefix(255))
            }
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            sendInfo()
        } label: {
            Text("Guardar")
                .font(Font.custom("FiraSans-Bold", size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSendButtonDisabled ? Color.gray.opacity(0.4) : accentColor)
                )
        }
        .disabled(isSendButtonDisabled)
        .padding(.horizontal, .margin)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(
            Color(.systemGroupedBackground)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: -3)
        )
    }

    // MARK: - Functions (unchanged logic)
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

    func downloadArchive(action: ActionButton, urlParameter: String? = nil) {
        self.isLoading = true
        let rawUrl = urlParameter ?? ""

        guard !rawUrl.isEmpty else {
            FirebaseLogger.shared.log("Error: URL de PDF vacia")
            self.isLoading = false
            self.alertAuthEvent = .DownloadError
            return
        }

        let fileName = S3FileHelper.extractFileNameFromUrl(rawUrl)
        let objectKey = S3FileHelper.extractObjectKeyFromUrl(rawUrl)
        FirebaseLogger.shared.log("Obteniendo URL pre-firmada: \(fileName), objectKey: \(objectKey)")

        // Verificar caché local solo para "Ver PDF" (Descargar siempre re-descarga, igual que Android)
        if action == .isOpen, let cachedFileUrl = S3FileHelper.getCachedFileUrl(fileName: fileName) {
            FirebaseLogger.shared.log("Archivo encontrado en caché")
            self.isLoading = false
            handleLocalFile(cachedFileUrl, action: action)
            return
        }

        Task {
            let result = await Network.shared.getPresignedUrl(objectKey: objectKey, filename: fileName)
            switch result {
            case let .success(response):
                guard let presignedUrl = response.url, !response.error else {
                    FirebaseLogger.shared.log("Error: respuesta sin URL valida")
                    self.isLoading = false
                    self.alertAuthEvent = .DownloadError
                    return
                }
                FirebaseLogger.shared.log("URL pre-firmada obtenida exitosamente")
                do {
                    let localFileUrl = try await S3FileHelper.downloadAndSave(from: presignedUrl, fileName: fileName)
                    self.isLoading = false
                    handleLocalFile(localFileUrl, action: action)
                } catch {
                    FirebaseLogger.shared.log("Error al descargar: \(error.localizedDescription)")
                    self.isLoading = false
                    self.alertAuthEvent = .DownloadError
                }
            case let .failure(error):
                FirebaseLogger.shared.log("Error getPresignedUrl: \(error.message)")
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

    func sendInfo() {
        self.isLoading = true

        let filesCount = fileExams.filter { !$0.imgData.isEmpty }.count
        FirebaseLogger.shared.log("Iniciando subida de \(filesCount) archivo(s) a S3")
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
                        await MainActor.run {
                            fileExams[index].urlImg = url
                        }
                        uploadedCount += 1
                        FirebaseLogger.shared.log("Archivo \(index + 1) subido a S3")
                    }

                case let .failure(error):
                    failedCount += 1
                    FirebaseLogger.shared.log("Error al subir archivo \(index + 1) a S3: \(error.localizedDescription)")
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

            FirebaseLogger.shared.log("Subida completada - Exito: \(uploadedCount), Fallos: \(failedCount)")

            let atLeastOneUploaded = fileExams.contains { !$0.urlImg.isEmpty }

            if atLeastOneUploaded {
                postExam()
            } else {
                FirebaseLogger.shared.log("Error: Ningun archivo se subio correctamente")
                FirebaseLogger.shared.logErrorPopup(
                    title: "Error al Subir Archivos",
                    message: "No se pudo subir ningun archivo",
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

    func postExam() {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""

        FirebaseLogger.shared.log("Enviando examen: \(examName)")
        FirebaseLogger.shared.setCustomValues([
            "exam_name": examName,
            "has_comment": !comment.isEmpty,
            "files_count": fileExams.filter { !$0.urlImg.isEmpty }.count
        ])

        Task {
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
                FirebaseLogger.shared.log("Examen enviado exitosamente: \(examName)")
                FirebaseLogger.shared.logEvent("exam_submitted_success", attributes: [
                    "exam_name": examName,
                    "files_count": fileExams.filter { !$0.urlImg.isEmpty }.count,
                    "has_comment": !comment.isEmpty
                ])
                popup = successPopup
                self.isPublished = true

            case let .failure(error):
                FirebaseLogger.shared.log("Error al enviar examen: \(error.localizedDescription)")
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

    enum ActionButton: Identifiable {
        var id: Int { hashValue }
        case isDownload
        case isShare
        case isOpen
    }


    func isExamPublished() {
        if (self.isPublished) {
            self.examName = exam?.nombreDelExamenC ?? ""
            self.fileExams[0].urlImg = exam?.urlExamen1C ?? ""
            self.fileExams[1].urlImg = exam?.urlExamen2C ?? ""
            self.fileExams[2].urlImg = exam?.urlExamen3C ?? ""
            self.fileExams[3].urlImg = exam?.urlExamen4C ?? ""
            self.comment = exam?.comentariosC ?? ""
        }
    }
}


struct FileExam: Identifiable {
    let id: UUID = UUID()
    var imgData: String = ""
    var urlImg: String = ""
    var archiveExtension: String = ""
}
