//
//  PrescriptionsView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 14/03/2023.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage
import ZIPFoundation

struct PrescriptionsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedResults(BrandAccounts.self) var items
    @State var UIState: PrescriptionUIState = PrescriptionUIState()
    var accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
    @State var from: String = ""
    @State var until: String = ""
    @State var dateFrom: Date = Date().adding(days: -180)
    @State var dateUntil: Date = .now
    @State var filterPres: String = ""
    @State var total: Double = 1
    @State var count: Double = 0
    @State var progress: Double = 0.0
    @State var isCurrent: Bool = true
    @State private var isLoading: Bool = true
    @State var isLoadingAction: Bool = false
    @State var prescriptions: Prescriptions? = nil
    @State private var showDismissButton: Bool = true
    @State var showFilterView: Bool = false
    @State var showAlert: Bool = false
    @State private var isButtonDownloadEnable: Bool = false
    @State private var isButtonShareEnable: Bool = false
    @State private var isButtonSelectAllFilled: Bool = false
    @State var prescriptionSelectedList: [String:Bool] = [:]
    @State var actionButton: ActionAuthPresAndExam?
    @State var showSheetView: Bool = false
    @State private var urlsToZip: [URL] = []
    @State var urlShare: URL?
    
 
    var body: some View {
        NavigationViewCustom {
            ZStack {
                VStack (spacing: 0){
                    Divider()
                    VStack(spacing: 20){
                        HStack{
                            Button {} label: {
                                Image("search")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.presList.title.color))
                                }
                            TextField(UIState.presList.textBrowser, text: $filterPres)
                            Button {
                                showFilterView.toggle()
                            } label: {
                                Image("filter")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.presList.title.color))
                            }
                        }
                        .padding(.margin)
                        .background {
                            Color.grayLight
                        }
                        .cornerRadius(10)
                        
                        CustomButtonsHeader
                        
                        Text(UIState.presList.titleList.text)
                            .font(Font.custom(UIState.presList.titleList.font, size: CGFloat(Int(UIState.presList.titleList.size) ?? 18)))
                            .foregroundColor(Color(hex: UIState.presList.titleList.color))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ScrollView {
                            if isLoading{
                                ProgressView()
                                    .padding()
                                    .onAppear{
                                        dateToString()
                                        getRecetas()
                                    }
                            }else{
                                VStack {
                                    if let searchPres = searchPres{
                                        ForEach(searchPres, id: \.self) { pres in
                                            
                                            if isCurrent{
                                                if stringToDate(pres.hastaC ?? "") >= Date().adding(days: -1) {
                                                    PrescriptionRowView(isSelected:  $prescriptionSelectedList, prescription: pres, UIState: $UIState)
                                                }
                                            }else{
                                                PrescriptionRowView(isSelected:  $prescriptionSelectedList, prescription: pres, UIState: $UIState)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    .padding(.margin)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(UIState.presList.title.text)
                                .font(Font.custom(UIState.presList.title.font, size: CGFloat(Int(UIState.presList.title.size) ?? 18)))
                                .foregroundColor(Color(hex: UIState.presList.title.color))
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image("back")
                                    .renderingMode(.template)
                                    .tint(Color(hex: UIState.presList.title.color))
                            }
                            .disabled(showFilterView ? true : false)
                        }
                    }
                }
                .sheet(isPresented: $showSheetView, content: {
                    ShareSheet(activityItems: ["¡Hola! Estos documentos fueron compartidos desde la App \(UIState.presList.textToShare).\n", self.urlShare as Any])
                })
                .onChange(of: urlShare, perform: { v in
                    print(v)
                })
                .blur(radius: showFilterView || isLoadingAction ? 3 : 0.000001)
                if showFilterView{
                    withAnimation {
                        PrescriptionFilter(dateFrom: $dateFrom, dateUntil: $dateUntil, isCurrent: $isCurrent, showFilterView: $showFilterView, isLoading: $isLoading, UIState: UIState.presFilter)
                            .background(.white)
                            .cornerRadius(.cornerRadius)
                            .shadow(radius: 10)
                    }
                }
                if isLoadingAction{
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                    withAnimation {
                        PrescriptionDownloadView(total: $total, count: $count)
                            .background(.white)
                            .cornerRadius(.cornerRadius)
                            .shadow(radius: 10)
                    }
                }
            }
            .task{
                loadUIState()
            }
            .onChange(of: count) { newCount in
                if newCount >= total && total > 0 && isLoadingAction {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        isLoadingAction = false
                        if actionButton == .isShare {
                            if let zipURL = createZip(from: urlsToZip, zipFileName: "DocumentosCompartidos") {
                                urlShare = zipURL
                                showSheetView = true
                            }
                        }
                    }
                }
            }
            .configureNavigation()
            .background(
                Group{
                    if UIState.presList.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.presList.imageBackground ),
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
    }
    var searchPres: [Prescriptions.Prescription]?{
        if filterPres.isEmpty{
            return prescriptions?.records
        }else {
            return prescriptions?.records.filter{ $0.Name?.contains(filterPres) ?? false}
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
                    Text(UIState.presList.btnDownload.textBtn)
                        .font(Font.custom(UIState.presList.btnDownload.fontTextBtn, size: CGFloat(Int(UIState.presList.btnDownload.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.presList.btnDownload.colorTextBtn))
                    Image("pdf")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.presList.btnDownload.colorTextBtn))
                }
            }
            .frame(width: 100)
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.presList.btnDownload.colorTextBtn), lineWidth: 1)
                )
            .disabled(isButtonDownloadEnable ? false : true)
            .opacity(isButtonDownloadEnable ? 1 : 0.5)
            Button {
                self.isLoadingAction = true
                actionButton = .isShare
                filterIsSelected()
            } label: {
                HStack{
                    Text(UIState.presList.btnShare.textBtn)
                        .font(Font.custom(UIState.presList.btnShare.fontTextBtn, size: CGFloat(Int(UIState.presList.btnShare.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.presList.btnShare.colorTextBtn))
                    Image("share")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.presList.btnShare.colorTextBtn))
                }
            }
            .frame(width: 100)
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color(hex: UIState.presList.btnShare.colorTextBtn), lineWidth: 1)
                )
            .disabled(isButtonShareEnable ? false : true)
            .opacity(isButtonShareEnable ? 1 : 0.5)
            Button {
                checkSelectedList()
            } label: {
                HStack{
                    Text(UIState.presList.btnSelect.textBtn)
                        .font(Font.custom(UIState.presList.btnSelect.fontTextBtn, size: CGFloat(Int(UIState.presList.btnSelect.sizeTextBtn) ?? 18)))
                        .foregroundColor(Color(hex: UIState.presList.btnSelect.colorTextBtn))
                    Image(isButtonSelectAllFilled ? "unselectAll" : "selectAll" )
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.presList.btnSelect.colorTextBtn))
                        .onChange(of: prescriptionSelectedList) { newValue in
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
                    .stroke(Color(hex: UIState.presList.btnSelect.colorTextBtn), lineWidth: 1)
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
    prescriptionSelectedList = [:]
        Task{
            let result = await Network.shared.getRecetas(accountId: accountId, from: from, until: until)
            self.isLoading = false
            switch result {
                case let .success(listPres):
                self.prescriptions = listPres
                if let prescriptions = prescriptions{
                    for pres in prescriptions.records {
                        if isCurrent{
                            if stringToDate(pres.hastaC ?? "") >= Date().adding(days: -1) {
                                prescriptionSelectedList[pres.Id ?? ""] = false
                            }
                        }else{
                            prescriptionSelectedList[pres.Id ?? ""] = false
                        }
                    }
                }
                case let .failure(error):
                    AppStatusManager.error(error)
                
            }

        }
    }
    func checkSelectedList(){
        if let searchPres = searchPres{
            if prescriptionSelectedList.contains(where: { (key: String, value: Bool) in
                value == false
            }){
                if isCurrent{
                    for pres in searchPres {
                        if stringToDate(pres.hastaC ?? "") >= Date().adding(days: -1) {
                            prescriptionSelectedList[pres.Id ?? ""] = true
                        }
                    }
                }else{
                    for pres in searchPres {
                        prescriptionSelectedList[pres.Id ?? ""] = true
                    }
                }
                
                isButtonSelectAllFilled = true
            }else{
                if isCurrent{
                    for pres in searchPres {
                        if stringToDate(pres.hastaC ?? "") >= Date().adding(days: -1) {
                            prescriptionSelectedList[pres.Id ?? ""] = false
                        }
                    }
                }else{
                    for pres in searchPres {
                        prescriptionSelectedList[pres.Id ?? ""] = false
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
        if let prescriptions = prescriptions{
            if prescriptionSelectedList.contains(where: { (key: String, value: Bool) in
                value == true
            }){
                for pres in prescriptions.records{
                    if prescriptionSelectedList[pres.Id ?? ""] ?? false{
                        self.total += 1
                    }
                }
            }
            if prescriptionSelectedList.contains(where: { (key: String, value: Bool) in
                value == true
            }){
                for pres in prescriptions.records{
                    if prescriptionSelectedList[pres.Id ?? ""] ?? false{
                        if actionButton == .isDownload{
//                            downloadSelected(pres.urlDeLaRecetaC ?? "", name: pres.Name ?? "")
                            downloadArchive(urlParameter: pres.urlDeLaRecetaC ?? "", action: .isDownload)
                        }
                        if actionButton == .isShare{
//                            shareSelected(pres.urlDeLaRecetaC ?? "Sin URL", name: pres.Name ?? "Sin nombre")
                            downloadArchive(urlParameter: pres.urlDeLaRecetaC ?? "", action: .isShare)
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
        let fileName = UIState.presList.textToShare
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
            let pdfNameFromUrl = "\(name)-\(fileName).pdf"
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
    func downloadArchive(urlParameter: String?, action: ActionAuthPresAndExam) {
        guard let rawUrl = urlParameter, !rawUrl.isEmpty else { return }
        let fileName = S3FileHelper.extractFileNameFromUrl(rawUrl)
        let objectKey = S3FileHelper.extractObjectKeyFromUrl(rawUrl)

        Task {
            let result = await Network.shared.getPresignedUrl(objectKey: objectKey, filename: fileName)
            switch result {
            case let .success(response):
                guard let presignedUrl = response.url, !response.error,
                      let remoteURL = URL(string: presignedUrl) else {
                    self.count += 1
                    self.progress = Double(self.count / self.total)
                    return
                }
                downloadFromPresignedUrl(remoteURL, fileName: fileName, action: action)
            case let .failure(error):
                AppStatusManager.error(error)
                self.count += 1
                self.progress = Double(self.count / self.total)
            }
        }
    }

    func downloadFromPresignedUrl(_ remoteURL: URL, fileName: String, action: ActionAuthPresAndExam) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: remoteURL)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
                let safeFileName = S3FileHelper.sanitizeFileName(fileName)
                let fileURL = documentsURL.appendingPathComponent(safeFileName)
                try data.write(to: fileURL, options: .atomic)

                DispatchQueue.main.async {
                    if action == .isShare {
                        self.urlsToZip.append(fileURL)
                    }
                    self.count += 1
                    self.progress = Double(self.count / self.total)
                }
            } catch {
                DispatchQueue.main.async {
                    self.count += 1
                    self.progress = self.count / self.total
                }
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
}

enum ActionAuthPresAndExam: Identifiable{
    var id: Int{
        hashValue
    }
    case isDownload
    case isShare
}
