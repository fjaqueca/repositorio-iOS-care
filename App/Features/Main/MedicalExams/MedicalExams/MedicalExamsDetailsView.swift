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
    @State var selectedURL: URL?
    @State var alertAuthEvent: AlertAuthEvent?
    @State var isLoading: Bool = false
    @Binding var isLoadingExam: Bool
    @State var urlImg: [String] = []
    @Binding var isFavorite: Bool
    @State private var showWebView = false
    @Binding var UIState: ExamUIState
    // Config dinámica COMPLETA del detalle de prescripción.
    // Viene de Elemento 9 del record `ExamenesAutomatizadosCustom`
    // (VistaDetallePrescripcionesMedicas).
    var vistaDetalle: VistaDetallePrescripcionesConfig = VistaDetallePrescripcionesConfig()
    // Config de la vista "Subir Examen" (Elemento 10 del Custom record).
    // No se consume aquí — solo se reenvía a SendNewExamView.
    var vistaSubir: VistaSubirExamenConfig = VistaSubirExamenConfig()
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogExamenesEnviadosConfig: DialogExamenesEnviadosConfig = DialogExamenesEnviadosConfig()
    var dialogEliminarDocOrdenConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var badgeOrdenMedica: BadgeConfig = BadgeConfig()
    var badgeExamenAutomatizado: BadgeConfig = BadgeConfig()
    var badgeRecetaMedica: BadgeConfig = BadgeConfig()
    /// Binding al MedicalExamsView padre. Lo seteamos a true tras un upload exitoso
    /// para que la lista se refresque al volver.
    @Binding var listNeedsRefresh: Bool
    /// PatientExam asociado calculado por el padre (cruce por FK contra allPatientExams).
    /// Snapshot cacheado del último refresh del padre.
    var linkedPatientExam: FunctionFilterExamResponse.PatientExams? = nil
    /// PatientExam refrescado desde el propio detalle tras un upload exitoso (paridad
    /// con Android `viewExamLauncher → examenesService(idOrden)`). Tiene PRIORIDAD
    /// sobre `linkedPatientExam` cuando está set, porque viene de una consulta
    /// posterior al upload con datos reales del backend.
    @State private var refreshedLinkedExam: FunctionFilterExamResponse.PatientExams? = nil
    /// Optimistic UI: mientras corre `refreshThisExamFromBackend()`, mantenemos el
    /// botón cambiado a "Ver documento enviado". Si la consulta puntual falla, este
    /// flag asegura que la UI no retroceda — la lista padre se reconciliará al volver.
    @State private var optimisticUploaded: Bool = false

    /// Source of truth efectiva para la decisión de UI. Prioridad:
    ///  1. refreshedLinkedExam — consulta puntual post-upload (datos más frescos).
    ///  2. linkedPatientExam — snapshot del padre.
    private var effectiveLinkedExam: FunctionFilterExamResponse.PatientExams? {
        refreshedLinkedExam ?? linkedPatientExam
    }
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
    // Color del icono PDF del bloque "Examen adjunto" — viene de 9.10
    // (ColorIconoExamenAdjunto). Si no hay config, fallback a gris medio.
    private var examenAdjuntoIconoColor: Color {
        let c = vistaDetalle.examenAdjuntoIconoColor
        return Color(hex: c.isEmpty ? "#387FC2" : c)
    }

    /// Decisión de UI del botón "Subir/Ver documento enviado" (paridad con Android).
    /// True si:
    ///  - hay un effectiveLinkedExam (refresh puntual post-upload o snapshot del padre), o
    ///  - el usuario acaba de subir y aún no llegó la respuesta del refresh (optimistic).
    private var isExamPublish: Bool {
        effectiveLinkedExam != nil || optimisticUploaded
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Divider()
                    .onAppear {
                        let csa = vistaSubir.containerSinArchivo
                        let cca = vistaSubir.containerConArchivo
                        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        print("📋 [MedicalExamsDetailsView] vistaSubir RECIBIDO")
                        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        print("   notaTexto: \"\(vistaSubir.notaTexto)\"")
                        print("   [10.7] sinArchivo: borde=\"\(csa.colorBorde)\" icono=\"\(csa.icono)\" colorIcono=\"\(csa.colorIcono)\" fondo=\"\(csa.colorFondoContainer)\"")
                        print("   [10.8] conArchivo: borde=\"\(cca.colorBorde)\" fondoContainer=\"\(cca.colorFondoContainer)\"")
                        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                ScrollView {
                    VStack(spacing: 20) {
                        // Main card
                        VStack(alignment: .leading, spacing: 0) {
                            // Exam name & date (spacing aumentado para respirar
                            // entre título / badge / fecha)
                            VStack(alignment: .leading, spacing: 10) {
                                // 9.4 AtributosTituloCardDetalle
                                Text((exam.Name ?? "Sin nombre").uppercased())
                                    .font(Font.custom(
                                        vistaDetalle.tituloCardAttr.font.isEmpty ? "FiraSans-Bold" : vistaDetalle.tituloCardAttr.font,
                                        size: CGFloat(Int(vistaDetalle.tituloCardAttr.size) ?? 16)
                                    ))
                                    .foregroundColor(Color(hex: vistaDetalle.tituloCardAttr.color.isEmpty ? "#333333" : vistaDetalle.tituloCardAttr.color))
                                    .lineLimit(3)

                                // Badge indicador de tipo de documento (9.5/9.14/9.15)
                                if let tipo = exam.tipoDocumento {
                                    let detalleBadge: BadgeDetalleConfig = {
                                        switch tipo {
                                        case .examenAutomatizado: return vistaDetalle.badgeCreadoPaciente
                                        case .recetaMedica:       return vistaDetalle.badgeRecetaMedica
                                        case .ordenMedica:        return vistaDetalle.badgeExamenMedico
                                        }
                                    }()
                                    let badgeTexto: String = {
                                        if tipo == .ordenMedica {
                                            return detalleBadge.texto.replacingOccurrences(of: "{ProfesionalResponsable}", with: exam.profesionalResponsableR?.Name ?? "")
                                        }
                                        return detalleBadge.texto
                                    }()
                                    HStack(spacing: 6) {
                                        if !detalleBadge.icono.isEmpty {
                                            Image(systemName: detalleBadge.icono)
                                                .font(.system(size: CGFloat(Double(detalleBadge.size) ?? 15)))
                                                .foregroundColor(Color(hex: detalleBadge.colorTexto))
                                        }
                                        Text(badgeTexto)
                                            .font(Font.custom(
                                                detalleBadge.font.isEmpty ? "FiraSans-Regular" : detalleBadge.font,
                                                size: CGFloat(Double(detalleBadge.size) ?? 15)
                                            ))
                                            .foregroundColor(Color(hex: detalleBadge.colorTexto))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(Color(hex: detalleBadge.colorFondo)))
                                }

                                // 9.6 FechaDetallePrescripcion (con icono opcional)
                                if let dateStr = exam.desdeC, !dateStr.isEmpty {
                                    let fechaColor = Color(hex: vistaDetalle.fechaAttr.color.isEmpty ? "#888888" : vistaDetalle.fechaAttr.color)
                                    let fechaSize = CGFloat(Int(vistaDetalle.fechaAttr.size) ?? 13)
                                    let fechaFont = vistaDetalle.fechaAttr.font.isEmpty ? "FiraSans-Regular" : vistaDetalle.fechaAttr.font
                                    let fechaIcono = vistaDetalle.fechaIcono
                                    let fechaIconoColor = Color(hex: vistaDetalle.fechaIconoColor.isEmpty ? "#888888" : vistaDetalle.fechaIconoColor)
                                    HStack(spacing: 4) {
                                        if !fechaIcono.isEmpty {
                                            Image(systemName: fechaIcono)
                                                .font(.system(size: fechaSize))
                                                .foregroundColor(fechaIconoColor)
                                        }
                                        Text(formatDateDisplay(dateStr, outputFormat: vistaDetalle.fechaFormato))
                                            .font(Font.custom(fechaFont, size: fechaSize))
                                            .foregroundColor(fechaColor)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                            Divider()
                                .padding(.horizontal, 16)

                            // Indicaciones (9.7 título + 9.8 texto)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(vistaDetalle.indicacionesTitulo.isEmpty ? "Indicaciones" : vistaDetalle.indicacionesTitulo)
                                    .font(Font.custom(
                                        vistaDetalle.indicacionesTituloAttr.font.isEmpty ? "FiraSans-Bold" : vistaDetalle.indicacionesTituloAttr.font,
                                        size: CGFloat(Int(vistaDetalle.indicacionesTituloAttr.size) ?? 15)
                                    ))
                                    .foregroundColor(Color(hex: vistaDetalle.indicacionesTituloAttr.color.isEmpty ? "#333333" : vistaDetalle.indicacionesTituloAttr.color))
                                    .frame(maxWidth: .infinity, alignment: alignmentFor(vistaDetalle.indicacionesTituloAttr.alignment))

                                Text(exam.descripcionC ?? "Sin descripción")
                                    .font(Font.custom(
                                        vistaDetalle.indicacionesTextoAttr.font.isEmpty ? "FiraSans-Regular" : vistaDetalle.indicacionesTextoAttr.font,
                                        size: CGFloat(Int(vistaDetalle.indicacionesTextoAttr.size) ?? 14)
                                    ))
                                    .foregroundColor(Color(hex: vistaDetalle.indicacionesTextoAttr.color.isEmpty ? "#888888" : vistaDetalle.indicacionesTextoAttr.color))
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 12)

                            Divider()
                                .padding(.horizontal, 16)

                            // Examen adjunto (9.9 título + 9.10 icono)
                            VStack(alignment: .leading, spacing: 10) {
                                Text(vistaDetalle.examenAdjuntoTitulo.isEmpty ? "Examen adjunto" : vistaDetalle.examenAdjuntoTitulo)
                                    .font(Font.custom(
                                        vistaDetalle.examenAdjuntoTituloAttr.font.isEmpty ? "FiraSans-Medium" : vistaDetalle.examenAdjuntoTituloAttr.font,
                                        size: CGFloat(Int(vistaDetalle.examenAdjuntoTituloAttr.size) ?? 14)
                                    ))
                                    .foregroundColor(Color(hex: vistaDetalle.examenAdjuntoTituloAttr.color.isEmpty ? "#333333" : vistaDetalle.examenAdjuntoTituloAttr.color))
                                    .frame(maxWidth: .infinity, alignment: alignmentFor(vistaDetalle.examenAdjuntoTituloAttr.alignment))

                                // Icono PDF — usa exclusivamente la config 9.10
                                // (ColorIconoExamenAdjunto). NO se descarga ninguna
                                // imagen externa porque eso impide aplicar el color
                                // dinámico del record.
                                Button {
                                    downloadArchive(action: .isOpen)
                                } label: {
                                    let iconSize = CGFloat(Int(vistaDetalle.examenAdjuntoIconoSize) ?? 32)
                                    Image(systemName: "doc.richtext")
                                        .font(.system(size: iconSize, weight: .light))
                                        .foregroundColor(examenAdjuntoIconoColor)
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

                    }
                    .padding(.top, 20)
                    .padding(.bottom, .margin)
                }

                // Subir Examen button (oculto para recetas médicas) — fijo al final
                if exam.tipoDocumento != .recetaMedica {
                    subExamButton
                        .padding(.horizontal, .margin)
                        .padding(.vertical, 14)
                }
            }
            .alert(item: $alertAuthEvent, content: { tipe in
                switch tipe {
                case .DownloadSucces:
                    return Alert(title: Text("Descarga Completa"), message: Text("Archivo guardado en la app de Archivos"), dismissButton: .default(Text("OK")))
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
                // 9.2 TituloGeneralDetallePrescripcionesMedicas
                ToolbarItem(placement: .principal) {
                    Text(vistaDetalle.tituloTexto.isEmpty ? "Prescripciones Médicas" : vistaDetalle.tituloTexto)
                        .font(Font.custom(
                            vistaDetalle.tituloAttr.font.isEmpty ? "FiraSans-Bold" : vistaDetalle.tituloAttr.font,
                            size: CGFloat(Int(vistaDetalle.tituloAttr.size) ?? 18)
                        ))
                        .foregroundColor(Color(hex: vistaDetalle.tituloAttr.color.isEmpty ? "#00BBDC" : vistaDetalle.tituloAttr.color))
                }
                // 9.3 IconoEstrella
                ToolbarItem(placement: .navigationBarTrailing) {
                    let estrellaSize = CGFloat(Int(vistaDetalle.iconoEstrellaSize) ?? 18)
                    let estrellaColor = Color(hex: vistaDetalle.iconoEstrellaColor.isEmpty ? "#333333" : vistaDetalle.iconoEstrellaColor)
                    Button(action: {
                        changeFavorite()
                    }) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.system(size: estrellaSize))
                            .foregroundColor(isFavorite ? .yellow : estrellaColor)
                    }
                }
                // 9.1 BackArrow
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: vistaDetalle.backArrowColor.isEmpty ? "#00BBDC" : vistaDetalle.backArrowColor))
                    }
                }
            }
            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App.\n", self.urlToShare as Any])
            })
            .sheet(isPresented: $showWebView) {
                if let urlToShare = self.urlToShare {
                    WebView(url: urlToShare)
                }
            }
            .alert("Examen descargado correctamente", isPresented: $showDownloadSuccessDialog) {
                Button("Aceptar") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showWebView = true
                    }
                }
            } message: {
                Text("Tu examen quedó guardado en la aplicación de archivos")
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
    // MARK: - Subir Examen / Ver documento enviado
    // Botón dual: si la prescripción ya tiene documento adjunto se muestra
    // BotonVerDocumentoEnviado (9.16); si no, BotonSubirExamen (9.13). Ambos
    // vienen del Elemento 9 de ExamenesAutomatizadosCustom.
    private var subExamButton: some View {
        Group {
            if isExamPublish {
                let btn = vistaDetalle.botonVerDocumentoEnviado
                Button {
                    sendNewExam = true
                } label: {
                    Text(btn.texto.isEmpty ? "Ver documento enviado" : btn.texto)
                        .font(Font.custom(
                            btn.font.isEmpty ? "FiraSans-Regular" : btn.font,
                            size: CGFloat(Double(btn.size) ?? 17)
                        ))
                        .foregroundColor(Color(hex: btn.colorTexto.isEmpty ? "#FFFFFF" : btn.colorTexto))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: btn.colorFondo.isEmpty ? "#00BBDC" : btn.colorFondo))
                        )
                }
            } else {
                let btn = vistaDetalle.botonSubirExamen
                Button {
                    sendNewExam = true
                } label: {
                    Text(btn.texto.isEmpty ? "+ Subir Examen" : btn.texto)
                        .font(Font.custom(
                            btn.font.isEmpty ? "FiraSans-Bold" : btn.font,
                            size: CGFloat(Double(btn.size) ?? 16)
                        ))
                        .foregroundColor(Color(hex: btn.colorTexto.isEmpty ? "#FFFFFF" : btn.colorTexto))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: btn.colorFondo.isEmpty ? "#00BBDC" : btn.colorFondo))
                        )
                }
            }
        }
        .onReceive(publisher, perform: { _ in
            // Paridad con Android `viewExamLauncher` callback (UPDATE=true):
            //  1) optimisticUploaded = true → botón cambia INMEDIATO a "Ver documento
            //     enviado" mientras llega la consulta real.
            //  2) listNeedsRefresh = true → cuando user haga back, padre re-consulta
            //     allPatientExams (equivale a fragment.examenesService() en Android).
            //  3) refreshThisExamFromBackend() → consulta puntual de ESTA orden
            //     (equivale a Android `examenesService(idOrden)` en el detalle).
            //     Cuando llega, refreshedLinkedExam tiene URLs reales → si user toca
            //     "Ver documento enviado" YA, abre con datos correctos.
            print("🔄 [ExamDetalle] Upload exitoso recibido — optimistic + refresh puntual + flag padre")
            optimisticUploaded = true
            listNeedsRefresh = true
            Task { await refreshThisExamFromBackend() }
        })
        .navigationLink(isActive: $sendNewExam) {
            if isExamPublish {
                SendNewExamView(UIState: $UIState, vistaSubir: vistaSubir, dialogEliminarConfig: dialogEliminarConfig, dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig, dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig, examName: exam.Name ?? "", isPublished: true, exam: medicExamToPatientExam(), publisher: self.publisher)
            } else {
                SendNewExamView(UIState: $UIState, vistaSubir: vistaSubir, dialogEliminarConfig: dialogEliminarConfig, dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig, dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig, examName: exam.Name ?? "", fromOrderExam: true, exam: medicExamToPatientExam(), publisher: self.publisher)
            }
        }
    }

    // MARK: - Download & Share Buttons (9.11 + 9.12)
    var buttonsBottom: some View {
        HStack(spacing: 12) {
            let btnDesc = vistaDetalle.botonDescargar
            Button {
                downloadArchive(action: .isDownload)
            } label: {
                HStack(spacing: 6) {
                    Text(btnDesc.texto.isEmpty ? "Descargar" : btnDesc.texto)
                        .font(Font.custom(
                            btnDesc.font.isEmpty ? "FiraSans-Medium" : btnDesc.font,
                            size: CGFloat(Int(btnDesc.size) ?? 14)
                        ))
                    if !btnDesc.icono.isEmpty {
                        Image(systemName: btnDesc.icono)
                            .font(.system(size: CGFloat(Int(btnDesc.size) ?? 14), weight: .medium))
                            .foregroundColor(Color(hex: btnDesc.colorIcono.isEmpty ? btnDesc.colorTexto : btnDesc.colorIcono))
                    } else {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(Color(hex: btnDesc.colorTexto.isEmpty ? "#333333" : btnDesc.colorTexto))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: btnDesc.colorFondo.isEmpty ? "#FFFFFF" : btnDesc.colorFondo))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: btnDesc.colorBorde.isEmpty ? "#D1D1D6" : btnDesc.colorBorde), lineWidth: 1)
                )
            }

            let btnComp = vistaDetalle.botonCompartir
            Button {
                downloadArchive(action: .isShare)
            } label: {
                HStack(spacing: 6) {
                    Text(btnComp.texto.isEmpty ? "Compartir" : btnComp.texto)
                        .font(Font.custom(
                            btnComp.font.isEmpty ? "FiraSans-Medium" : btnComp.font,
                            size: CGFloat(Int(btnComp.size) ?? 14)
                        ))
                    if !btnComp.icono.isEmpty {
                        Image(systemName: btnComp.icono)
                            .font(.system(size: CGFloat(Int(btnComp.size) ?? 14), weight: .medium))
                            .foregroundColor(Color(hex: btnComp.colorIcono.isEmpty ? btnComp.colorTexto : btnComp.colorIcono))
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(Color(hex: btnComp.colorTexto.isEmpty ? "#333333" : btnComp.colorTexto))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: btnComp.colorFondo.isEmpty ? "#FFFFFF" : btnComp.colorFondo))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: btnComp.colorBorde.isEmpty ? "#D1D1D6" : btnComp.colorBorde), lineWidth: 1)
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
    func changeFavorite(){
        let data = !isFavorite
        self.isLoading = true
        Task { @MainActor in
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
        // Si tenemos un linked exam (refrescado puntual O snapshot del padre), lo
        // usamos como fuente de verdad. Cubre tanto ordenMedica (idOrdenMedicaC)
        // como examenAutomatizado (idExamenesAutomatizadosC). Si refreshedLinkedExam
        // está set (consulta puntual post-upload), tiene prioridad — sus URLs son
        // las más frescas justo después de subir.
        if let linked = effectiveLinkedExam {
            var p = linked
            p.tipoDocumento = exam.tipoDocumento
            p.nombreOrdenPadre = exam.Name
            return p
        }
        // Fallback (sin linked): construimos un PatientExam vacío a partir de la orden,
        // útil para pasar a SendNewExamView en el flujo de SUBIR (no hay archivos aún).
        var patientExam = FunctionFilterExamResponse.PatientExams(
            attributes: nil,
            pacienteC: exam.pacienteC,
            Id: nil,
            nombreDelExamenC: exam.Name,
            urlExamen1C: exam.url1C,
            urlExamen2C: exam.url2C,
            urlExamen3C: exam.url3C,
            urlExamen4C: exam.url4C,
            comentariosC: exam.comment,
            CreatedDate: exam.desdeC,
            idOrdenMedicaC: exam.Id,
            idExamenesAutomatizadosC: nil,
            tipoArchivoC: nil
        )
        patientExam.tipoDocumento = exam.tipoDocumento
        patientExam.nombreOrdenPadre = exam.Name
        return patientExam
    }

    /// Convierte fecha de formato Salesforce (yyyy-MM-dd) al formato pedido por
    /// el record (9.6 FechaDetallePrescripcion). Default dd-MM-yyyy si no hay config.
    private func formatDateDisplay(_ dateStr: String, outputFormat: String = "dd-MM-yyyy") -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat.isEmpty ? "dd-MM-yyyy" : outputFormat
        if let date = inputFormatter.date(from: dateStr) {
            return outputFormatter.string(from: date)
        }
        return dateStr
    }

    /// Convierte la "Posicion" Salesforce ("Left"/"Center"/"Right") a SwiftUI Alignment.
    private func alignmentFor(_ posicion: String) -> Alignment {
        switch posicion.lowercased() {
        case "center":  return .center
        case "right":   return .trailing
        default:        return .leading
        }
    }

    /// Consulta puntual al backend para refrescar el PatientExam asociado a ESTA orden,
    /// disparada justo después de un upload exitoso (paridad con Android
    /// `examenesService(idOrden)` en el callback de `viewExamLauncher`).
    ///
    /// El cruce por FK se hace según el tipo de documento padre:
    ///  - examenAutomatizado → idExamenesAutomatizadosC
    ///  - resto              → idOrdenMedicaC
    ///
    /// Si la consulta falla o no encuentra match, el botón se mantiene cambiado
    /// gracias a `optimisticUploaded`. La lista padre reconciliará al hacer back.
    func refreshThisExamFromBackend() async {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
        guard !accountId.isEmpty, let examId = exam.Id, !examId.isEmpty else {
            print("⚠️ [ExamDetalle] refreshThisExamFromBackend abortado: accountId o exam.Id vacíos")
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔄 [ExamDetalle] refreshThisExamFromBackend (paridad Android examenesService)")
        print("   exam.Id: \(examId)")
        print("   exam.tipoDocumento: \(String(describing: exam.tipoDocumento))")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result = await Network.shared.getExamsForPatient(accountId: accountId)
        switch result {
        case .success(let response):
            let all = response.data?.first?.examenesDelPacienteC ?? []
            // Cruce por FK según tipo (mismo criterio que linkedPatientExam(for:) del padre).
            let match: FunctionFilterExamResponse.PatientExams?
            if exam.tipoDocumento == .examenAutomatizado {
                match = all.first { $0.idExamenesAutomatizadosC == examId }
            } else {
                match = all.first { $0.idOrdenMedicaC == examId }
            }
            await MainActor.run {
                if let m = match {
                    refreshedLinkedExam = m
                    print("✅ [ExamDetalle] refreshedLinkedExam set — id=\(m.Id ?? "nil") urls=[\((m.urlExamen1C ?? "").prefix(40)), \((m.urlExamen2C ?? "").prefix(40))]")
                } else {
                    print("⚠️ [ExamDetalle] No se encontró PatientExam matcheando \(examId) (optimisticUploaded mantiene el botón)")
                }
            }
        case .failure(let error):
            print("❌ [ExamDetalle] refreshThisExamFromBackend error: \(error.name) - \(error.message) (optimisticUploaded mantiene el botón)")
        }
    }
}
