//
//  PatientExamsView.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage

struct PatientExamsView: View {
    @Binding var UIState: ExamUIState
    // Config completa de la vista — Elemento 12 del record ExamenesAutomatizadosCustom.
    // Toda la UI dinámica (título, back arrow, badges, búsqueda, fecha, empty
    // state, botón Subir, ícono basura, barra vertical) viene de este struct.
    var vistaMisArchivos: VistaMisArchivosConfig = VistaMisArchivosConfig()
    // Config del DETALLE (al tocar una card) — Elemento 8. Se reenvía a SendNewExamView.
    var vistaDetalleMisArchivos: VistaDetalleMisArchivosConfig = VistaDetalleMisArchivosConfig()
    var botonesDetalleExamen: BotonesDetalleExamenConfig = BotonesDetalleExamenConfig()
    var badgeCargadoPorPaciente: BadgeDetalleConfig = BadgeDetalleConfig(texto: "Cargado por el Paciente", colorTexto: "#FFFFFF", colorFondo: "#7B61FF", font: "FiraSans-Medium", size: "11", icono: "person.fill")
    var dialogEliminarConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogExamenesEnviadosConfig: DialogExamenesEnviadosConfig = DialogExamenesEnviadosConfig()
    var dialogEliminarDocOrdenConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    var dialogEliminarMiArchivoConfig: DialogEliminarExamenConfig = DialogEliminarExamenConfig()
    // Config de la vista "Subir Examen" (Elemento 10 del Custom record).
    // Se reenvía a SendNewExamView al tocar "+ Subir Examen".
    var vistaSubir: VistaSubirExamenConfig = VistaSubirExamenConfig()
    var accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
    @State var filterExams: String = ""
    @State private var isLoading: Bool = true
    /// Todos los exámenes del servicio (sin filtrar)
    @State var allExams: [FunctionFilterExamResponse.PatientExams] = []
    /// Exámenes visibles (filtrados o todos)
    @State var exams: [FunctionFilterExamResponse.PatientExams] = []
    @State private var sendNewExam = false
    @State private var deleteConfirmExamId: String? = nil
    @State private var deletingLoading: Bool = false
    @State private var emptyStateReady: Bool = false

    // Filter states
    @State private var showFilterView: Bool = false
    @State private var dateFrom: Date? = nil
    @State private var dateUntil: Date? = nil
    @State private var selectedDocumentType: String = ""

    private let patientDocTypes = [
        "Todos",
        "Examen de Laboratorio",
        "Examen de Imagen",
        "Receta Médica",
        "Orden de Exámenes",
        "Informe Médico",
        "Otros"
    ]

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    private var hasActiveFilters: Bool {
        dateFrom != nil || dateUntil != nil || !selectedDocumentType.isEmpty
    }

    var body: some View {
        ZStack {
        VStack(spacing: 0) {
            // Search bar
            searchBar
                .padding(.horizontal, .margin)
                .padding(.top, 21)

            // Badge "Limpiar filtros"
            if hasActiveFilters {
                HStack {
                    Spacer()
                    Button {
                        clearAllFilters()
                    } label: {
                        Text("Limpiar filtros")
                            .font(Font.custom("FiraSans-Medium", size: 12))
                            .foregroundColor(Color(hex: "#00BBDC"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "#00BBDC"), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
                .padding(.horizontal, .margin)
                .padding(.top, 10)
            }

            // Exam list
            ScrollView {
                if isLoading {
                    SkeletonList(rows: 4)
                        .padding(.top, 30)
                } else {
                    if let searchExams = searchExams, !searchExams.isEmpty {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(searchExams.enumerated()), id: \.element) { index, exam in
                                PatientExamRowView(
                                    exam: exam,
                                    isLoadingExam: $isLoading,
                                    UIState: $UIState,
                                    vistaMisArchivos: vistaMisArchivos,
                                    vistaDetalleMisArchivos: vistaDetalleMisArchivos,
                                    botonesDetalleExamen: botonesDetalleExamen,
                                    badgeCargadoPorPaciente: badgeCargadoPorPaciente,
                                    dialogEliminarConfig: dialogEliminarConfig,
                                    dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig,
                                    dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig,
                                    vistaSubir: vistaSubir,
                                    onDelete: { examId in
                                        deleteConfirmExamId = examId
                                    }
                                )
                                .pressable()
                                .springOnAppear(delay: Double(index) * 0.05)
                            }
                        }
                        .padding(.horizontal, .margin)
                        .padding(.top, 23)
                        .padding(.bottom, .margin)
                    } else {
                        // Empty state — texto, font, size y color vienen del 12.14
                        let emptyText = vistaMisArchivos.emptyStateTexto.isEmpty
                            ? "No se encontraron exámenes"
                            : vistaMisArchivos.emptyStateTexto
                        let emptyFont = vistaMisArchivos.emptyStateAttr.font.isEmpty
                            ? "FiraSans-Bold"
                            : vistaMisArchivos.emptyStateAttr.font
                        let emptySize = CGFloat(Int(vistaMisArchivos.emptyStateAttr.size) ?? 19)
                        let emptyColor = Color(hex: vistaMisArchivos.emptyStateAttr.color.isEmpty
                            ? "#5B6770"
                            : vistaMisArchivos.emptyStateAttr.color)
                        VStack(spacing: 12) {
                            Spacer()
                            // TEMPORAL: Lottie Empty_Box deshabilitado, se restaura icono SF Symbol.
                            // Para reactivar, comenta el Image y descomenta el LottieView.
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(Color(.systemGray3))
                            // LottieView(animationName: "Empty_Box")
                            //     .frame(width: 220, height: 220)
                            if emptyStateReady {
                                TypewriterText(emptyText,
                                              font: emptyFont, size: emptySize,
                                              color: emptyColor,
                                              speed: 0.06, showDots: false, delay: 0.3)
                                if !filterExams.isEmpty || hasActiveFilters {
                                    TypewriterText("Intenta con otro término de búsqueda o ajusta los filtros",
                                                  font: "FiraSans-Regular", size: 13,
                                                  color: Color(hex: "#C4C4C4"),
                                                  speed: 0.04, showDots: true, delay: 1.5)
                                }
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .popIn()
                        .onAppear {
                            emptyStateReady = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                emptyStateReady = true
                            }
                        }
                    }
                }
            }

            // Upload exam button
            uploadButton
                .padding(.horizontal, .margin)
                .padding(.vertical, 16)
        }
        .blur(radius: (deleteConfirmExamId != nil || showFilterView) ? 3 : 0.000001)
        .onAppear {
            getExamsForPatient()
        }
        .navigationLink(isActive: $sendNewExam) {
            SendNewExamView(UIState: $UIState, vistaSubir: vistaSubir, dialogEliminarConfig: dialogEliminarConfig, dialogExamenesEnviadosConfig: dialogExamenesEnviadosConfig, dialogEliminarDocOrdenConfig: dialogEliminarDocOrdenConfig, isPublished: false, exam: nil)
        }
        .background(
            Group {
                if UIState.examList.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: UIState.examList.imageBackground),
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

        // Modal de confirmación de eliminación (usa config específica de Custom2 Elem 3)
        if deleteConfirmExamId != nil {
            ExamDeleteConfirmationModal(
                onConfirm: {
                    deletePatientExam()
                },
                onCancel: {
                    deleteConfirmExamId = nil
                },
                isLoading: deletingLoading,
                config: dialogEliminarMiArchivoConfig
            )
            .zIndex(50)
            .transition(.opacity)
        }

        // Modal de filtro
        if showFilterView {
            PrescriptionFilter(
                dateFrom: $dateFrom,
                dateUntil: $dateUntil,
                showFilterView: $showFilterView,
                selectedDocumentType: $selectedDocumentType,
                onApplyWithDates: { from, until in
                    applyFilter()
                },
                onClear: {
                    clearAllFilters()
                },
                UIState: UIState.examFilter,
                documentTypes: patientDocTypes
            )
            .zIndex(40)
            .transition(.opacity)
        }
        } // ZStack
    }

    // MARK: - Search Bar
    // 12.11 TextoPlaceholderFiltro + 12.12 IconoFiltro
    private var searchBar: some View {
        let phText = vistaMisArchivos.placeholderTexto.isEmpty
            ? "Buscar mis exámenes..."
            : vistaMisArchivos.placeholderTexto
        let phFont = vistaMisArchivos.placeholderAttr.font.isEmpty
            ? "FiraSans-Regular"
            : vistaMisArchivos.placeholderAttr.font
        let phSize = CGFloat(Int(vistaMisArchivos.placeholderAttr.size) ?? 15)
        let phColor = Color(hex: vistaMisArchivos.placeholderAttr.color.isEmpty
            ? "#5B6770"
            : vistaMisArchivos.placeholderAttr.color)

        let filterIcon = vistaMisArchivos.iconoFiltro.isEmpty
            ? "line.3.horizontal.decrease"
            : vistaMisArchivos.iconoFiltro
        let filterIconSize = CGFloat(Int(vistaMisArchivos.iconoFiltroSize) ?? 16)
        let filterIconColor = Color(hex: vistaMisArchivos.iconoFiltroColor.isEmpty
            ? "#00BBDC"
            : vistaMisArchivos.iconoFiltroColor)

        return HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .frame(width: 20, height: 20)

            TextField("", text: $filterExams, prompt:
                Text(phText)
                    .font(Font.custom(phFont, size: phSize))
                    .foregroundColor(phColor)
            )
                .font(Font.custom(phFont, size: phSize))

            if !filterExams.isEmpty {
                Button {
                    filterExams = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }

            Button {
                withAnimation { showFilterView.toggle() }
            } label: {
                Image(systemName: filterIcon)
                    .font(.system(size: filterIconSize, weight: .medium))
                    .foregroundColor(filterIconColor)
                    .frame(width: 32, height: 32)
                    .background(Color.grayLight.opacity(0.5))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }

    // MARK: - Upload Button
    // 12.16 BotonSubirExamen(Texto;ColorTexto;ColorFondo;TipoFuente;Size)
    private var uploadButton: some View {
        let cfg = vistaMisArchivos.botonSubirExamen
        let btnText = cfg.texto.isEmpty ? "+ Subir Examen" : cfg.texto
        let btnColorTexto = cfg.colorTexto.isEmpty ? "#FFFFFF" : cfg.colorTexto
        let btnColorFondo = cfg.colorFondo.isEmpty ? "#00BBDC" : cfg.colorFondo
        let btnFont = cfg.font.isEmpty ? "FiraSans-Medium" : cfg.font
        let btnSize = Double(cfg.size) ?? 15

        return Button {
            HapticManager.impact(style: .medium)
            sendNewExam = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 14, weight: .medium))
                Text(btnText)
                    .font(Font.custom(btnFont, size: btnSize))
            }
            .foregroundColor(Color(hex: btnColorTexto))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: btnColorFondo))
            )
        }
        .bounceOnTap()
    }

    // MARK: - Computed
    var searchExams: [FunctionFilterExamResponse.PatientExams]? {
        if filterExams.isEmpty {
            return exams
        } else {
            return exams.filter { $0.nombreDelExamenC?.localizedCaseInsensitiveContains(filterExams) ?? false }
        }
    }

    // MARK: - Filter Functions

    /// Aplica filtro local por tipo de documento + fechas sobre allExams
    func applyFilter() {
        var results = allExams
        let totalBefore = results.count

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 [MisExamenes] APLICAR FILTRO (local, sin servicio)")
        print("   Total antes de filtrar: \(totalBefore)")
        print("   selectedDocumentType: \"\(selectedDocumentType.isEmpty ? "(Todos)" : selectedDocumentType)\"")
        print("   dateFrom: \(dateFrom != nil ? "\(dateFrom!)" : "nil")")
        print("   dateUntil: \(dateUntil != nil ? "\(dateUntil!)" : "nil")")

        // Filtro por tipo de documento (Tipo_de_Archivo__c)
        if !selectedDocumentType.isEmpty {
            let before = results.count
            if selectedDocumentType == "Otros" {
                // "Otros" = tipo vacío o no coincide con los 5 conocidos
                let knownTypes = ["Examen de Laboratorio", "Examen de Imagen", "Receta Médica", "Orden de Exámenes", "Informe Médico"]
                results = results.filter { exam in
                    let tipo = exam.tipoArchivoC ?? ""
                    return tipo.isEmpty || !knownTypes.contains(tipo)
                }
            } else {
                results = results.filter { ($0.tipoArchivoC ?? "") == selectedDocumentType }
            }
            print("   📄 Filtro tipo \"\(selectedDocumentType)\": \(before) → \(results.count)")
        }

        // Filtro por rango de fechas (CreatedDate en ISO8601)
        if let from = dateFrom, let until = dateUntil {
            let before = results.count
            let calendar = Calendar.current
            let fromStart = calendar.startOfDay(for: from)
            let untilEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: until)) ?? until

            results = results.filter { exam in
                guard let dateStr = exam.CreatedDate, !dateStr.isEmpty else { return true }
                if let date = formatter.date(from: dateStr) {
                    return date >= fromStart && date < untilEnd
                }
                return true
            }
            print("   📅 Filtro fechas: \(before) → \(results.count)")
        }

        exams = results
        print("   ✅ Resultado final: \(results.count) de \(totalBefore)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    /// Limpia todos los filtros y restaura la lista completa
    func clearAllFilters() {
        print("🧹 [MisExamenes] LIMPIAR TODOS LOS FILTROS")
        dateFrom = nil
        dateUntil = nil
        selectedDocumentType = ""
        exams = allExams
    }

    // MARK: - Service Functions
    func deletePatientExam() {
        guard let examId = deleteConfirmExamId, !examId.isEmpty else { return }
        deletingLoading = true

        Task {
            let result = await Network.shared.deletePatientExam(examId: examId)

            await MainActor.run {
                deletingLoading = false
                deleteConfirmExamId = nil
                switch result {
                case .success:
                    print("🗑️ [MisExamenes] Examen eliminado exitosamente — id: \(examId)")
                    getExamsForPatient()
                case let .failure(error):
                    print("❌ [MisExamenes] Error al eliminar examen: \(error.name) - \(error.message)")
                    AppStatusManager.error(error)
                }
            }
        }
    }

    func getExamsForPatient() {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [MisExamenes] INICIO - getExamsForPatient()")
        print("   accountId: \"\(accountId)\"")
        if accountId.isEmpty {
            print("   ⚠️ account_id está vacío en UserDefaults — no se puede consultar")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        self.isLoading = true
        Task {
            let result = await Network.shared.getExamsForPatient(accountId: accountId)
            await MainActor.run {
                self.isLoading = false
                switch result {
                case .success(let listExam):
                    let records = listExam.data?.first?.examenesDelPacienteC ?? []
                    print("✅ [MisExamenes] Servicio OK - statusCode: \(listExam.statusCode ?? -1)")
                    print("   Exámenes recibidos: \(records.count)")
                    for (i, exam) in records.enumerated() {
                        print("   [\(i)] Id=\(exam.Id ?? "") Nombre=\"\(exam.nombreDelExamenC ?? "")\" Tipo=\"\(exam.tipoArchivoC ?? "")\" Fecha=\(exam.CreatedDate ?? "")")
                    }
                    let sorted = records.sorted(by: { $0.CreatedDate ?? "" > $1.CreatedDate ?? "" })
                    self.allExams = sorted
                    // Si hay filtros activos, re-aplicar sobre los nuevos datos
                    if self.hasActiveFilters {
                        self.applyFilter()
                    } else {
                        self.exams = sorted
                    }
                    print("   Exámenes visibles: \(self.exams.count)")
                case let .failure(error):
                    print("❌ [MisExamenes] Error: \(error.name) - \(error.message)")
                    AppStatusManager.error(error)
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }
        }
    }
}
