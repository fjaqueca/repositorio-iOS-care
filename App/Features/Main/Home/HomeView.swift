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
    @State private var waveRotation: Double = 0
    @State private var waveOpacity: Double = 0
    @State private var waveAlreadyPlayed: Bool = false

    var body: some View {
        NavigationViewCustom {
            ZStack{
                // CONTENIDO PRINCIPAL
                VStack(spacing: .margin * 2) {
                    VStack {
                        HStack{
                            if totalSubHomes.count > 1{
                                Button {
                                    HapticManager.impact(style: .light)
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
                            // Manita saludando animada (réplica de web: fade-in + wave-once)
                            if totalSubHomes.count == 1 {
                                Text("👋🏻")
                                    .font(.system(size: 24))
                                    .opacity(waveOpacity)
                                    .rotationEffect(.degrees(waveRotation), anchor: UnitPoint(x: 0.7, y: 0.7))
                                    .padding(.leading, 4)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, .margin)
                    
                    ScrollView(.vertical) {
                        TilesView(UIState: $UIState, UIStateAppoint: $UIStateAppoint, currentSubHome: $currentSubHome, totalSubHomes: $totalSubHomes, tipeSubHome: $tipeSubHome, selectedTab: $selectedTab)
                    }
                    .fadeSlideIn(delay: 0.05, from: .bottom)
                }
                .onReceive(AppStatusManager.onSelectedEnterprise) { newValue in
                    guard let newValue = newValue else { return }
                    if self.selectedEnterprise != newValue{
                        self.selectedEnterprise = newValue
                    }
                }
                .onChange(of: items){ newValue in
                    guard !newValue.isEmpty else { return }
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
            // FIX OPTIMIZACIÓN: antes este onAppear hacía DOS network calls
            // adicionales a getBrandAccount (uno via AppStatusManager y otro
            // directo) que eran idénticos al que ya hace AppView.fetchData().
            // Ahora:
            //   1. Si ya hay BrandAccount en Realm (cargado por fetchData), lo
            //      reutilizamos para buscar FormularioGeneral — cero network.
            //   2. checkFichaClinicaGeneralAndDecide corre en paralelo, no
            //      espera al BrandAccount (son independientes).
            // Resultado: 2 calls menos al backend y latencia mucho menor.
            Task { @MainActor in
                print("⏳ [HomeView] Iniciando aterrizaje en Home...")
                let t0 = Date()

                // Watchdog: si en 12s isLoading no se apagó (network muy lento,
                // call que se cuelga, etc.), forzamos la salida del estado loading
                // para que el usuario pueda interactuar con la app.
                let watchdog = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 12_000_000_000)
                    if !Task.isCancelled && self.isLoading {
                        print("⚠️ [HomeView] Watchdog 12s: forzando isLoading=false")
                        self.isLoading = false
                    }
                }

                // 1) Buscar FormularioGeneral en lo que ya hay en Realm (no
                //    requiere network). Si Realm aún no tiene datos, hacemos un
                //    fetch de respaldo en paralelo a la ficha clínica.
                async let fichaTask: Void = checkFichaClinicaGeneralAndDecide()

                if let cached = readBrandAccountFromRealm() {
                    print("✅ [HomeView] BrandAccount tomado de Realm (sin network)")
                    self.brandAccountResponse = cached
                    findFormularioGeneral(in: cached)
                } else if let agreementId = AppStatusManager.selectedEnterprise?.empresaC, !agreementId.isEmpty {
                    print("ℹ️ [HomeView] Realm sin BrandAccount aún → fetch de respaldo")
                    let result = await Network.shared.getBrandAccount(agreementId: agreementId)
                    if case let .success(brands) = result {
                        self.brandAccountResponse = brands
                        findFormularioGeneral(in: brands)
                    } else {
                        print("❌ [HomeView] Fetch de respaldo de BrandAccount falló")
                    }
                }

                await fichaTask
                watchdog.cancel()

                let elapsed = String(format: "%.2f", Date().timeIntervalSince(t0))
                print("✅ [HomeView] Aterrizaje completo en \(elapsed)s")

                // Red de seguridad: si por cualquier camino isLoading quedó en
                // true, lo apagamos acá para evitar blur pegado.
                if self.isLoading {
                    print("⚠️ [HomeView] Safety net: forzando isLoading=false")
                    self.isLoading = false
                }
            }
        }
        .onChange(of: mostrarFormularioGeneral) { newValue in
            // Sheet se cerró → disparar animación wave
            if !newValue && !waveAlreadyPlayed {
                waveAlreadyPlayed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    startWaveAnimation()
                }
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
    
    // MARK: - Wave Animation

    /// Réplica del patrón web: greeting-fade-in (0.55s delay, 0.3s) + wave-once (1s delay, 1.2s)
    /// @keyframes wave-once: 0%→0deg, 15%→14deg, 30%→-8deg, 45%→14deg, 60%→-4deg, 75%→10deg, 100%→0deg
    /// transform-origin: 70% 70% (pivote en la "muñeca")
    private func startWaveAnimation() {
        // Fase 1: fade-in a los 0.55s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeOut(duration: 0.3)) {
                waveOpacity = 1
            }
        }

        // Fase 2: wave-once a los 1.0s (duración total 1.2s, 6 keyframes)
        let waveStart: Double = 1.0
        let duration: Double = 1.2

        // 15% → 14deg
        DispatchQueue.main.asyncAfter(deadline: .now() + waveStart + duration * 0.15) {
            withAnimation(.easeInOut(duration: duration * 0.15)) {
                waveRotation = 14
            }
        }
        // 30% → -8deg
        DispatchQueue.main.asyncAfter(deadline: .now() + waveStart + duration * 0.30) {
            withAnimation(.easeInOut(duration: duration * 0.15)) {
                waveRotation = -8
            }
        }
        // 45% → 14deg
        DispatchQueue.main.asyncAfter(deadline: .now() + waveStart + duration * 0.45) {
            withAnimation(.easeInOut(duration: duration * 0.15)) {
                waveRotation = 14
            }
        }
        // 60% → -4deg
        DispatchQueue.main.asyncAfter(deadline: .now() + waveStart + duration * 0.60) {
            withAnimation(.easeInOut(duration: duration * 0.15)) {
                waveRotation = -4
            }
        }
        // 75% → 10deg
        DispatchQueue.main.asyncAfter(deadline: .now() + waveStart + duration * 0.75) {
            withAnimation(.easeInOut(duration: duration * 0.15)) {
                waveRotation = 10
            }
        }
        // 100% → 0deg
        DispatchQueue.main.asyncAfter(deadline: .now() + waveStart + duration) {
            withAnimation(.easeInOut(duration: duration * 0.25)) {
                waveRotation = 0
            }
        }
    }

    // MARK: - Lectura de BrandAccount desde Realm
    /// Retorna el `BrandAccounts` ya persistido localmente (sin network).
    /// Devuelve nil si Realm aún no tiene datos.
    private func readBrandAccountFromRealm() -> BrandAccounts? {
        do {
            let realm = try Realm(queue: nil)
            return realm.objects(BrandAccounts.self).first
        } catch {
            print("❌ [HomeView] No se pudo abrir Realm para leer BrandAccount: \(error.localizedDescription)")
            return nil
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

        // Si no hay formulario, animar la manita directamente
        if !finalDecision && !waveAlreadyPlayed {
            waveAlreadyPlayed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startWaveAnimation()
            }
        }
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
