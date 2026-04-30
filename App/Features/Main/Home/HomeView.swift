//
//  HomeView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 06/08/2022.
//

import Foundation
import SwiftUI
import RealmSwift
import CachedAsyncImage

struct HomeView: View {
    /// Flag de sesión: true después de mostrar (o decidir) el formulario por primera vez.
    /// Se resetea automáticamente al cerrar la app (es static, vive solo en memoria).
    private static var formularioYaMostradoEnSesion = false

    @State private var selectedEnterprise: CompanyAgreementR? = AppStatusManager.selectedEnterprise
    @State var  isLoading: Bool = true
    @ObservedResults(User.self) private var users
    @ObservedResults(BrandAccounts.self) var items
    @State var totalSubHomes: [String] = ["SecIni"]
    @State var currentSubHome: [String] = []
    @State var tipeSubHome: [Int] = []
    @Binding var UIStateAppoint: AppointmentUIStateModel
    @Binding var UIState: HomeUIState
    @Binding var selectedColor: String
    @Binding var selectedTab: Tab

    // NUEVO: Guardar respuesta cruda del servicio Brand Account
    @State private var brandAccountResponse: BrandAccounts?
    // NUEVO: Registro encontrado con Name == "FormularioGeneral"
    @State private var brandAccountFormularioGeneral: BrandAccount?
    // NUEVO: Flag para indicar si mostrar formulario general (Valor_1_1__c == "Si")
    @State private var mostrarFormularioGeneral: Bool = false
    // NUEVO: Formulario parseado listo para mostrar
    @State private var formularioParsed: FormularioGeneral?

    var body: some View {
        NavigationViewCustom {
            ZStack{
                // CONTENIDO PRINCIPAL
                VStack(spacing: .margin * 2) {
                    VStack {
                        HStack{
                            if totalSubHomes.count > 1{
                                Button {
                                    totalSubHomes.removeLast()
                                    tipeSubHome.removeLast()
                                    UIState.customSubHomeName.removeLast()
                                    UIState.nameSubHomeText.removeLast()
                                } label: {
                                    Image("back")
                                }
                            }
                            if totalSubHomes.count == 1{
                                CachedAsyncImage(
                                    url: URL(string: UIState.imageLogo),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 60, alignment: .leading)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    })
                            }
                            if UIState.imageLogo != "" && totalSubHomes.count > 1{
                                CachedAsyncImage(
                                    url: URL(string: UIState.imageLogo),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 90, alignment: .leading)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    })
                            }
                            
                            VStack(alignment: .leading){
                                if UIState.imageLogo == ""{
                                    Text(UIState.nameSubHomeText.last ?? "")
                                        .font(Font.custom(UIState.greetingUIState.font, size: CGFloat(Int(UIState.greetingUIState.size) ?? 14)))
                                        .foregroundColor(Color(hex: UIState.greetingUIState.color))
                                }else if totalSubHomes.count == 1 {
                                    Text(UIState.greetingUIState.text)
                                        .font(Font.custom(UIState.greetingUIState.font, size: CGFloat(Int(UIState.greetingUIState.size) ?? 14)))
                                        .foregroundColor(Color(hex: UIState.greetingUIState.color))
                                }
                                if totalSubHomes.count == 1{
                                    Text(users.first?.records.first?.FirstName ?? "")
                                        .font(Font.custom(UIState.userUIState.font, size: CGFloat(Int(UIState.userUIState.size) ?? 16)))
                                        .foregroundColor(Color(hex: UIState.userUIState.color))
                                }
                            }
                            .padding(.leading)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, .margin)
                    
                    ScrollView(.vertical) {
                        TilesView(UIState: $UIState, UIStateAppoint: $UIStateAppoint, currentSubHome: $currentSubHome, totalSubHomes: $totalSubHomes, tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                    }
                }
                .onReceive(AppStatusManager.onSelectedEnterprise) { newValue in
                    guard let newValue = newValue else { return }
                    if self.selectedEnterprise != newValue{
                        self.selectedEnterprise = newValue
                    }
                }
                .onChange(of: items){ newValue in
                    loadUIState()
                    loadUIStateAppoint()
                }
                .onChange(of: tipeSubHome){ newValue in
                    loadUIState()
                }
                .navigationBarHidden(true)
                .configureNavigation()
                .blur(radius: isLoading ? 3 : 0.000001)
                
                // LOADING ESTÁNDAR (visible mientras isLoading = true)
                /*if isLoading {
                    CenteredLoadingView()
                }*/
            }
        }
        .accentColor(.blue)
        .onAppear {
            // Ejecutar el servicio BrandAccount al entrar a HomeView (doble llamada)
            Task {
                print("⏳ [Loading] Iniciando carga de HomeView...")
                
                // 1) Mantener flujo actual: persistir en Realm y generar clínicas
                await AppStatusManager.loadBrandAccount()
                
                // 2) Obtener respuesta cruda para print y guardado en brandAccountResponse
                if let agreementId = AppStatusManager.selectedEnterprise?.empresaC, !agreementId.isEmpty {
                    print("🔎 Iniciando carga de BrandAccount con agreementId: \(agreementId)")
                    let result = await Network.shared.getBrandAccount(agreementId: agreementId)
                    switch result {
                    case .success(let brands):
                        // Guardar en variable local de estado
                        self.brandAccountResponse = brands
                        print("✅ BrandAccount cargado. totalSize: \(brands.totalSize ?? -1), done: \(brands.done ?? false), records: \(brands.records.count)")
                        
                        // ✅ Imprimir JSON legible en consola
                        do {
                            let encoder = JSONEncoder()
                            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                            let data = try encoder.encode(brands)
                            if let jsonString = String(data: data, encoding: .utf8) {
                                //print("✅ BrandAccount JSON (pretty):\n\(jsonString)")
                            } else {
                                print("ℹ️ No se pudo convertir a String el JSON de BrandAccount.")
                            }
                        } catch {
                            print("❌ Error al serializar BrandAccount a JSON: \(error)")
                        }
                        
                        // 🔎 Buscar el registro con Name == "FormularioGeneral"
                        findFormularioGeneral(in: brands)
                        
                        // 3) NUEVO: Consultar si el usuario ya tiene Ficha Clínica General
                        await checkFichaClinicaGeneralAndDecide()
                        
                    case .failure(let error):
                        print("❌ Error al obtener BrandAccount (crudo):", error)
                        // Aunque falle BrandAccount crudo, intentamos ficha clínica para decidir modal
                        await checkFichaClinicaGeneralAndDecide()
                    }
                } else {
                    print("ℹ️ No hay agreementId disponible para cargar BrandAccount en HomeView.")
                    // Sin convenio, igual intentamos ficha clínica por si hay account_id
                    await checkFichaClinicaGeneralAndDecide()
                }
                
                // ✅ El loading se ocultará DENTRO de applyFinalDecision()
                // después de tomar la decisión final sobre el modal
                print("✅ [Loading] Proceso de decisión completado")
            }
        }
        // PRESENTACIÓN DEL SHEET CUANDO mostrarFormularioGeneral = true
        .sheet(isPresented: $mostrarFormularioGeneral) {
            if let formulario = formularioParsed {
                FormularioGeneralView(
                    formulario: formulario,
                    onComplete: { respuestas in
                        handleFormularioComplete(respuestas: respuestas, formulario: formulario)
                    },
                    onClose: {
                        mostrarFormularioGeneral = false
                    },
                    isCloseable: true // ✅ HomeView: El modal SÍ se puede cerrar
                )
            }
        }
    }
    
    // MARK: - Búsqueda de "FormularioGeneral"
    private func findFormularioGeneral(in brands: BrandAccounts) {
        print("🔎 Buscando registro con Name == \"FormularioGeneral\" en \(brands.records.count) records...")
        
        var foundIndex: Int?
        for (index, record) in brands.records.enumerated() {
            let name = record.Name ?? "(nil)"
            print("   • Revisando record[\(index)] Name: \(name)")
            if name == "FormularioGeneral" {
                foundIndex = index
                break
            }
        }
        
        guard let index = foundIndex else {
            print("⚠️ No se encontró ningún registro con Name == \"FormularioGeneral\".")
            self.brandAccountFormularioGeneral = nil
            // No alteramos mostrarFormularioGeneral aquí; se decidirá luego con ficha clínica
            return
        }
        
        let record = brands.records[index]
        self.brandAccountFormularioGeneral = record
        print("✅ Encontrado FormularioGeneral en index \(index). Id: \(record.Id ?? "(nil)")")
        
        // ===== PRINT DETALLADO DEL REGISTRO COMPLETO =====
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 REGISTRO COMPLETO: FormularioGeneral (index \(index))")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // Serializar el registro completo a JSON legible
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(record)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 JSON del registro FormularioGeneral:\n\(jsonString)")
            } else {
                print("⚠️ No se pudo convertir el registro a String JSON")
            }
        } catch {
            print("❌ Error al serializar FormularioGeneral a JSON: \(error)")
        }
        
        // Print de campos individuales importantes
        print("\n📌 CAMPOS CLAVE:")
        print("   • Id: \(record.Id ?? "(nil)")")
        print("   • Name: \(record.Name ?? "(nil)")")
        print("   • Atributo_1_1__c: \(record.atributo11C ?? "(nil)")")
        print("   • Valor_1_1__c: \(record.valor11C ?? "(nil)")")
        print("   • Atributo_2_1__c: \(record.atributo21C ?? "(nil)")")
        print("   • Valor_2_1__c: \(record.valor21C ?? "(nil)")")
        print("   • Atributo_3_1__c: \(record.atributo31C ?? "(nil)")")
        print("   • Valor_3_1__c: \(record.valor31C ?? "(nil)")")
        print("   • Atributo_4_1__c: \(record.atributo41C ?? "(nil)")")
        print("   • Valor_4_1__c: \(record.valor41C ?? "(nil)")")
        print("   • Atributo_5_1__c: \(record.atributo51C ?? "(nil)")")
        print("   • Valor_5_1__c: \(record.valor51C ?? "(nil)")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
        
        // No decidimos aún; la prioridad se aplicará en checkFichaClinicaGeneralAndDecide()
    }
    
    // MARK: - Decisión final: Ficha Clínica + Prioridad BrandAccount
    @MainActor
    private func checkFichaClinicaGeneralAndDecide() async {
        // Solo mostrar el formulario 1 vez por sesión de app
        guard !HomeView.formularioYaMostradoEnSesion else {
            print("ℹ️ [FichaClinica] Ya se evaluó el formulario en esta sesión. No se volverá a mostrar.")
            self.isLoading = false
            return
        }
        HomeView.formularioYaMostradoEnSesion = true

        // 📝 IMPORTANTE: Como Android, NUNCA usamos el flag como gate aquí
        // El flag solo se actualiza DESDE la respuesta del servidor
        // Si el usuario borró la ficha desde Salesforce, lo detectamos en la próxima navegación

        let accountId = UserDefaults.standard.string(forKey: "account_id") ?? ""
        guard !accountId.isEmpty else {
            print("⚠️ [FichaClinica] account_id vacío. No se puede consultar Ficha_Clinica_General__c.")
            applyFinalDecision(fichaArrayCount: nil)
            return
        }
        
        // Log del flag para info, pero NO lo usamos como gate
        let flagLocal = UserDefaults.standard.bool(forKey: "ficha_clinica_completada")
        print("🩺 [FichaClinica] Consultando servidor SIEMPRE (flag_local=\(flagLocal), ignorado)")
        print("   • Motivo: Como Android, la fuente de verdad es el servidor")
        print("   • POST function_filter con Account__c=\(accountId)")
        
        let result = await Network.shared.fichaClinicaGeneralService(accountId: accountId)
        switch result {
        case .success(let response):
            let countBlocks = response.data.count
            print("✅ [FichaClinica] Respuesta OK. data.count=\(countBlocks)")
            if let first = response.data.first {
                let fichaArray = first["Ficha_Clinica_General__c"] ?? []
                print("📦 [FichaClinica] Ficha_Clinica_General__c count=\(fichaArray.count)")
                applyFinalDecision(fichaArrayCount: fichaArray.count)
            } else {
                print("ℹ️ [FichaClinica] data.first es nil. Asumimos fichaArray vacío para decisión preliminar.")
                applyFinalDecision(fichaArrayCount: 0)
            }
        case .failure(let error):
            print("❌ [FichaClinica] Error en function_filter:", error)
            applyFinalDecision(fichaArrayCount: 0)
        }
    }
    
    // Aplica la prioridad del atributo sobre la decisión preliminar por ficha
    private func applyFinalDecision(fichaArrayCount: Int?) {
        // ℹ️ NOTA: Este método se llama DESPUÉS de consultar el servidor
        // Si llegamos aquí, significa que YA hicimos el HTTP request
        // Por lo tanto, debemos CONFIAR en la respuesta del servidor (fichaArrayCount)
        // y ACTUALIZAR el flag local basado en esa respuesta
        
        var wantsToShowByFicha = false
        if let count = fichaArrayCount {
            wantsToShowByFicha = (count == 0)
            print("🧮 [Decision] Respuesta del servidor: fichaArrayCount=\(count) → wantsToShowByFicha=\(wantsToShowByFicha)")
            
            // Actualizar flag local basado en servidor (fuente de verdad)
            if count > 0 {
                print("💾 [Decision] Servidor confirma que tiene ficha → Actualizar flag=true")
                UserDefaults.standard.set(true, forKey: "ficha_clinica_completada")
            } else {
                print("💾 [Decision] Servidor confirma que NO tiene ficha → Actualizar flag=false")
                UserDefaults.standard.set(false, forKey: "ficha_clinica_completada")
            }
        } else {
            print("🧮 [Decision] Sin dato de ficha (nil). Mantendremos false salvo override.")
            wantsToShowByFicha = false
        }
        
        var finalDecision = wantsToShowByFicha
        if let form = self.brandAccountFormularioGeneral {
            let atributo = form.atributo11C ?? ""
            let valor = form.valor11C ?? ""
            let isOverride = (atributo == "MostrarFormularioGeneral") && (valor.lowercased() == "si")
            print("⚖️ [Decision] Chequeando override BrandAccount → Atributo='\(atributo)' Valor='\(valor)' → override=\(isOverride)")
            
            // 🔧 FIX CRÍTICO: El override solo aplica si NO tiene ficha clínica
            // Si ya tiene ficha, NUNCA mostrar el modal (sin importar el override)
            if isOverride && wantsToShowByFicha {
                finalDecision = true
                
                // 🔧 NUEVO: Parsear el formulario si decidimos mostrarlo
                if let formulario = FormularioGeneralParser.parse(from: form) {
                    self.formularioParsed = formulario
                    print("✅ [Decision] Formulario parseado exitosamente con \(formulario.preguntas.count) preguntas")
                } else {
                    print("⚠️ [Decision] No se pudo parsear el formulario. No se mostrará nada.")
                    finalDecision = false
                }
            } else if !wantsToShowByFicha {
                // Usuario ya tiene ficha → Nunca mostrar modal
                finalDecision = false
                print("✅ [Decision] Usuario ya tiene ficha clínica → Override ignorado, modal NO se mostrará")
            } else {
                // isOverride es false (BrandAccount dice "No" o no es "Si") → No mostrar
                finalDecision = false
                print("✅ [Decision] BrandAccount NO habilita formulario (Valor='\(valor)') → modal NO se mostrará")
            }
        } else {
            print("ℹ️ [Decision] No hay registro 'FormularioGeneral' en BrandAccount para override.")
        }
        
        self.mostrarFormularioGeneral = finalDecision
        print("🟢 [Decision] mostrarFormularioGeneral=\(self.mostrarFormularioGeneral)")
        
        // ✅ OCULTAR LOADING AQUÍ (después de tomar la decisión final)
        print("✅ [Loading] Decisión final tomada. Ocultando loading...")
        self.isLoading = false
    }
    
    // MARK: - Handler del formulario completado
    @MainActor
    private func handleFormularioComplete(respuestas: [String: Any], formulario: FormularioGeneral) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 [HomeView.Formulario] Respuestas recibidas del formulario")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        guard let nombreFlujo = formulario.nombreFlujoServicio else {
            print("⚠️ [HomeView.Formulario] No hay nombre de flujo definido")
            return
        }
        
        print("🚀 [HomeView.Formulario] Ejecutando flujo: \(nombreFlujo)")
        print("📦 [HomeView.Formulario] Total de preguntas a enviar: \(formulario.preguntas.count)")
        
        // Reconstruir el diccionario correcto desde el FormularioGeneralView
        // El formulario viene con estructura: ["pregunta_1": {...}, "pregunta_2": {...}]
        // Necesitamos convertirlo a [UUID: RespuestaPregunta]
        
        var respuestasTyped: [UUID: RespuestaPregunta] = [:]
        
        for (index, pregunta) in formulario.preguntas.enumerated() {
            let key = "pregunta_\(index + 1)"
            
            // Obtener el diccionario de la respuesta
            guard let respuestaDict = respuestas[key] as? [String: Any] else {
                print("⚠️ [HomeView.Formulario] No se encontró respuesta para \(key)")
                continue
            }
            
            // Reconstruir RespuestaPregunta desde el diccionario
            // NOTA: opcionesSeleccionadas ahora viene como String (formato "Opcion1;Opcion2;Opcion3")
            let opcionesString = respuestaDict["opcionesSeleccionadas"] as? String ?? ""
            let opcionesArray = opcionesString.isEmpty ? [] : opcionesString.components(separatedBy: ";")
            
            let textoLibre = respuestaDict["textoLibre"] as? String ?? ""
            let campoCondicional = respuestaDict["campoCondicional"] as? String ?? ""
            
            let respuesta = RespuestaPregunta(
                opcionesSeleccionadas: opcionesArray,
                textoLibre: textoLibre,
                campoCondicional: campoCondicional
            )
            
            respuestasTyped[pregunta.id] = respuesta
            
            print("   ✓ Pregunta \(index + 1): \(pregunta.texto)")
            if !opcionesArray.isEmpty {
                print("     - Opciones: \(opcionesArray.joined(separator: ", "))")
            }
            if !textoLibre.isEmpty {
                print("     - Texto libre: \(textoLibre)")
            }
            if !campoCondicional.isEmpty {
                print("     - Campo condicional: \(campoCondicional)")
            }
        }
        
        // Mostrar loading
        self.isLoading = true
        
        // Llamar al servicio
        Task {
            print("\n🌐 [HomeView.Formulario] Iniciando envío al servidor...")
            
            let result = await Network.shared.postFichaClinicaGeneral(
                nombreFlujo: nombreFlujo,
                preguntas: formulario.preguntas,
                respuestas: respuestasTyped
            )
            
            await MainActor.run {
                self.isLoading = false
                
                switch result {
                case .success:
                    print("✅ [HomeView.Formulario] Ficha clínica enviada exitosamente")
                    
                    // Cerrar el modal
                    self.mostrarFormularioGeneral = false
                    
                    // Mostrar mensaje de éxito (opcional)
                    // Puedes agregar un @State para mostrar un alert
                    print("💾 [HomeView.Formulario] Modal cerrado y flag guardado")
                    
                case .failure(let error):
                    print("❌ [HomeView.Formulario] Error al enviar ficha clínica: \(error)")
                    
                    // En Android falla silenciosamente (el modal permanece abierto)
                    // Aquí puedes decidir si mostrar un alert o dejarlo así
                    // Por ahora solo logueamos y el modal permanece abierto
                    print("⚠️ [HomeView.Formulario] Modal permanece abierto (falla silenciosa)")
                }
            }
        }
    }
    
    func configView(){
        self.currentSubHome = []
        let currentStringSubHome = self.totalSubHomes.last ?? ""
        if currentStringSubHome.contains(";") {
            self.currentSubHome = self.totalSubHomes.last?.components(separatedBy: ";") ?? []
        } else {
            self.currentSubHome.append(currentStringSubHome)
        }
    }
}

// MARK: - Helper para aplicar detents sólo en iOS 16+
private extension View {
    @ViewBuilder
    func applySheetDetentsIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }
}

struct TilesView: View {
    
    @Binding var UIState: HomeUIState
    @Binding var UIStateAppoint: AppointmentUIStateModel
    
    @Binding var currentSubHome: [String]
    @Binding var totalSubHomes: [String]
    @Binding var tipeSubHome: [Int]
    
    
    @Binding var selectedTab: Tab
    
    @ObservedResults(FavoriteTasksTotal.self) var favoriteTasks
    
    var body: some View {
        
        VStack{
            PromotionsTile(UIState: $UIState)
            if tipeSubHome.last != nil && tipeSubHome.last == 3 {
                SecondBannerView(UIState: $UIState)
                
            }
            
            FirstComponentTile(UIState: $UIState,UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome, tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                .padding(.leading, .margin)
            if tipeSubHome.last != nil && (tipeSubHome.last == 2 || tipeSubHome.last == 3) {
                SecondTile(UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome, tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                    .padding(.leading, .margin)
            }
            if tipeSubHome.count == 0{
                AppointmentsTile(UIState: $UIState, UIStateAppoint: $UIStateAppoint)
            }
            if (tipeSubHome.last != nil && tipeSubHome.last == 3) || ((favoriteTasks.first?.records.first) != nil && totalSubHomes.count == 1){
                TaskTile(UIState: $UIState, UIStateAppoint: $UIStateAppoint, totalSubHomes: $totalSubHomes, currentSubHome: $currentSubHome, tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                    .padding(.leading, .margin)
            }
            Spacer()
        }
    }
    
}
