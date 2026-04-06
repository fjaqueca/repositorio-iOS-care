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
    @State private var showDownloadSuccessDialog: Bool = false
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
    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Divider()
                ScrollView {
                    VStack(spacing: 20) {
                        // Main card
                        VStack(alignment: .leading, spacing: 0) {
                            // Exam name & date
                            VStack(alignment: .leading, spacing: 6) {
                                Text(exam.Name ?? "Sin nombre")
                                    .font(Font.custom("FiraSans-Bold", size: 16))
                                    .foregroundColor(Color(hex: "#333333"))
                                    .lineLimit(3)

                                if let dateStr = exam.desdeC, !dateStr.isEmpty {
                                    Text(dateStr)
                                        .font(Font.custom("FiraSans-Regular", size: 13))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                            Divider()
                                .padding(.horizontal, 16)

                            // Indicaciones
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Indicaciones")
                                    .font(Font.custom("FiraSans-Bold", size: 15))
                                    .foregroundColor(Color(hex: "#333333"))

                                Text(exam.descripcionC ?? "Sin descripción")
                                    .font(Font.custom("FiraSans-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 12)

                            Divider()
                                .padding(.horizontal, 16)

                            // Examen adjunto
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Examen adjunto")
                                    .font(Font.custom("FiraSans-Medium", size: 14))
                                    .foregroundColor(Color(hex: "#333333"))

                                Button {
                                    downloadArchive(action: .isOpen)
                                } label: {
                                    VStack {
                                        if let url = URL(string: UIState.examDetail.svgIconShowArchive) {
                                            WebImage(url: url) { image in
                                                image.resizable()
                                                    .scaledToFit()
                                                    .frame(height: 42)
                                            } placeholder: {
                                                Image(systemName: "doc.richtext")
                                                    .font(.system(size: 32, weight: .light))
                                                    .foregroundColor(accentColor)
                                            }
                                        } else {
                                            Image(systemName: "doc.richtext")
                                                .font(.system(size: 32, weight: .light))
                                                .foregroundColor(accentColor)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 14)

                            // Download & Share buttons
                            buttonsBottom
                                .padding(.horizontal, 16)
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

                        // Subir Examen button
                        subExamButton
                            .padding(.horizontal, .margin)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, .margin)
                }
                .onAppear {
                    isExamPublished()
                }
            }
            .alert(item: $alertAuthEvent, content: { tipe in
                switch tipe {
                case .DownloadSucces:
                    return Alert(title: Text("Descarga Completa"), message: Text("Archivo guardado en: Archivos > iPhone > \(UIState.examList.textToShare)"), dismissButton: .default(Text("OK")))
                case .DownloadError:
                    return Alert(title: Text(""), message: Text("Error en la descarga"), dismissButton: .default(Text("OK")))
                case .SuccessPostExam:
                    return Alert(title: Text(""), message: Text("Exámenes subidos con éxito"), dismissButton: .default(Text("OK")))
                case .SendFileError:
                    return Alert(title: Text(""), message: Text("La imagen excede el tamaño máximo"), dismissButton: .default(Text("OK")))
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(UIState.examDetail.title.text.isEmpty ? "Exámenes Médicos" : UIState.examDetail.title.text)
                        .font(Font.custom("FiraSans-Bold", size: 17))
                        .foregroundColor(Color(hex: UIState.examDetail.title.color.isEmpty ? "#333333" : UIState.examDetail.title.color))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        changeFavorite()
                    }) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : Color(hex: UIState.examDetail.title.color.isEmpty ? "#333333" : UIState.examDetail.title.color))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                }
            }
            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.examList.textToShare).\n", self.urlToShare as Any])
            })
            .sheet(isPresented: $showWebView) {
                WebView(url: self.urlToShare!)
            }
            .alert("Examen descargado correctamente", isPresented: $showDownloadSuccessDialog) {
                Button("Aceptar") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showWebView = true
                    }
                }
            } message: {
                Text("Tu examen quedó guardado en la aplicación de archivos en la ruta: Archivos > iPhone > \(UIState.examList.textToShare)")
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
        .background(Color(.systemGroupedBackground))
    }
    // MARK: - Subir Examen Button
    private var subExamButton: some View {
        Group {
            if isExamPublish {
                Button {
                    sendNewExam = true
                } label: {
                    Text("+ Subir Examen")
                        .font(Font.custom("FiraSans-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: UIState.btnAddSeeExam.btnSeeExam.colorButton.isEmpty ? "#00BCD4" : UIState.btnAddSeeExam.btnSeeExam.colorButton))
                        )
                }
            } else {
                Button {
                    sendNewExam = true
                } label: {
                    Text("+ Subir Examen")
                        .font(Font.custom("FiraSans-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: UIState.btnAddSeeExam.btnAddExam.colorButton.isEmpty ? "#00BCD4" : UIState.btnAddSeeExam.btnAddExam.colorButton))
                        )
                }
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
            } else {
                SendNewExamView(UIState: $UIState, examName: exam.Name ?? "", fromOrderExam: true, exam: medicExamToPatientExam(), publisher: self.publisher)
            }
        }
    }

    // MARK: - Download & Share Buttons
    var buttonsBottom: some View {
        HStack(spacing: 12) {
            Button {
                downloadArchive(action: .isDownload)
            } label: {
                HStack(spacing: 6) {
                    Text(UIState.examDetail.btnDownload.textBtn.isEmpty ? "Descargar" : UIState.examDetail.btnDownload.textBtn)
                        .font(Font.custom("FiraSans-Medium", size: 14))
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Color(hex: "#333333"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }

            Button {
                downloadArchive(action: .isShare)
            } label: {
                HStack(spacing: 6) {
                    Text(UIState.examDetail.btnShare.textBtn.isEmpty ? "Compartir" : UIState.examDetail.btnShare.textBtn)
                        .font(Font.custom("FiraSans-Medium", size: 14))
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Color(hex: "#333333"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
    }
  
    /// Flujo completo estilo Android (ExamenPreview):
    /// 1. Verifica URL no vacía
    /// 2. Extrae fileName y objectKey de la URL S3
    /// 3. Verifica caché local
    /// 4. Si existe en caché → abre directo
    /// 5. Si NO existe → getPresignedUrl → descarga → guarda → abre
    func downloadArchive(action: ActionButton, urlParameter: String? = nil) {
        self.isLoading = true
        let rawUrl = urlParameter ?? exam.urlDeLaOrdenMedicaC ?? ""

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 [ExamPreview] CLICK downloadArchive")
        print("📥 [ExamPreview] action: \(action)")
        print("📥 [ExamPreview] urlParameter: \(urlParameter ?? "nil")")
        print("📥 [ExamPreview] exam.urlDeLaOrdenMedicaC: \(exam.urlDeLaOrdenMedicaC ?? "nil")")
        print("📥 [ExamPreview] rawUrl: \(rawUrl)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        guard !rawUrl.isEmpty else {
            print("❌ [ExamPreview] URL vacía, abortando")
            self.isLoading = false
            self.alertAuthEvent = .DownloadError
            return
        }

        // Paso 1: Extraer fileName y objectKey (igual que Android)
        let fileName = S3FileHelper.extractFileNameFromUrl(rawUrl)
        let objectKey = S3FileHelper.extractObjectKeyFromUrl(rawUrl)

        print("📥 [ExamPreview] fileName extraido: \(fileName)")
        print("📥 [ExamPreview] objectKey extraido: \(objectKey)")

        // Paso 2: Verificar caché local solo para "Ver PDF" (Android: isFileInDownloads solo en Ver, no en Descargar)
        if action == .isOpen, let cachedFileUrl = S3FileHelper.getCachedFileUrl(fileName: fileName) {
            print("✅ [ExamPreview] Archivo encontrado en caché, abriendo directamente")
            self.isLoading = false
            handleLocalFile(cachedFileUrl, action: action)
            return
        }

        print("📥 [ExamPreview] Archivo NO en caché, llamando a getPresignedUrl...")
        print("📥 [ExamPreview] POST body: {\"object_key\": \"\(objectKey)\", \"filename\": \"\(fileName)\"}")

        // Paso 3: Obtener URL pre-firmada y descargar
        Task {
            let result = await Network.shared.getPresignedUrl(objectKey: objectKey, filename: fileName)
            switch result {
            case let .success(response):
                print("✅ [ExamPreview] Respuesta del servicio:")
                print("   - url: \(response.url?.prefix(80) ?? "nil")...")
                print("   - error: \(response.error)")
                print("   - message: \(response.message ?? "nil")")

                guard let presignedUrl = response.url, !response.error else {
                    print("❌ [ExamPreview] Respuesta con error o sin URL")
                    self.isLoading = false
                    self.alertAuthEvent = .DownloadError
                    return
                }

                // Paso 4: Descargar desde URL pre-firmada y guardar
                do {
                    print("📥 [ExamPreview] Descargando archivo desde URL pre-firmada...")
                    let localFileUrl = try await S3FileHelper.downloadAndSave(from: presignedUrl, fileName: fileName)
                    print("✅ [ExamPreview] Archivo descargado y guardado: \(localFileUrl.path)")
                    self.isLoading = false
                    handleLocalFile(localFileUrl, action: action)
                } catch {
                    print("❌ [ExamPreview] Error al descargar archivo: \(error.localizedDescription)")
                    self.isLoading = false
                    self.alertAuthEvent = .DownloadError
                }

            case let .failure(error):
                print("❌ [ExamPreview] Error en la peticion getPresignedUrl:")
                print("   - id: \(error.id)")
                print("   - name: \(error.name)")
                print("   - message: \(error.message)")
                self.isLoading = false
                self.alertAuthEvent = .DownloadError
            }
        }
    }

    func handleLocalFile(_ fileURL: URL, action: ActionButton) {
        print("📥 [ExamPreview] handleLocalFile -> action: \(action), fileURL: \(fileURL.path)")
        switch action {
        case .isOpen:
            self.urlToShare = fileURL
            self.showWebView.toggle()
            print("✅ [ExamPreview] Abriendo archivo en WebView")
        case .isDownload:
            self.urlToShare = fileURL
            self.showDownloadSuccessDialog = true
            print("✅ [ExamPreview] Descarga completada, mostrando dialog de éxito")
        case .isShare:
            self.urlToShare = fileURL
            self.showSheetView.toggle()
            print("✅ [ExamPreview] Compartiendo archivo")
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
    func medicExamToPatientExam() -> FunctionFilterExamResponse.PatientExams{
        return FunctionFilterExamResponse.PatientExams(attributes: nil, pacienteC: exam.pacienteC, Id: nil, nombreDelExamenC: exam.Name, urlExamen1C: exam.url1C, urlExamen2C: exam.url2C, urlExamen3C: exam.url3C, urlExamen4C: exam.url4C, comentariosC: exam.comment, CreatedDate: nil, idOrdenMedicaC: exam.Id)
    }
}
