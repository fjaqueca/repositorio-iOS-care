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
    @State var examSelectedList: [String:Bool] = [:]
    @State var actionButton: ActionAuthPresAndExam?
    @State var showSheetView: Bool = false
    @State var isLoadingFav: Bool = false
    @State private var urlsToZip: [URL] = []
    @State var urlShare: URL?
 
    var body: some View {
            ZStack {
                    VStack(spacing: 20){
                        HStack{
                            Button {} label: {
                                Image("search")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.examList.title.color))
                                }
                            TextField(UIState.examList.textBrowser, text: $filterExams)
                            Button {
                                showFilterView.toggle()
                            } label: {
                                Image("filter")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.examList.title.color))
                            }
                        }
                        .padding(.margin)
                        .background {
                            Color.grayLight
                        }
                        .cornerRadius(10)
                        
                        CustomButtonsHeader
                            .onAppear{
                                dateToString()
                                getRecetas()
                            }
//                        Text(UIState.examList.titleList.text)
//                            .font(Font.custom(UIState.examList.titleList.font, size: CGFloat(Int(UIState.examList.titleList.size) ?? 18)))
//                            .foregroundColor(Color(hex: UIState.examList.titleList.color))
//                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ScrollView {
                            if isLoading{
                                ProgressView()
                                    .padding()
                                    
                            }else{
                                VStack {
                                    if let searchExams = searchExams{
                                        ForEach(searchExams, id: \.self) { exams in
                                            
                                            if isCurrent{
                                                if stringToDate(exams.hastaC ?? "") >= Date().adding(days: -1) {
                                                    MedicalExamsRowView(isSelected:  $examSelectedList, exam: exams, isLoadingFavorite: $isLoadingFav, isLoadingExam: $isLoading, UIState: $UIState)
                                                }
                                            }else{
                                                MedicalExamsRowView(isSelected:  $examSelectedList, exam: exams, isLoadingFavorite: $isLoadingFav, isLoadingExam: $isLoading, UIState: $UIState)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    .padding(.margin)
                    
                .sheet(isPresented: $showSheetView, content: {
                    ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.examList.textToShare).\n", self.urlShare as Any])
                })
                .onChange(of: urlShare, perform: { v in
                    print(v)
                })
                .blur(radius: showFilterView || isLoadingAction || isLoadingFav ? 3 : 0.000001)
                if showFilterView{
                    withAnimation {
                        PrescriptionFilter(dateFrom: $dateFrom, dateUntil: $dateUntil, isCurrent: $isCurrent, showFilterView: $showFilterView, isLoading: $isLoading, UIState: UIState.examFilter)
                            .background(.white)
                            .cornerRadius(.cornerRadius)
                            .shadow(radius: 10)
                    }
                }
                if isLoadingAction{
                    withAnimation {
                        PrescriptionDownloadView(isLoadingAction: $isLoadingAction, total: $total, count: $count, progress: $progress, actionButton: $actionButton, showSheetView: $showSheetView)
                            .background(.white)
                            .cornerRadius(.cornerRadius)
                            .shadow(radius: 10)
                    }
                }
                if isLoadingFav{
                    ProgressView()
                        .padding()
                }
            }
            .background(
                Group{
                    if UIState.examList.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.examList.imageBackground ),
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
    var searchExams: [MedicalExams.Exam]?{
        if filterExams.isEmpty{
            return exams?.records.sorted(by: { $0.desdeC ?? "" > $1.desdeC ?? "" })
                .sorted{$0.favoritoAppC ?? false && !($1.favoritoAppC ?? false) }
        }else {
            return exams?.records.filter{ $0.Name?.contains(filterExams) ?? false}
                .sorted(by: { $0.desdeC ?? "" > $1.desdeC ?? "" })
                .sorted{$0.favoritoAppC ?? false && !($1.favoritoAppC ?? false) }
        }
    }
    private var CustomButtonsHeader: some View{
        
        HStack{
            Button {
                self.isLoadingAction = true
                actionButton = .isDownload
                filterIsSelected()
            } label: {
                HStack{
                    Text(UIState.examList.btnDownload.textBtn)
                        .font(Font.custom(UIState.examList.btnDownload.fontTextBtn, size: CGFloat(Int(UIState.examList.btnDownload.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.examList.btnDownload.colorTextBtn))
                    Image("pdf")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.examList.btnDownload.colorTextBtn))
                }
            }
            .frame(width: 100)
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.examList.btnDownload.colorTextBtn), lineWidth: 1)
                )
            .disabled(isButtonDownloadEnable ? false : true)
            .opacity(isButtonDownloadEnable ? 1 : 0.5)
            Button {
                self.isLoadingAction = true
                actionButton = .isShare
                filterIsSelected()
            } label: {
                HStack{
                    Text(UIState.examList.btnShare.textBtn)
                        .font(Font.custom(UIState.examList.btnShare.fontTextBtn, size: CGFloat(Int(UIState.examList.btnShare.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.examList.btnShare.colorTextBtn))
                    Image("share")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.examList.btnShare.colorTextBtn))
                }
            }
            .frame(width: 100)
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.examList.btnShare.colorTextBtn), lineWidth: 1)
                )
            .disabled(isButtonShareEnable ? false : true)
            .opacity(isButtonShareEnable ? 1 : 0.5)
            Button {
                checkSelectedList()
            } label: {
                HStack{
                    Text(UIState.examList.btnSelect.textBtn)
                        .font(Font.custom(UIState.examList.btnSelect.fontTextBtn, size: CGFloat(Int(UIState.examList.btnSelect.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.examList.btnSelect.colorTextBtn))
                    Image(isButtonSelectAllFilled ? "unselectAll" : "selectAll" )
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.examList.btnSelect.colorTextBtn))
                        .onChange(of: examSelectedList) { newValue in
                            if newValue.contains(where: { (key: String, value: Bool) in
                                value == false
                            }){
                                isButtonSelectAllFilled = false
                            }else{
                                isButtonSelectAllFilled = true
                            }
                            if newValue.contains(where: { (key: String, value: Bool) in
                                value == true
                            }){
                                isButtonShareEnable = true
                                isButtonDownloadEnable = true
                            }else{
                                isButtonShareEnable = false
                                isButtonDownloadEnable = false
                            }
                        }
                }
            }
            .frame(width: 100)
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.examList.btnSelect.colorTextBtn), lineWidth: 1)
                )
        }
    }
    func dateToString(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.from = formatter.string(from: dateFrom)
        self.until = formatter.string(from: dateUntil)
    }
    func stringToDate(_ dateString: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString){
            return date
        }else{
            return Date().adding(days: +1)
        }
        
    }
    func getRecetas(){
        self.isLoading = true
        Task{
            let result = await Network.shared.getExams(accountId: accountId, from: from, until: until)
            
            switch result {
                case let .success(listExams):
                self.exams = listExams
                if let exams = exams{
                    for exam in exams.records {
                        if isCurrent{
                            if stringToDate(exam.hastaC ?? "") >= Date().adding(days: -1) {
                                examSelectedList[exam.Id ?? ""] = false
                            }
                        }else{
                            examSelectedList[exam.Id ?? ""] = false
                        }
                    }
                }
                getExamsForPatient()
                case let .failure(error):
                    AppStatusManager.error(error)
                self.isLoading = false
            }

        }
    }
    func checkSelectedList(){
        if let searchExams = searchExams{
            if examSelectedList.contains(where: { (key: String, value: Bool) in
                value == false
            }){
                if isCurrent{
                    for exam in searchExams {
                        if stringToDate(exam.hastaC ?? "") >= Date().adding(days: -1) {
                            examSelectedList[exam.Id ?? ""] = true
                        }
                    }
                }else{
                    for exam in searchExams {
                        examSelectedList[exam.Id ?? ""] = true
                    }
                }
                isButtonSelectAllFilled = true
            }else{
                if isCurrent{
                    for exam in searchExams {
                        if stringToDate(exam.hastaC ?? "") >= Date().adding(days: -1) {
                            examSelectedList[exam.Id ?? ""] = false
                        }
                    }
                }else{
                    for exam in searchExams {
                        examSelectedList[exam.Id ?? ""] = false
                    }
                }
                isButtonSelectAllFilled = false
            }
        }
    }
    func filterIsSelected(){
        self.urlsToZip = []
        self.total = 0.0
        self.count = 0.0
        self.progress = 0.0
        if let exams = exams{
            if examSelectedList.contains(where: { (key: String, value: Bool) in
                value == true
            }){
                for exam in exams.records{
                    if examSelectedList[exam.Id ?? ""] ?? false{
                        self.total += 1
                    }
                }
            }
            if examSelectedList.contains(where: { (key: String, value: Bool) in
                value == true
            }){
                for exam in exams.records{
                    if examSelectedList[exam.Id ?? ""] ?? false{
                        if actionButton == .isDownload{
//                            downloadSelected(exam.urlDeLaOrdenMedicaC ?? "", name: exam.Name ?? "")
                            downloadArchive(urlParameter: exam.urlDeLaOrdenMedicaC ?? "", action: .isDownload)
                        }
                        if actionButton == .isShare{
//                            shareSelected(exam.urlDeLaOrdenMedicaC ?? "Sin URL", name: exam.Name ?? "Sin nombre")
                            downloadArchive(urlParameter: exam.urlDeLaOrdenMedicaC ?? "", action: .isShare)
                        }
                    }
                }
//                if actionButton == .isShare{
//                    self.showSheetView = true
//                }
                self.actionButton = .none
            }
        }
    }
    func downloadSelected(_ url: String, name: String){
        let fileName = UIState.examList.textToShare
        savePdf(urlString: url, fileName: fileName, name: name)
    }
//    func shareSelected(_ url: String, name: String){
//        self.stringShare += "\(name):\n\(url)\n"
//    }
    func savePdf(urlString:String, fileName:String, name: String) {
        DispatchQueue.global(qos: .background).async  {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "Examen: \(name)-\(fileName).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
                self.count += 1
                self.progress = Double(self.count/self.total)
                print(self.progress)
            } catch {
                print("PDF no guardado: \(error)")
                self.count += 1
                self.progress = self.count/self.total
                print(self.progress)
            }
        }
    }
    func downloadArchive(urlParameter: String?, action : ActionAuthPresAndExam){
        if let url = urlParameter {
            let pdfName = url.components(separatedBy: "/")
            Task{
                let result = await Network.shared.getPdf(pdfName: pdfName.last ?? "")
                switch result {
                    case let .success(exam):
                        createPDF(with: exam.data, fileName: pdfName.last ?? ".pdf", action: action)
                    case let .failure(error):
                        AppStatusManager.error(error)
                }
            }
        }
    }
    /// Creates a PDF file from a Base64 encoded string
    func createPDF(with base64Info: String, fileName: String, action: ActionAuthPresAndExam) {
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
                    self.count += 1
                    self.progress = Double(self.count/self.total)
                    print(self.progress)
                case .isShare:
                    self.urlsToZip.append(fileURL)
                    self.count += 1
                    self.progress = Double(self.count/self.total)
                    if self.count >= self.total {
                        if let zipURL = createZip(from: self.urlsToZip, zipFileName: "DocumentosCompartidos") {
                            self.urlShare = zipURL // Actualiza con el archivo ZIP
                            self.showSheetView.toggle()
                        }
                    }
                }
                
            } catch let error {
                print("Failed to write the PDF data due to: \(error.localizedDescription)")
                self.count += 1
                self.progress = self.count/self.total
                print(self.progress)
            }
        }
    }
    /// Crea un archivo .zip a partir de múltiples URLs
    func createZip(from urls: [URL], zipFileName: String) -> URL? {
        // Directorio de documentos
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let zipURL = documentsURL.appendingPathComponent("\(zipFileName).zip")
        
        do {
            // Si el archivo ya existe, elimínalo
            if FileManager.default.fileExists(atPath: zipURL.path) {
                try FileManager.default.removeItem(at: zipURL)
                print("Archivo ZIP anterior eliminado.")
            }
            
            // Crea el archivo ZIP
            guard let archive = Archive(url: zipURL, accessMode: .create) else {
                print("No se pudo crear el archivo ZIP.")
                return nil
            }
            
            for fileURL in urls {
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    print("El archivo no existe: \(fileURL.path)")
                    continue
                }
                
                // Añade cada archivo al archivo ZIP
                try archive.addEntry(
                    with: fileURL.lastPathComponent,
                    relativeTo: fileURL.deletingLastPathComponent()
                )
            }
            
            print("Archivo ZIP creado exitosamente en: \(zipURL.path)")
            return zipURL
        } catch {
            print("Error al crear el archivo ZIP: \(error.localizedDescription)")
            return nil
        }
    }
    func getExamsForPatient(){
        let accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
//        self.isLoading = true
        Task{
            let result = await Network.shared.getExamsForPatient(accountId: accountId)
            self.isLoading = false
            switch result {
                case .success(let listExam):
                if let urlsExams = listExam.data.first?.examenesDelPacienteC{
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
