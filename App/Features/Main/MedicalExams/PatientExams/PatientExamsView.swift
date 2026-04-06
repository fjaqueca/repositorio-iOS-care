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
    var accountId: String = UserDefaults.standard.string(forKey: "account_id") ?? ""
    @State var filterExams: String = ""
    @State private var isLoading: Bool = true
    @State var exams: [FunctionFilterExamResponse.PatientExams] = []
    @State private var sendNewExam = false

    private var accentColor: Color {
        Color(hex: UIState.examList.iconSelectColor.isEmpty ? "#387FC2" : UIState.examList.iconSelectColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
                .padding(.horizontal, .margin)
                .padding(.top, 21)

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
                                PatientExamRowView(
                                    exam: exam,
                                    isLoadingExam: $isLoading,
                                    UIState: $UIState
                                )
                            }
                        }
                        .padding(.horizontal, .margin)
                        .padding(.top, 23)
                        .padding(.bottom, .margin)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "folder.badge.questionmark")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.35))
                            Text("No se encontraron exámenes")
                                .font(Font.custom("FiraSans-Regular", size: 16))
                                .foregroundColor(.gray)
                            if !filterExams.isEmpty {
                                Text("Intenta con otro término de búsqueda")
                                    .font(Font.custom("FiraSans-Regular", size: 13))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    }
                }
            }

            // Upload exam button
            uploadButton
                .padding(.horizontal, .margin)
                .padding(.vertical, 16)
        }
        .onAppear {
            getExamsForPatient()
        }
        .navigationLink(isActive: $sendNewExam) {
            SendNewExamView(UIState: $UIState, isPublished: false, exam: nil)
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

            TextField("Buscar mis exámenes...", text: $filterExams)
                .font(Font.custom("FiraSans-Regular", size: 15))

            if !filterExams.isEmpty {
                Button {
                    filterExams = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
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
    private var uploadButton: some View {
        Button {
            sendNewExam = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 14, weight: .medium))
                Text(UIState.btnAddSeeExam.btnAddExam.textBtn.isEmpty ? "Subir Examen" : UIState.btnAddSeeExam.btnAddExam.textBtn)
                    .font(Font.custom("FiraSans-Medium", size: 15))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor)
            )
        }
    }

    // MARK: - Computed
    var searchExams: [FunctionFilterExamResponse.PatientExams]? {
        if filterExams.isEmpty {
            return exams
        } else {
            return exams.filter { $0.nombreDelExamenC?.localizedCaseInsensitiveContains(filterExams) ?? false }
        }
    }

    // MARK: - Functions
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
            self.isLoading = false
            switch result {
            case .success(let listExam):
                let records = listExam.data?.first?.examenesDelPacienteC ?? []
                print("✅ [MisExamenes] Servicio OK - statusCode: \(listExam.statusCode ?? -1)")
                print("   Exámenes recibidos: \(records.count)")
                for (i, exam) in records.enumerated() {
                    print("   [\(i)] Id=\(exam.Id ?? "") Nombre=\"\(exam.nombreDelExamenC ?? "")\" Fecha=\(exam.CreatedDate ?? "") URL1=\(exam.urlExamen1C?.prefix(50) ?? "(nil)")")
                }
                self.exams = records.sorted(by: { $0.CreatedDate ?? "" > $1.CreatedDate ?? "" })
                print("   Exámenes ordenados y asignados: \(self.exams.count)")
            case let .failure(error):
                print("❌ [MisExamenes] Error: \(error.name) - \(error.message)")
                AppStatusManager.error(error)
            }
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }
}
