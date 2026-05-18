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
    // Config dinámica COMPLETA de esta pantalla. Toda la UI proviene del
    // Elemento 10 del record `ExamenesAutomatizadosCustom` — no se lee
    // SecMas ni ningún otro elemento para los textos/estilos visibles.
    var vistaSubir: VistaSubirExamenConfig = VistaSubirExamenConfig()
    // (legacy) botonesDetalleExamen sigue alimentando la vista "publicada"
    // cuando se navega desde el detalle de Prescripciones Médicas. Para el
    // flujo de Mis Archivos de Salud usa `vistaDetalleMisArchivos` (Elemento 8)
    // y este queda con default sin efecto.
    var botonesDetalleExamen: BotonesDetalleExamenConfig = BotonesDetalleExamenConfig()
    // Config completa del detalle de Mis Archivos de Salud — Elemento 8 del
    // record `ExamenesAutomatizadosCustom`. Se pasa SOLO cuando el origen es
    // la lista de Mis Archivos de Salud. Si está set y isPublished=true, el
    // modo lectura usa este struct en lugar de vistaSubir/botonesDetalleExamen.
    var vistaDetalleMisArchivos: VistaDetalleMisArchivosConfig? = nil
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogExamenesEnviadosConfig: DialogExamenesEnviadosConfig = DialogExamenesEnviadosConfig()
    var dialogEliminarDocOrdenConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
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
    // Estados del modal de éxito custom (con animación del check).
    @State private var showSuccessModal: Bool = false
    @State private var checkScale: CGFloat = 0.0
    @State private var checkOpacity: Double = 0.0
    @State private var showConfetti: Bool = false

    enum AlertAuthEvent: Identifiable {
        var id: Int { hashValue }
        case DownloadSucces
        case DownloadError
        case SuccessPostExam
        case SendFileError
    }

    @State private var selectedDocumentType: String = ""
    private let documentTypeOptions = ["Examen de Laboratorio", "Examen de Imagen", "Receta Médica", "Orden de Exámenes", "Informe Médico", "Otros"]

    // Color de fondo del botón Enviar (10.10). Si no hay config, fallback gris.
    private var sendButtonBackgroundColor: Color {
        let c = vistaSubir.botonEnviar.colorFondo
        return Color(hex: c.isEmpty ? "#387FC2" : c)
    }

    /// Convierte la "Position" de Salesforce ("Left"/"Center"/"Right") a SwiftUI Alignment.
    private func alignmentFor(_ position: String) -> Alignment {
        switch position.lowercased() {
        case "center":  return .center
        case "right":   return .trailing
        default:        return .leading
        }
    }

    /// Variante para `multilineTextAlignment` — sin esto, el texto multi-línea
    /// (como la Nota 10.9) no se alinea internamente aunque el frame externo sí.
    private func textAlignmentFor(_ position: String) -> TextAlignment {
        switch position.lowercased() {
        case "center":  return .center
        case "right":   return .trailing
        default:        return .leading
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
                .onAppear {
                    let csa = vistaSubir.containerSinArchivo
                    let cca = vistaSubir.containerConArchivo
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("📋 [SendNewExamView] vistaSubir RECIBIDO en init de body")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("   titulo:    \"\(vistaSubir.tituloTexto)\"")
                    print("   notaTexto: \"\(vistaSubir.notaTexto)\"")
                    print("   [10.7] sinArchivo: borde=\"\(csa.colorBorde)\" icono=\"\(csa.icono)\" colorIcono=\"\(csa.colorIcono)\" sizeIcono=\"\(csa.sizeIcono)\" fondo=\"\(csa.colorFondoContainer)\"")
                    print("   [10.8] conArchivo: borde=\"\(cca.colorBorde)\" icono=\"\(cca.icono)\" colorIcono=\"\(cca.colorIcono)\" sizeIcono=\"\(cca.sizeIcono)\" textoFormato=\"\(cca.colorTextoFormato)\" iconoX=\"\(cca.iconoCancelar)\" fondoX=\"\(cca.colorFondoBotonCancelar)\" cruz=\"\(cca.colorCruz)\" fondoContainer=\"\(cca.colorFondoContainer)\"")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }

            VStack(spacing: 0) {
                Divider()

                ScrollView {
                    if isPublished {
                        publishedDocumentView
                            .padding(.horizontal, .margin)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                            .onAppear {
                                let btns = botonesDetalleExamen
                                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                                print("📋 [SendNewExamView] CONFIG DINÁMICA BOTONES DETALLE")
                                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                                print("   tituloArchivosAdjuntos: \"\(btns.tituloArchivosAdjuntos)\"")
                                print("   tituloAttr: font=\(btns.tituloArchivosAdjuntosAttr.font) size=\(btns.tituloArchivosAdjuntosAttr.size) color=\(btns.tituloArchivosAdjuntosAttr.color)")
                                print("   btnDescargar: texto=\"\(btns.botonDescargar.texto)\" font=\(btns.botonDescargar.font) size=\(btns.botonDescargar.size) colorTexto=\(btns.botonDescargar.colorTexto) colorFondo=\(btns.botonDescargar.colorFondo) icono=\(btns.botonDescargar.icono) colorIcono=\(btns.botonDescargar.colorIcono) colorBorde=\(btns.botonDescargar.colorBorde)")
                                print("   btnCompartir: texto=\"\(btns.botonCompartir.texto)\" font=\(btns.botonCompartir.font) size=\(btns.botonCompartir.size) colorTexto=\(btns.botonCompartir.colorTexto) colorFondo=\(btns.botonCompartir.colorFondo) icono=\(btns.botonCompartir.icono) colorIcono=\(btns.botonCompartir.colorIcono) colorBorde=\(btns.botonCompartir.colorBorde)")
                                print("   btnEliminar: texto=\"\(btns.botonEliminar.texto)\" font=\(btns.botonEliminar.font) size=\(btns.botonEliminar.size) colorTexto=\(btns.botonEliminar.colorTexto) colorFondo=\(btns.botonEliminar.colorFondo) icono=\(btns.botonEliminar.icono) colorIcono=\(btns.botonEliminar.colorIcono) colorBorde=\(btns.botonEliminar.colorBorde)")
                                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            }
                    } else {
                        VStack(spacing: 16) {
                            documentTypeCard
                            fileAttachmentCard
                        }
                        .padding(.horizontal, .margin)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }

                if isPublished {
                    publishedButtons
                } else {
                    saveButton
                }
            }
            .slideInFromRight()
            // Blur del contenido detrás del loading (mismo patrón que el resto de la app).
            .blur(radius: isLoading ? 3 : 0.000001)
            .popup(item: $popup)
            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["\u{00A1}Hola! Estos documentos fueron compartidos desde la App.\n", self.urlToShare as Any])
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
                                // Galería no provee nombre original — generamos uno legible con timestamp.
                                let ts = Int(Date().timeIntervalSince1970)
                                fileExams[index].originalFileName = "imagen_\(ts).jpg"
                            }
                            resetPickerState()
                        }
                    case .document:
                        DocumentPickerView { url in
                            do {
                                let data = try Data(contentsOf: url)
                                fileExams[index].imgData = data.base64EncodedString()
                                fileExams[index].archiveExtension = url.pathExtension
                                // Preservamos el nombre original del archivo (Campo_10__c).
                                fileExams[index].originalFileName = url.lastPathComponent
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

            // Loading estándar de la app (mismo estilo que AutomatedExamsView):
            // overlay oscuro semi-transparente + spinner celeste grande centrado.
            // Aparece al pulsar "Enviar" y se mantiene durante toda la cadena
            // (N subidas a S3 + postExams). Se desactiva siempre en MainActor en
            // success, en error y en abort por fallo de S3.
            if isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#00BBDC")))
                        .scaleEffect(1.8)
                }
                .zIndex(30)
            }

            // Modal de éxito custom (reemplaza el successPopup genérico).
            if showSuccessModal {
                successModalView
                    .zIndex(40)
                    .transition(.opacity)
            }

            // Modal de confirmación de eliminación (usa config específica de Custom2 Elem 2)
            if showDeleteConfirmation {
                ExamDeleteConfirmationModal(
                    onConfirm: {
                        deleteExamFiles()
                    },
                    onCancel: {
                        showDeleteConfirmation = false
                    },
                    isLoading: deletingLoading,
                    config: dialogEliminarDocOrdenConfig
                )
                .zIndex(50)
                .transition(.opacity)
            }
        }
        .confetti(isActive: $showConfetti)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Título — si la pantalla está en modo detalle de Mis Archivos
            // (vistaDetalleMisArchivos set + isPublished), usa 8.2; si no, 10.2.
            ToolbarItem(placement: .principal) {
                let useMisArchivos = (vistaDetalleMisArchivos != nil) && isPublished
                let texto = useMisArchivos
                    ? (vistaDetalleMisArchivos!.tituloTexto.isEmpty ? "Mis Archivos de Salud" : vistaDetalleMisArchivos!.tituloTexto)
                    : (vistaSubir.tituloTexto.isEmpty ? "Exámenes Médicos" : vistaSubir.tituloTexto)
                let attr = useMisArchivos ? vistaDetalleMisArchivos!.tituloAttr : vistaSubir.tituloAttr
                Text(texto)
                    .font(Font.custom(
                        attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                        size: CGFloat(Int(attr.size) ?? 19)
                    ))
                    .foregroundColor(Color(hex: attr.color.isEmpty ? "#00BBDC" : attr.color))
            }
            // Back arrow — 8.1 en modo detalle Mis Archivos, 10.1 en otro caso.
            ToolbarItem(placement: .navigationBarLeading) {
                let useMisArchivos = (vistaDetalleMisArchivos != nil) && isPublished
                let raw = useMisArchivos
                    ? vistaDetalleMisArchivos!.backArrowColor
                    : vistaSubir.backArrowColor
                Button {
                    HapticManager.impact(style: .light)
                    dismiss()
                } label: {
                    Image("back")
                        .renderingMode(.template)
                        .foregroundColor(Color(hex: raw.isEmpty ? "#00BBDC" : raw))
                }
            }
        }
        .task {
            self.isExamPublished()
        }
    }

    // MARK: - Card 1: ¿Qué vas a cargar? (10.3)
    private var documentTypeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(vistaSubir.tipoDocumentoTexto.isEmpty ? "¿Qué vas a cargar? *" : vistaSubir.tipoDocumentoTexto)
                .font(Font.custom(
                    vistaSubir.tipoDocumentoAttr.font.isEmpty ? "FiraSans-Bold" : vistaSubir.tipoDocumentoAttr.font,
                    size: CGFloat(Int(vistaSubir.tipoDocumentoAttr.size) ?? 15)
                ))
                .foregroundColor(Color(hex: vistaSubir.tipoDocumentoAttr.color.isEmpty ? "#333333" : vistaSubir.tipoDocumentoAttr.color))
                .frame(maxWidth: .infinity, alignment: alignmentFor(vistaSubir.tipoDocumentoAttr.alignment))

            Menu {
                ForEach(documentTypeOptions, id: \.self) { option in
                    Button(action: {
                        selectedDocumentType = option
                        examName = option
                    }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if selectedDocumentType == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedDocumentType.isEmpty ? "Selecciona una opción" : selectedDocumentType)
                        .font(.system(size: 15))
                        .foregroundColor(selectedDocumentType.isEmpty ? Color.gray.opacity(0.5) : Color(red: 0.2, green: 0.2, blue: 0.2))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
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

    // MARK: - Card 2: Adjuntar archivo (10.5 + 10.6 + 10.9)
    private var fileAttachmentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 10.5 TextoAdjuntarArchivo
            Text(vistaSubir.adjuntarArchivoTexto.isEmpty ? "Adjuntar archivo" : vistaSubir.adjuntarArchivoTexto)
                .font(Font.custom(
                    vistaSubir.adjuntarArchivoAttr.font.isEmpty ? "FiraSans-Bold" : vistaSubir.adjuntarArchivoAttr.font,
                    size: CGFloat(Int(vistaSubir.adjuntarArchivoAttr.size) ?? 15)
                ))
                .foregroundColor(Color(hex: vistaSubir.adjuntarArchivoAttr.color.isEmpty ? "#333333" : vistaSubir.adjuntarArchivoAttr.color))
                .frame(maxWidth: .infinity, alignment: alignmentFor(vistaSubir.adjuntarArchivoAttr.alignment))

            // 10.6 DescripcionAdjuntarArchivo
            Text(vistaSubir.descripcionAdjuntarTexto.isEmpty
                 ? "Los formatos permitidos son PDF, JPG, PNG, con un máximo de 4 archivos"
                 : vistaSubir.descripcionAdjuntarTexto)
                .font(Font.custom(
                    vistaSubir.descripcionAdjuntarAttr.font.isEmpty ? "FiraSans-Regular" : vistaSubir.descripcionAdjuntarAttr.font,
                    size: CGFloat(Int(vistaSubir.descripcionAdjuntarAttr.size) ?? 12)
                ))
                .foregroundColor(Color(hex: vistaSubir.descripcionAdjuntarAttr.color.isEmpty ? "#4CAF50" : vistaSubir.descripcionAdjuntarAttr.color))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: alignmentFor(vistaSubir.descripcionAdjuntarAttr.alignment))

            // File cards grid (2x2) — los containers usan 10.7 / 10.8
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach($fileExams) { $fileExam in
                    FileRowExam(
                        fileExam: $fileExam,
                        isExamPublish: $isPublished,
                        UIState: $UIState,
                        containerSinArchivo: vistaSubir.containerSinArchivo,
                        containerConArchivo: vistaSubir.containerConArchivo,
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
                    HapticManager.impact(style: .light)
                    selectedSourceType = .camera
                    showFilePicker = true
                }
                Button("Seleccionar archivo") {
                    HapticManager.impact(style: .light)
                    selectedSourceType = .document
                    showFilePicker = true
                }
            }

            // 10.9 TextoNota — soporta markup **bold** y <br> vía parseSalesforceText
            parseSalesforceText(
                vistaSubir.notaTexto.isEmpty
                    ? "**Nota:** Los archivos cargados serán respaldados en tu ficha de salud."
                    : vistaSubir.notaTexto,
                font: vistaSubir.notaAttr.font.isEmpty ? "FiraSans-Regular" : vistaSubir.notaAttr.font,
                size: CGFloat(Int(vistaSubir.notaAttr.size) ?? 11),
                color: Color(hex: vistaSubir.notaAttr.color.isEmpty ? "#888888" : vistaSubir.notaAttr.color)
            )
            .multilineTextAlignment(textAlignmentFor(vistaSubir.notaAttr.alignment))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: alignmentFor(vistaSubir.notaAttr.alignment))
            .padding(.top, 8)
            .onAppear {
                let nota = vistaSubir.notaAttr
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [SendNewExamView] CONFIG TEXTO NOTA (10.9)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("   texto:     \"\(vistaSubir.notaTexto)\"")
                print("   font:      \(nota.font)")
                print("   size:      \(nota.size)")
                print("   color:     \(nota.color)")
                print("   alignment: \(nota.alignment)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
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

    // MARK: - Published Document View (modo lectura)
    private var publishedDocumentView: some View {
        // Si la pantalla está mostrando el detalle de un Archivo de Salud, usa
        // el Elemento 8 (vistaDetalleMisArchivos). Si no, usa el flujo legacy
        // de prescripciones médicas (Elemento 10 + 13).
        Group {
            if let cfg = vistaDetalleMisArchivos {
                misArchivosDetalleView(cfg: cfg)
            } else {
                prescripcionesDetalleView
            }
        }
    }

    // MARK: - Detalle Mis Archivos de Salud (Elemento 8)
    private func misArchivosDetalleView(cfg: VistaDetalleMisArchivosConfig) -> some View {
        VStack(spacing: 16) {
            // Diagnóstico al primer render
            Color.clear.frame(height: 0).onAppear {
                let cArc = cfg.containerArchivo
                let bD = cfg.botonDescargar
                let bC = cfg.botonCompartir
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📋 [misArchivosDetalleView] CONFIG RECIBIDA")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("   [8.7] container: borde=\"\(cArc.colorBorde)\" icono=\"\(cArc.icono)\" colorIcono=\"\(cArc.colorIcono)\" sizeIcono=\"\(cArc.sizeIcono)\" textoFormato=\"\(cArc.colorTextoFormato)\" fondo=\"\(cArc.colorFondoContainer)\"")
                print("   [8.8] btnDescargar: font=\(bD.font) texto=\"\(bD.texto)\" colorTexto=\(bD.colorTexto) size=\(bD.size) colorFondo=\(bD.colorFondo) icono=\(bD.icono) colorIcono=\(bD.colorIcono) colorBorde=\(bD.colorBorde)")
                print("   [8.9] btnCompartir: font=\(bC.font) texto=\"\(bC.texto)\" colorTexto=\(bC.colorTexto) size=\(bC.size) colorFondo=\(bC.colorFondo) icono=\(bC.icono) colorIcono=\(bC.colorIcono) colorBorde=\(bC.colorBorde)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }

            // Card 1 — Nombre + badge "Cargado por el Paciente" + fecha
            VStack(alignment: .leading, spacing: 10) {
                // 8.3 AtributosTituloCardDetalle
                Text((exam?.nombreDelExamenC ?? examName).uppercased())
                    .font(Font.custom(
                        cfg.tituloCardAttr.font.isEmpty ? "FiraSans-Bold" : cfg.tituloCardAttr.font,
                        size: CGFloat(Int(cfg.tituloCardAttr.size) ?? 16)
                    ))
                    .foregroundColor(Color(hex: cfg.tituloCardAttr.color.isEmpty ? "#333333" : cfg.tituloCardAttr.color))

                // 8.4 BadgeCargadoPorElPaciente
                let badge = cfg.badgeCargadoPorPaciente
                HStack(spacing: 6) {
                    if !badge.icono.isEmpty {
                        Image(systemName: badge.icono)
                            .font(.system(size: CGFloat(Double(badge.size) ?? 11)))
                            .foregroundColor(Color(hex: badge.colorTexto))
                    }
                    Text(badge.texto.isEmpty ? "Cargado por el Paciente" : badge.texto)
                        .font(Font.custom(
                            badge.font.isEmpty ? "FiraSans-Medium" : badge.font,
                            size: CGFloat(Double(badge.size) ?? 11)
                        ))
                        .foregroundColor(Color(hex: badge.colorTexto.isEmpty ? "#FFFFFF" : badge.colorTexto))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color(hex: badge.colorFondo.isEmpty ? "#7B61FF" : badge.colorFondo)))

                // 8.5 FechaDetalleMisArchivosDeSalud
                if let dateStr = exam?.CreatedDate, !dateStr.isEmpty {
                    let fontFecha = cfg.fechaAttr.font.isEmpty ? "FiraSans-Regular" : cfg.fechaAttr.font
                    let sizeFecha = CGFloat(Int(cfg.fechaAttr.size) ?? 13)
                    let colorFecha = Color(hex: cfg.fechaAttr.color.isEmpty ? "#888888" : cfg.fechaAttr.color)
                    let iconoFecha = cfg.fechaIcono.isEmpty ? "calendar" : cfg.fechaIcono
                    let colorIcono = Color(hex: cfg.fechaIconoColor.isEmpty
                        ? (cfg.fechaAttr.color.isEmpty ? "#888888" : cfg.fechaAttr.color)
                        : cfg.fechaIconoColor)
                    HStack(spacing: 6) {
                        Image(systemName: iconoFecha)
                            .font(.system(size: sizeFecha))
                            .foregroundColor(colorIcono)
                        Text(formatDisplayDate(dateStr, formato: cfg.fechaFormato))
                            .font(Font.custom(fontFecha, size: sizeFecha))
                            .foregroundColor(colorFecha)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )

            // Card 2 — Título "Archivos adjuntos" + grid + botones Descargar/Compartir
            VStack(alignment: .leading, spacing: 10) {
                // 8.6 DetalleArchivosAdjuntos
                let titAttr = cfg.detalleArchivosAttr
                let tituloAlign = titAttr.alignment.lowercased()
                let frameAlign: Alignment = tituloAlign == "center" ? .center : (tituloAlign == "right" ? .trailing : .leading)
                Text(cfg.detalleArchivosTitulo.isEmpty ? "Archivos adjuntos" : cfg.detalleArchivosTitulo)
                    .font(Font.custom(
                        titAttr.font.isEmpty ? "FiraSans-Bold" : titAttr.font,
                        size: CGFloat(Int(titAttr.size) ?? 16)
                    ))
                    .foregroundColor(Color(hex: titAttr.color.isEmpty ? "#333333" : titAttr.color))
                    .frame(maxWidth: .infinity, alignment: frameAlign)

                // 8.7 ContainerArchivoAdjunto — mapeado a FileRowExam vía un
                // ContainerConArchivoConfig "compatible" (los campos del botón
                // cancelar no se usan porque isExamPublish=true).
                let containerCompat: ContainerConArchivoConfig = {
                    var c = ContainerConArchivoConfig()
                    c.colorBorde = cfg.containerArchivo.colorBorde
                    c.icono = cfg.containerArchivo.icono
                    c.colorIcono = cfg.containerArchivo.colorIcono
                    c.sizeIcono = cfg.containerArchivo.sizeIcono
                    c.colorTextoFormato = cfg.containerArchivo.colorTextoFormato
                    c.colorFondoContainer = cfg.containerArchivo.colorFondoContainer
                    return c
                }()

                let activeFileExams = fileExams.filter { !$0.urlImg.isEmpty }
                let columns: [GridItem] = activeFileExams.count == 1
                    ? [GridItem(.flexible())]
                    : [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach($fileExams) { $fileExam in
                        if !fileExam.urlImg.isEmpty {
                            FileRowExam(
                                fileExam: $fileExam,
                                isExamPublish: $isPublished,
                                UIState: $UIState,
                                containerSinArchivo: ContainerSinArchivoConfig(),
                                containerConArchivo: containerCompat,
                                onSelect: { _ in },
                                onDownload: {
                                    downloadArchive(action: .isOpen, urlParameter: fileExam.urlImg)
                                }
                            )
                        }
                    }
                }

                // 8.8 BotonDescargar + 8.9 BotonCompartir
                HStack(spacing: 12) {
                    accionButton(cfg: cfg.botonDescargar, fallbackText: "Descargar") {
                        downloadAllFiles()
                    }
                    accionButton(cfg: cfg.botonCompartir, fallbackText: "Compartir") {
                        shareAllFiles()
                    }
                }
                .padding(.top, 4)
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
    }

    /// Renderiza un botón Descargar/Compartir con la firma del 8.8/8.9
    /// (TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde).
    private func accionButton(cfg btn: ButtonExamConfig, fallbackText: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if !btn.icono.isEmpty {
                    Image(systemName: btn.icono)
                        .font(.system(size: CGFloat(Int(btn.size) ?? 14), weight: .medium))
                        .foregroundColor(Color(hex: btn.colorIcono.isEmpty ? btn.colorTexto : btn.colorIcono))
                }
                Text(btn.texto.isEmpty ? fallbackText : btn.texto)
                    .font(Font.custom(
                        btn.font.isEmpty ? "FiraSans-Medium" : btn.font,
                        size: CGFloat(Int(btn.size) ?? 14)
                    ))
            }
            .foregroundColor(Color(hex: btn.colorTexto.isEmpty ? "#333333" : btn.colorTexto))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: btn.colorFondo.isEmpty ? "#FFFFFF" : btn.colorFondo))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: btn.colorBorde.isEmpty ? "#D1D1D6" : btn.colorBorde), lineWidth: 1)
            )
        }
    }

    // MARK: - Detalle Prescripciones Médicas (legacy — Elemento 10 + 13)
    private var prescripcionesDetalleView: some View {
        VStack(spacing: 16) {
            // Card info del documento
            VStack(alignment: .leading, spacing: 10) {
                Text((exam?.nombreDelExamenC ?? examName).uppercased())
                    .font(Font.custom("FiraSans-Bold", size: 16))
                    .foregroundColor(Color(hex: "#333333"))

                // Badge "Cargado por el Paciente" (10.4)
                let badge = vistaSubir.badgeCargadoPorPaciente
                HStack(spacing: 6) {
                    if !badge.icono.isEmpty {
                        Image(systemName: badge.icono)
                            .font(.system(size: CGFloat(Double(badge.size) ?? 11)))
                            .foregroundColor(Color(hex: badge.colorTexto))
                    }
                    Text(badge.texto.isEmpty ? "Cargado por el Paciente" : badge.texto)
                        .font(Font.custom(
                            badge.font.isEmpty ? "FiraSans-Medium" : badge.font,
                            size: CGFloat(Double(badge.size) ?? 11)
                        ))
                        .foregroundColor(Color(hex: badge.colorTexto.isEmpty ? "#FFFFFF" : badge.colorTexto))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color(hex: badge.colorFondo.isEmpty ? "#7B61FF" : badge.colorFondo)))

                if let dateStr = exam?.CreatedDate, !dateStr.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        Text(formatDisplayDate(dateStr))
                            .font(Font.custom("FiraSans-Regular", size: 13))
                            .foregroundColor(.gray)
                    }
                }

                if let comment = exam?.comentariosC, !comment.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        Text(comment)
                            .font(Font.custom("FiraSans-Regular", size: 13))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )

            // Card archivos adjuntos + botones Descargar/Compartir
            VStack(alignment: .leading, spacing: 10) {
                let tituloAttr = botonesDetalleExamen.tituloArchivosAdjuntosAttr
                let tituloAlign = tituloAttr.alignment.lowercased()
                let frameAlign: Alignment = tituloAlign == "center" ? .center : (tituloAlign == "right" ? .trailing : .leading)
                Text(botonesDetalleExamen.tituloArchivosAdjuntos.isEmpty ? "Archivos adjuntos" : botonesDetalleExamen.tituloArchivosAdjuntos)
                    .font(Font.custom(
                        tituloAttr.font.isEmpty ? "FiraSans-Bold" : tituloAttr.font,
                        size: CGFloat(Int(tituloAttr.size) ?? 15)
                    ))
                    .foregroundColor(Color(hex: tituloAttr.color.isEmpty ? "#333333" : tituloAttr.color))
                    .frame(maxWidth: .infinity, alignment: frameAlign)

                let activeFileExams = fileExams.filter { !$0.urlImg.isEmpty }
                let columns: [GridItem] = activeFileExams.count == 1
                    ? [GridItem(.flexible())]
                    : [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach($fileExams) { $fileExam in
                        if !fileExam.urlImg.isEmpty {
                            FileRowExam(
                                fileExam: $fileExam,
                                isExamPublish: $isPublished,
                                UIState: $UIState,
                                containerSinArchivo: vistaSubir.containerSinArchivo,
                                containerConArchivo: vistaSubir.containerConArchivo,
                                onSelect: { _ in },
                                onDownload: {
                                    downloadArchive(action: .isOpen, urlParameter: fileExam.urlImg)
                                }
                            )
                        }
                    }
                }

                // Botones Descargar y Compartir (dinámico desde Elemento 13)
                HStack(spacing: 12) {
                    accionButton(cfg: botonesDetalleExamen.botonDescargar, fallbackText: "Descargar") {
                        downloadAllFiles()
                    }
                    accionButton(cfg: botonesDetalleExamen.botonCompartir, fallbackText: "Compartir") {
                        shareAllFiles()
                    }
                }
                .padding(.top, 4)
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
    }

    // MARK: - Published Buttons (Descargar + Eliminar)
    @State private var showDeleteConfirmation = false
    @State private var deletingLoading = false

    private var publishedButtons: some View {
        // 8.10 BotonEliminarDetalleMiArchivoDeSalud cuando es detalle Mis
        // Archivos; en otro caso, fallback al Elemento 13 legacy.
        // Para Mis Archivos: icono "trash" (hardcoded en el parser), sizeIcono
        // y colorIcono dinámicos. Para el flujo legacy: usa lo que venía del 13.
        let btnElim: ButtonExamConfig = vistaDetalleMisArchivos?.botonEliminar ?? botonesDetalleExamen.botonEliminar
        let isMisArchivos = vistaDetalleMisArchivos != nil

        return Button {
            showDeleteConfirmation = true
        } label: {
            HStack(spacing: 6) {
                if !btnElim.icono.isEmpty {
                    // Si el botón viene del 8.10 con iconoSize dedicado, lo
                    // usamos; si no, fallback al `size` del texto.
                    let iconoSize: CGFloat = {
                        if !btnElim.iconoSize.isEmpty, let s = Double(btnElim.iconoSize) {
                            return CGFloat(s)
                        }
                        return CGFloat(Int(btnElim.size) ?? 16)
                    }()
                    let iconoColor = btnElim.colorIcono.isEmpty
                        ? (btnElim.colorTexto.isEmpty ? "#FFFFFF" : btnElim.colorTexto)
                        : btnElim.colorIcono
                    Image(systemName: btnElim.icono)
                        .font(.system(size: iconoSize, weight: .medium))
                        .foregroundColor(Color(hex: iconoColor))
                }
                Text(btnElim.texto.isEmpty ? "Eliminar" : btnElim.texto)
                    .font(Font.custom(
                        btnElim.font.isEmpty ? "FiraSans-Bold" : btnElim.font,
                        size: CGFloat(Double(btnElim.size) ?? 16)
                    ))
            }
            .foregroundColor(Color(hex: btnElim.colorTexto.isEmpty ? "#FFFFFF" : btnElim.colorTexto))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: btnElim.colorFondo.isEmpty ? "#FF3B30" : btnElim.colorFondo))
                )
        }
        .bounceOnTap()
        .padding(.horizontal, .margin)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(
            Color(.systemGroupedBackground)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: -3)
        )
        .onAppear {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [SendNewExamView] publishedButtons RECIBIDO (Eliminar)")
            print("   modo: \(isMisArchivos ? "Mis Archivos (8.10)" : "Prescripciones (legacy 13)")")
            print("   texto:     \"\(btnElim.texto)\"")
            print("   font:      \(btnElim.font)")
            print("   size:      \(btnElim.size)")
            print("   colorTexto: \(btnElim.colorTexto)")
            print("   colorFondo: \(btnElim.colorFondo)")
            print("   icono:     \(btnElim.icono)")
            print("   iconoSize: \(btnElim.iconoSize)")
            print("   colorIcono: \(btnElim.colorIcono)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }

    // MARK: - Send Button
    // 10.10 BotonEnviar(Texto;Size;ColorTexto;ColorFondo;TipoFuente)
    private var saveButton: some View {
        let btn = vistaSubir.botonEnviar
        let btnTexto = btn.texto.isEmpty ? "Enviar" : btn.texto
        let btnFont = btn.font.isEmpty ? "FiraSans-Bold" : btn.font
        let btnSize = CGFloat(Int(btn.size) ?? 16)
        let btnColorTexto = Color(hex: btn.colorTexto.isEmpty ? "#FFFFFF" : btn.colorTexto)
        return Button {
            HapticManager.impact(style: .medium)
            sendInfo()
        } label: {
            Text(btnTexto)
                .font(Font.custom(btnFont, size: btnSize))
                .foregroundColor(btnColorTexto)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSendButtonDisabled ? Color.gray.opacity(0.4) : sendButtonBackgroundColor)
                )
        }
        .disabled(isSendButtonDisabled)
        .bounceOnTap()
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

    // MARK: - Success Modal (custom redesign)

    /// Modal de éxito que se muestra tras subir los exámenes correctamente.
    /// Diseño: card blanca con check verde animado, título bold, mensaje y botón celeste.
    private var successModalView: some View {
        let cfg = dialogExamenesEnviadosConfig
        let tAttr = cfg.tituloAttr
        let dAttr = cfg.descripcionAttr
        let btn = cfg.botonAceptar

        return ZStack {
            // Backdrop oscuro semi-transparente que cubre toda la pantalla.
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { /* bloquea toques fuera del card */ }

            // Card blanca centrada
            VStack(spacing: 20) {
                // Círculo claro con ícono animado
                ZStack {
                    Circle()
                        .fill(Color(hex: cfg.colorFondoIcono.isEmpty ? "#E8F5E9" : cfg.colorFondoIcono))
                        .frame(width: 78, height: 78)
                    Image(systemName: cfg.icono.isEmpty ? "checkmark" : cfg.icono)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: cfg.colorIcono.isEmpty ? "#4CAF50" : cfg.colorIcono))
                        .scaleEffect(checkScale)
                        .opacity(checkOpacity)
                }
                .padding(.top, 24)

                Text(cfg.titulo.isEmpty ? "¡Exámenes Enviados!" : cfg.titulo)
                    .font(Font.custom(
                        tAttr.font.isEmpty ? "FiraSans-Bold" : tAttr.font,
                        size: CGFloat(Int(tAttr.size) ?? 18)
                    ))
                    .foregroundColor(Color(hex: tAttr.color.isEmpty ? "#222222" : tAttr.color))
                    .multilineTextAlignment(.center)

                if !cfg.descripcion.isEmpty {
                    parseSalesforceText(
                        cfg.descripcion,
                        font: dAttr.font.isEmpty ? "FiraSans-Regular" : dAttr.font,
                        size: CGFloat(Int(dAttr.size) ?? 14),
                        color: Color(hex: dAttr.color.isEmpty ? "#555555" : dAttr.color)
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 12) {
                        Text("Sus exámenes han sido cargados\ncorrectamente.")
                            .font(Font.custom("FiraSans-Regular", size: 14))
                            .foregroundColor(Color(hex: "#555555"))
                            .multilineTextAlignment(.center)
                        Text("Puedes revisarlos en cualquier\nmomento desde tu App.")
                            .font(Font.custom("FiraSans-Regular", size: 14))
                            .foregroundColor(Color(hex: "#555555"))
                            .multilineTextAlignment(.center)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    dismissSuccessModal()
                } label: {
                    Text(btn.texto.isEmpty ? "Aceptar" : btn.texto)
                        .font(Font.custom(
                            btn.font.isEmpty ? "FiraSans-Bold" : btn.font,
                            size: CGFloat(Int(btn.size) ?? 16)
                        ))
                        .foregroundColor(Color(hex: btn.colorTexto.isEmpty ? "#FFFFFF" : btn.colorTexto))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: btn.colorFondo.isEmpty ? "#1A8FCB" : btn.colorFondo))
                        )
                }
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 32)
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        }
    }

    /// Muestra el modal y dispara la animación del check (spring scale + fade in).
    private func presentSuccessModal() {
        let cfg = dialogExamenesEnviadosConfig
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("✅ [SendNewExamView] Mostrando dialog éxito con config dinámica:")
        print("   icono: \"\(cfg.icono)\"")
        print("   titulo: \"\(cfg.titulo)\"")
        print("   tituloAttr: font=\(cfg.tituloAttr.font) size=\(cfg.tituloAttr.size) color=\(cfg.tituloAttr.color)")
        print("   descripcion: \"\(cfg.descripcion)\"")
        print("   descripcionAttr: font=\(cfg.descripcionAttr.font) size=\(cfg.descripcionAttr.size) color=\(cfg.descripcionAttr.color)")
        print("   botonAceptar: texto=\"\(cfg.botonAceptar.texto)\" colorTexto=\(cfg.botonAceptar.colorTexto) colorFondo=\(cfg.botonAceptar.colorFondo)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        // Reset estado de animación antes de mostrar
        checkScale = 0.0
        checkOpacity = 0.0
        withAnimation(.easeOut(duration: 0.2)) {
            showSuccessModal = true
        }
        // Animación del check: aparece con un pequeño bounce desde escala 0.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                checkScale = 1.0
                checkOpacity = 1.0
            }
        }
    }

    /// Cierra el modal y propaga el evento de éxito (mismo callback que el popup viejo).
    private func dismissSuccessModal() {
        withAnimation(.easeIn(duration: 0.2)) {
            showSuccessModal = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
            self.publisher.send()
        }
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
            // Atomicidad: si UNA sola subida a S3 falla, abortamos todo el flujo y NO
            // llamamos al servicio genérico (paridad con web).
            var uploadedCount = 0

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
                    FirebaseLogger.shared.log("Error al subir archivo \(index + 1) a S3: \(error.localizedDescription) — abortando flujo")
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
                        "uploaded_before_failure": uploadedCount,
                        "error_context": "upload_to_s3"
                    ])
                    AppStatusManager.error(error)

                    // Limpiar URLs ya cargadas para no dejar estado inconsistente
                    // (si el usuario reintenta, se vuelven a subir todos).
                    await MainActor.run {
                        for i in fileExams.indices { fileExams[i].urlImg = "" }
                        self.alertAuthEvent = .SendFileError
                        self.showAlert.toggle()
                        self.isLoading = false
                    }
                    return  // ← aborta el Task completo, no se llama postExam()
                }
            }

            FirebaseLogger.shared.log("Subida completada - Exito: \(uploadedCount)/\(filesCount)")
            postExam()
        }
    }

    func postExam() {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""

        // --- Dos conceptos DISTINTOS, no confundir ---
        //
        // Campo_11__c "Tipo de Archivo": picklist RESTRINGIDO en Salesforce. Solo
        //   acepta los valores del dropdown del usuario (selectedDocumentType):
        //   "Examen de Laboratorio", "Examen de Imagen", "Receta Médica",
        //   "Orden de Exámenes", "Informe Médico", "Otros".
        //   ❌ NO acepta "Examen Automatizado" / "Orden médica" (esos son del padre).
        //
        // esExamenAutomatizado: SOLO discriminador interno para decidir si el ID
        //   del registro padre va en Campo_9__c o en Campo_12__c. No viaja como
        //   string al backend en ningún campo.
        let tipoArchivoPicklist = selectedDocumentType
        let esExamenAutomatizado = (exam?.tipoDocumento == .examenAutomatizado)

        // Campo_3__c: nombre del registro padre (sin uppercase).
        let nombreOrdenPadre: String = exam?.nombreOrdenPadre
            ?? exam?.nombreDelExamenC
            ?? examName

        // Compactación: filtramos slots vacíos y armamos arrays paralelos de URLs y nombres.
        // El backend espera Campo_4..7 con las primeras N URLs consecutivas y Campo_10__c
        // con los nombres unidos por ";" en el mismo orden.
        let archivosConUrl = fileExams.filter { !$0.urlImg.isEmpty }
        let urls: [String] = archivosConUrl.map { $0.urlImg }
        let nombresArchivos: [String] = archivosConUrl.map { archivo in
            if !archivo.originalFileName.isEmpty { return archivo.originalFileName }
            return S3FileHelper.extractFileNameFromUrl(archivo.urlImg)
        }

        FirebaseLogger.shared.log("Enviando examen: \(examName) — \(urls.count) archivo(s)")
        FirebaseLogger.shared.setCustomValues([
            "exam_name": examName,
            "files_count": urls.count,
            "tipo_archivo": tipoArchivoPicklist,
            "es_examen_automatizado": esExamenAutomatizado
        ])

        Task {
            let result = await Network.shared.postExams(
                accountId: accountId,
                nombreOrdenPadre: nombreOrdenPadre,
                urls: urls,
                nombresArchivos: nombresArchivos,
                tipoDocumentoPicklist: tipoArchivoPicklist,
                idOrdenExamen: exam?.idOrdenMedicaC ?? "",
                esExamenAutomatizado: esExamenAutomatizado
            )

            await MainActor.run {
                switch result {
                case .success:
                    FirebaseLogger.shared.log("Examen enviado exitosamente: \(examName)")
                    FirebaseLogger.shared.logEvent("exam_submitted_success", attributes: [
                        "exam_name": examName,
                        "files_count": fileExams.filter { !$0.urlImg.isEmpty }.count
                    ])
                    self.isPublished = true
                    self.showConfetti = true
                    presentSuccessModal()
                    ReviewManager.shared.requestReviewIfNeeded()

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
                // Apagar loading SIEMPRE (success o failure) en el hilo principal.
                self.isLoading = false
            }
        }
    }

    var isSendButtonDisabled: Bool {
        // selectedDocumentType es OBLIGATORIO siempre, incluso en fromOrderExam,
        // porque su valor viaja en Campo_11__c (picklist restringido en Salesforce).
        // Si está vacío, el backend rechazaría con INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST.
        fileExams.allSatisfy { $0.imgData.isEmpty }
            || isLoading
            || examName.isEmpty
            || selectedDocumentType.isEmpty
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
            self.selectedDocumentType = exam?.nombreDelExamenC ?? ""
            self.fileExams[0].urlImg = exam?.urlExamen1C ?? ""
            self.fileExams[1].urlImg = exam?.urlExamen2C ?? ""
            self.fileExams[2].urlImg = exam?.urlExamen3C ?? ""
            self.fileExams[3].urlImg = exam?.urlExamen4C ?? ""

            // Extraer extensiones desde las URLs para mostrar el tipo de archivo
            for i in fileExams.indices {
                if !fileExams[i].urlImg.isEmpty {
                    let fileName = S3FileHelper.extractFileNameFromUrl(fileExams[i].urlImg)
                    fileExams[i].archiveExtension = (fileName as NSString).pathExtension
                }
            }
        }
    }

    private func formatDisplayDate(_ dateStr: String, formato: String = "dd/MM/yyyy") -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = formato.isEmpty ? "dd/MM/yyyy" : formato

        // Intentar ISO8601 con fracciones
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateStr) {
            return displayFormatter.string(from: date)
        }
        // Intentar ISO8601 sin fracciones
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateStr) {
            return displayFormatter.string(from: date)
        }
        // Intentar yyyy-MM-dd (formato Salesforce)
        let sfFormatter = DateFormatter()
        sfFormatter.dateFormat = "yyyy-MM-dd"
        if let date = sfFormatter.date(from: dateStr) {
            return displayFormatter.string(from: date)
        }
        return dateStr
    }

    private func downloadAllFiles() {
        let filesWithUrl = fileExams.filter { !$0.urlImg.isEmpty }
        guard let first = filesWithUrl.first else { return }
        downloadArchive(action: .isDownload, urlParameter: first.urlImg)
    }

    private func shareAllFiles() {
        let filesWithUrl = fileExams.filter { !$0.urlImg.isEmpty }
        guard let first = filesWithUrl.first else { return }
        downloadArchive(action: .isShare, urlParameter: first.urlImg)
    }

    private func deleteExamFiles() {
        guard let examId = exam?.Id, !examId.isEmpty else {
            print("❌ [EliminarExamen] No se puede eliminar: exam.Id es nil o vacío")
            showDeleteConfirmation = false
            return
        }

        deletingLoading = true

        Task {
            let result = await Network.shared.deletePatientExam(examId: examId)

            await MainActor.run {
                deletingLoading = false
                showDeleteConfirmation = false
                switch result {
                case .success:
                    FirebaseLogger.shared.log("Examen eliminado exitosamente: \(examName) (id: \(examId))")
                    dismiss()
                    publisher.send()
                case let .failure(error):
                    FirebaseLogger.shared.log("Error al eliminar examen: \(error.localizedDescription)")
                    AppStatusManager.error(error)
                }
            }
        }
    }
}


struct FileExam: Identifiable {
    let id: UUID = UUID()
    var imgData: String = ""
    var urlImg: String = ""
    var archiveExtension: String = ""
    /// Nombre original del archivo (con extensión) tal como lo eligió el usuario.
    /// Se envía al backend en Campo_10__c del nuevo contrato de subida de exámenes.
    var originalFileName: String = ""
}
