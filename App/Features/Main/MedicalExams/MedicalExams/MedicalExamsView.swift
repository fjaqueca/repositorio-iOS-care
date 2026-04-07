//
//  MedicalExamsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 20/03/2023.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import ZIPFoundation

struct MedicalExamsView: View {
    @Binding var UIState: ExamUIState
    var backArrowColor: String = "#00BBDC"
    var seleccionarTodosTexto: String = "Seleccionar Todos"
    var seleccionarTodosAttr: TextExamAttributes = TextExamAttributes()
    var accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
    @State var from: String = ""
    @State var until: String = ""
    @State var dateFrom: Date = Date().adding(days: -180)
    @State var dateUntil: Date = .now
    @State var filterExams: String = ""
    @State var total: Double = 1
    @State var count: Double = 0
    @State var progress: Double = 0.0
    @State var isCurrent: Bool = true
    @State private var isLoading: Bool = true
    @State var isLoadingAction: Bool = false
    @State var exams: MedicalExams? = nil
    @State private var showDismissButton: Bool = true
    @State var showFilterView: Bool = false
    @State var showAlert: Bool = false
    @State private var isButtonDownloadEnable: Bool = false
    @State private var isButtonShareEnable: Bool = false
    @State private var isButtonSelectAllFilled: Bool = false
    @State var examSelectedList: [String: Bool] = [:]
    @State var actionButton: ActionAuthPresAndExam?
    @State var showSheetView: Bool = false
    @State var isLoadingFav: Bool = false
    @State private var urlsToZip: [URL] = []
    @State var urlShare: URL?
    @State private var showWebView = false
    @State private var downloadedFileURL: URL?

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    private var selectedCount: Int {
        examSelectedList.values.filter { $0 }.count
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding(.horizontal, .margin)
                    .padding(.top, 21)

                // Select all row (always visible)
                selectAllRow
                    .padding(.horizontal, .margin)
                    .padding(.top, 23)

                // Action buttons + counter (only visible when there's a selection)
                if selectedCount > 0 {
                    actionButtonsRow
                        .padding(.horizontal, .margin)
                        .padding(.top, 19)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Hidden onAppear trigger
                Color.clear
                    .frame(height: 0)
                    .onAppear {
                        dateToString()
                        getRecetas()
                    }

                // Exam list
                ScrollView {
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.1)
                            Text("Cargando exámenes...")
                                .font(Font.custom("FiraSans-Regular", size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    } else {
                        if let searchExams = searchExams, !searchExams.isEmpty {
                            LazyVStack(spacing: 10) {
                                ForEach(searchExams, id: \.self) { exam in
                                    MedicalExamsRowView(
                                        isSelected: $examSelectedList,
                                        exam: exam,
                                        isLoadingFavorite: $isLoadingFav,
                                        isLoadingExam: $isLoading,
                                        UIState: $UIState,
                                        backArrowColor: backArrowColor
                                    )
                                }
                            }
                            .padding(.horizontal, .margin)
                            .padding(.top, 23)
                            .padding(.bottom, .margin)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.35))
                                Text("No se encontraron exámenes")
                                    .font(Font.custom("FiraSans-Regular", size: 16))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                        }
                    }
                }
            }

            .sheet(isPresented: $showSheetView, content: {
                ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.examList.textToShare).\n", self.urlShare as Any])
            })
            .sheet(isPresented: $showWebView) {
                if let fileURL = downloadedFileURL {
                    WebView(url: fileURL)
                }
            }
            .onChange(of: count) { newCount in
                print("📊 [ExamList] onChange count: \(newCount)/\(total), isLoadingAction: \(isLoadingAction), actionButton: \(String(describing: actionButton))")
                if newCount >= total && total > 0 && isLoadingAction {
                    print("✅ [ExamList] Descarga completa, esperando 0.8s para cerrar dialog...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        print("📊 [ExamList] Cerrando dialog. actionButton: \(String(describing: actionButton)), downloadedFileURL: \(String(describing: downloadedFileURL))")
                        isLoadingAction = false
                        if actionButton == .isShare {
                            print("📊 [ExamList] Accion: Share -> creando ZIP...")
                            if let zipURL = createZip(from: urlsToZip, zipFileName: "DocumentosCompartidos") {
                                urlShare = zipURL
                                showSheetView = true
                            }
                        } else if actionButton == .isDownload {
                            print("📊 [ExamList] Accion: Download -> abriendo WebView. fileURL: \(String(describing: downloadedFileURL))")
                            if downloadedFileURL != nil {
                                showWebView = true
                                print("✅ [ExamList] showWebView = true")
                            } else {
                                print("❌ [ExamList] downloadedFileURL es nil, no se puede abrir WebView")
                            }
                        } else {
                            print("⚠️ [ExamList] actionButton es nil o desconocido: \(String(describing: actionButton))")
                        }
                    }
                }
            }
            .blur(radius: showFilterView || isLoadingAction || isLoadingFav ? 3 : 0.000001)

            if showFilterView {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showFilterView = false }
                    }
                withAnimation {
                    PrescriptionFilter(dateFrom: $dateFrom, dateUntil: $dateUntil, isCurrent: $isCurrent, showFilterView: $showFilterView, isLoading: $isLoading, UIState: UIState.examFilter)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                        .padding(.horizontal, 24)
                }
            }
            if isLoadingAction {
                withAnimation {
                    PrescriptionDownloadView(total: $total, count: $count)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                        .padding(.horizontal, 24)
                }
            }
            if isLoadingFav {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
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
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .frame(width: 20, height: 20)

            TextField("Buscar exámenes médicos", text: $filterExams)
                .font(Font.custom("FiraSans-Regular", size: 15))

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
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(accentColor)
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

    // MARK: - Select All Row
    private var selectAllRow: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    checkSelectedList()
                }
            } label: {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isButtonSelectAllFilled ? accentColor : Color.gray.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 20, height: 20)
                        if isButtonSelectAllFilled {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(accentColor)
                                .frame(width: 20, height: 20)
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    Text(seleccionarTodosTexto)
                        .font(Font.custom(
                            seleccionarTodosAttr.font.isEmpty ? "FiraSans-Regular" : seleccionarTodosAttr.font,
                            size: CGFloat(Int(seleccionarTodosAttr.size) ?? 14)
                        ))
                        .foregroundColor(seleccionarTodosAttr.color.isEmpty ? .primary : Color(hex: seleccionarTodosAttr.color))
                }
            }
            .buttonStyle(.plain)
            .onChange(of: examSelectedList) { newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    let hasUnselected = newValue.contains { !$0.value }
                    isButtonSelectAllFilled = !hasUnselected && !newValue.isEmpty
                    let hasSelected = newValue.contains { $0.value }
                    isButtonShareEnable = hasSelected
                    isButtonDownloadEnable = hasSelected
                }
            }

            Spacer()
        }
    }

    // MARK: - Action Buttons (visible only when selectedCount > 0)
    private var actionButtonsRow: some View {
        VStack(spacing: 8) {
            // Counter
            HStack {
                Spacer()
                Text("\(selectedCount) seleccionada\(selectedCount == 1 ? "" : "s")")
                    .font(Font.custom("FiraSans-Regular", size: 13))
                    .foregroundColor(.gray)
            }

            HStack(spacing: 10) {
                // Descargar
                Button {
                    self.isLoadingAction = true
                    actionButton = .isDownload
                    filterIsSelected()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 13, weight: .medium))
                        Text(UIState.examList.btnDownload.textBtn.isEmpty ? "Descargar" : UIState.examList.btnDownload.textBtn)
                            .font(Font.custom("FiraSans-Medium", size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accentColor)
                    )
                }

                // Compartir
            Button {
                self.isLoadingAction = true
                actionButton = .isShare
                filterIsSelected()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .medium))
                    Text(UIState.examList.btnShare.textBtn.isEmpty ? "Compartir" : UIState.examList.btnShare.textBtn)
                        .font(Font.custom("FiraSans-Medium", size: 14))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor)
                )
            }
            }
        }
    }

    // MARK: - Computed
    var searchExams: [MedicalExams.Exam]? {
        let records: [MedicalExams.Exam]?
        if filterExams.isEmpty {
            records = exams?.records
        } else {
            records = exams?.records.filter { $0.Name?.localizedCaseInsensitiveContains(filterExams) ?? false }
        }
        // Ordenamiento 3 criterios (igual que Android):
        // 1. Favoritos primero (desc)
        // 2. Fecha desdeC descendente (mas reciente primero)
        // 3. Numero extraido del Name con regex _(\d+)\.pdf$ descendente (desempate)
        return records?.sorted { a, b in
            let favA = a.favoritoAppC ?? false
            let favB = b.favoritoAppC ?? false
            if favA != favB { return favA }
            let dateA = a.desdeC ?? ""
            let dateB = b.desdeC ?? ""
            if dateA != dateB { return dateA > dateB }
            return extractOrderNumber(from: a.Name) > extractOrderNumber(from: b.Name)
        }
    }

    /// Extrae el numero de orden del Name con regex _(\d+)\.pdf$ para desempate en ordenamiento
    private func extractOrderNumber(from name: String?) -> Int {
        guard let name = name else { return 0 }
        let pattern = "_(\\d+)\\.pdf$"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)),
              let range = Range(match.range(at: 1), in: name) else { return 0 }
        return Int(name[range]) ?? 0
    }

    // MARK: - Functions
    func dateToString() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.from = formatter.string(from: dateFrom)
        self.until = formatter.string(from: dateUntil)
    }
    func stringToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return date
        } else {
            return Date().adding(days: +1)
        }
    }
    func getRecetas() {
        self.isLoading = true
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [OrdenesExamen] INICIO - getRecetas()")
        print("   accountId: \(accountId)")
        print("   from: \(from) until: \(until)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Task {
            // Servicio 1: Ordenes basicas (GET /get_examenes_r1)
            let result = await Network.shared.getExams(accountId: accountId, from: from, until: until)
            switch result {
            case let .success(listExams):
                self.exams = listExams
                print("✅ [OrdenesExamen] Servicio 1 OK - ordenes basicas: \(listExams.records.count)")
                if let exams = exams {
                    for exam in exams.records {
                        examSelectedList[exam.Id ?? ""] = false
                    }
                }

                // Servicio 2: Ordenes automatizadas (POST /function_filter → Examenes_Automatizados__c)
                await getAutomatedExamOrders()

                // Servicio 3: Mis Examenes del paciente (merge URLs)
                getExamsForPatient()
            case let .failure(error):
                AppStatusManager.error(error)
                self.isLoading = false
            }
        }
    }

    /// Servicio 2: Obtiene ordenes de examenes automatizados y las combina con las basicas
    func getAutomatedExamOrders() async {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [OrdenesExamen] Servicio 2 - getAutomatedExamOrders()")
        print("   accountId: \(accountId)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let result = await Network.shared.getAutomatedExamOrders(accountId: accountId)
        switch result {
        case .success(let response):
            guard let autoRecords = response.data?.first?.examenesAutomatizadosC, !autoRecords.isEmpty else {
                print("⚠️ [OrdenesExamen] Servicio 2 - sin registros automatizados")
                return
            }

            let existingIds = Set(exams?.records.map { $0.Id ?? "" } ?? [])
            var addedCount = 0
            var skippedCount = 0

            for record in autoRecords {
                // Deduplicar por Id
                if let id = record.Id, existingIds.contains(id) {
                    skippedCount += 1
                    print("   ⏭️ Duplicado, omitiendo Id=\(id)")
                    continue
                }

                // Convertir CreatedDate ISO 8601 (2026-03-20T14:30:00.000Z) a yyyy-MM-dd
                let desdeC = convertISODateToYMD(record.CreatedDate)

                // Convertir a MedicalExams.Exam
                // Name: usar Nombre_Examen__c como nombre visible (Name es solo codigo "EA-000XXX")
                let autoExam = MedicalExams.Exam(
                    attributes: nil,
                    examenMedicoR: nil,
                    profesionalResponsableR: nil,
                    etapaR: nil,
                    Id: record.Id,
                    Name: record.nombreExamenC ?? record.Name,
                    desdeC: desdeC,
                    hastaC: desdeC,
                    etapaC: nil,
                    actividadC: nil,
                    especialidadDelResponsableC: nil,
                    pacienteC: accountId,
                    favoritoAppC: false,
                    urlDeLaOrdenMedicaC: record.urlOrdenMedicaRealC,
                    descripcionC: record.descripcionC ?? "",
                    url1C: nil,
                    url2C: nil,
                    url3C: nil,
                    url4C: nil,
                    comment: nil
                )

                exams?.records.append(autoExam)
                examSelectedList[record.Id ?? ""] = false
                addedCount += 1
            }

            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("📋 [OrdenesExamen] Servicio 2 COMPLETADO")
            print("   Total automatizados recibidos: \(autoRecords.count)")
            print("   Agregados: \(addedCount)")
            print("   Duplicados omitidos: \(skippedCount)")
            print("   Total ordenes combinadas: \(exams?.records.count ?? 0)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        case .failure(let error):
            print("⚠️ [OrdenesExamen] Servicio 2 ERROR: \(error.name) - \(error.message)")
            print("   (continuamos con ordenes basicas solamente)")
        }
    }

    /// Convierte fecha ISO 8601 (2026-03-20T14:30:00.000Z) a formato yyyy-MM-dd
    private func convertISODateToYMD(_ isoDate: String?) -> String {
        guard let isoDate = isoDate, !isoDate.isEmpty else { return "" }
        // Intentar parsear con formato ISO 8601
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: isoDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"
            return outputFormatter.string(from: date)
        }
        // Fallback: si ya viene en yyyy-MM-dd, retornar tal cual
        if isoDate.count >= 10 {
            return String(isoDate.prefix(10))
        }
        return isoDate
    }
    func checkSelectedList() {
        if let searchExams = searchExams {
            if examSelectedList.contains(where: { !$0.value }) {
                for exam in searchExams {
                    examSelectedList[exam.Id ?? ""] = true
                }
                isButtonSelectAllFilled = true
            } else {
                for exam in searchExams {
                    examSelectedList[exam.Id ?? ""] = false
                }
                isButtonSelectAllFilled = false
            }
        }
    }
    func filterIsSelected() {
        self.urlsToZip = []
        self.total = 0.0
        self.count = 0.0
        self.progress = 0.0
        self.downloadedFileURL = nil
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 [ExamList] filterIsSelected -> actionButton: \(String(describing: actionButton))")
        if let exams = exams {
            if examSelectedList.contains(where: { $0.value }) {
                for exam in exams.records {
                    if examSelectedList[exam.Id ?? ""] ?? false {
                        self.total += 1
                    }
                }
            }
            print("📥 [ExamList] Total archivos a descargar: \(Int(total))")
            if examSelectedList.contains(where: { $0.value }) {
                for exam in exams.records {
                    if examSelectedList[exam.Id ?? ""] ?? false {
                        let url = exam.urlDeLaOrdenMedicaC ?? ""
                        print("📥 [ExamList] Descargando: \(url.suffix(40))...")
                        if actionButton == .isDownload {
                            downloadArchive(urlParameter: url, action: .isDownload)
                        }
                        if actionButton == .isShare {
                            downloadArchive(urlParameter: url, action: .isShare)
                        }
                    }
                }
                // NO resetear actionButton aqui, se necesita en onChange
                print("📥 [ExamList] Todas las descargas iniciadas. actionButton se mantiene: \(String(describing: actionButton))")
            }
        }
    }
    func downloadArchive(urlParameter: String?, action: ActionAuthPresAndExam) {
        guard let rawUrl = urlParameter, !rawUrl.isEmpty else {
            print("❌ [ExamList] downloadArchive: URL vacia, abortando")
            return
        }
        let fileName = S3FileHelper.extractFileNameFromUrl(rawUrl)
        let objectKey = S3FileHelper.extractObjectKeyFromUrl(rawUrl)
        print("📥 [ExamList] downloadArchive -> fileName: \(fileName), objectKey: \(objectKey)")

        Task {
            print("📥 [ExamList] Llamando getPresignedUrl...")
            let result = await Network.shared.getPresignedUrl(objectKey: objectKey, filename: fileName)
            switch result {
            case let .success(response):
                print("📥 [ExamList] getPresignedUrl response -> error: \(response.error), url: \(response.url?.prefix(60) ?? "nil")")
                guard let presignedUrl = response.url, !response.error,
                      let remoteURL = URL(string: presignedUrl) else {
                    print("❌ [ExamList] Respuesta invalida o con error")
                    self.count += 1
                    self.progress = Double(self.count / self.total)
                    return
                }
                print("📥 [ExamList] Descargando desde presigned URL...")
                downloadFromPresignedUrl(remoteURL, fileName: fileName, action: action)
            case let .failure(error):
                print("❌ [ExamList] Error getPresignedUrl: \(error.message)")
                self.count += 1
                self.progress = Double(self.count / self.total)
            }
        }
    }

    func downloadFromPresignedUrl(_ remoteURL: URL, fileName: String, action: ActionAuthPresAndExam) {
        print("📥 [ExamList] downloadFromPresignedUrl -> fileName: \(fileName), action: \(action)")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("📥 [ExamList] Descargando bytes desde: \(remoteURL.absoluteString.prefix(60))...")
                let data = try Data(contentsOf: remoteURL)
                print("📥 [ExamList] Bytes recibidos: \(data.count)")
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
                let safeFileName = S3FileHelper.sanitizeFileName(fileName)
                let fileURL = documentsURL.appendingPathComponent(safeFileName)
                try data.write(to: fileURL, options: .atomic)
                print("✅ [ExamList] Archivo guardado: \(fileURL.path)")

                DispatchQueue.main.async {
                    if action == .isDownload {
                        self.downloadedFileURL = fileURL
                        print("📥 [ExamList] downloadedFileURL seteado: \(fileURL.lastPathComponent)")
                    } else if action == .isShare {
                        self.urlsToZip.append(fileURL)
                    }
                    self.count += 1
                    self.progress = Double(self.count / self.total)
                    print("📊 [ExamList] Progreso: \(Int(self.count))/\(Int(self.total))")
                }
            } catch {
                print("❌ [ExamList] Error descargando archivo: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.count += 1
                    self.progress = self.count / self.total
                }
            }
        }
    }
    func createZip(from urls: [URL], zipFileName: String) -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let zipURL = documentsURL.appendingPathComponent("\(zipFileName).zip")
        do {
            if FileManager.default.fileExists(atPath: zipURL.path) {
                try FileManager.default.removeItem(at: zipURL)
            }
            guard let archive = Archive(url: zipURL, accessMode: .create) else { return nil }
            for fileURL in urls {
                guard FileManager.default.fileExists(atPath: fileURL.path) else { continue }
                try archive.addEntry(with: fileURL.lastPathComponent, relativeTo: fileURL.deletingLastPathComponent())
            }
            return zipURL
        } catch {
            return nil
        }
    }
    func getExamsForPatient() {
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
        Task {
            let result = await Network.shared.getExamsForPatient(accountId: accountId)
            self.isLoading = false
            switch result {
            case .success(let listExam):
                if let urlsExams = listExam.data?.first?.examenesDelPacienteC {
                    if var exams = exams {
                        exams.records = exams.records.map { exam in
                            var updatedExam = exam
                            if let match = urlsExams.first(where: { $0.idOrdenMedicaC == exam.Id }) {
                                updatedExam.url1C = match.urlExamen1C
                                updatedExam.url2C = match.urlExamen2C
                                updatedExam.url3C = match.urlExamen3C
                                updatedExam.url4C = match.urlExamen4C
                                updatedExam.comment = match.comentariosC
                            }
                            return updatedExam
                        }
                        self.exams = exams
                    }
                }
            case let .failure(error):
                AppStatusManager.error(error)
            }
        }
    }
}
