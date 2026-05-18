//
//  AutomatedExamsView.swift
//  CareAssistance
//
//  Created by Care Assistance on 27/03/2026.
//

import SwiftUI
import SDWebImageSwiftUI
import RealmSwift

struct AutomatedExamsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var config: AutomatedExamsUIState
    @ObservedResults(User.self) var users


    @State private var cartItems: [ExamenItem] = []

    // Navigation / popup states
    @State private var selectedCategoria: CategoriaExamen?
    @State private var showDisclaimerPopup = false        // Paso 2
    @State private var showSeleccionExamenes = false       // Paso 4
    @State private var showCart = false                     // Paso 5
    @State private var showConfirmDatos = false             // Paso 6
    @State private var showConsentimiento = false           // Paso 7
    @State private var showConfirmEmail = false             // Paso 8
    @State private var showUpdatingEmail = false            // Loading entre Paso 8 y 9
    @State private var showExamenSinCosto = false           // Paso 9
    @State private var showGenerandoOrden = false           // Paso 10
    @State private var showExitoOrdenes = false             // Paso 11
    @State private var showSugerencia = false               // Error/no results

    // Loading states
    @State private var isLoadingExams = false
    @State private var confirmDatosIsLoading = false
    // Animacion bounce del carrito al agregar items
    @State private var cartBounceScale: CGFloat = 1.0
    // Animacion bounce del badge al cambiar cantidad
    @State private var badgeScale: CGFloat = 1.0

    // Examenes de la categoria seleccionada (para SeleccionarExamenesView)
    @State private var examenesCategoria: [ExamenItem] = []

    // Datos editados por el usuario en Paso 6
    @State private var editedNombre = ""
    @State private var editedApellido = ""
    @State private var editedFechaNacimiento = ""
    @State private var editedDireccion = ""
    @State private var datosConfirmados = false

    // Email editado en Paso 8
    @State private var editedEmail = ""

    // URL del PDF generado (Paso 10-11)
    @State private var urlOrdenMedicaPdf = ""
    @State private var isDownloadingPdf = false
    @State private var showWebView = false
    @State private var downloadedFileURL: URL?
    @State private var showConfetti: Bool = false

    // Datos del paciente desde ProfileCache (cargados en ExamsView via getProfileFields)
    @State private var accountFirstName = ""
    @State private var accountLastName = ""
    @State private var accountBirthdate = ""  // formato YYYY-MM-DD
    @State private var accountEmail = ""
    @State private var accountAddress = ""
    @State private var accountGender = ""     // HealthCloudGA__Gender__pc
    @State private var accountRut = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    // Patient info from Realm (fallback)
    private var currentUser: UserR? { users.first?.records.first }
    private var accountId: String { currentUser?.Id ?? "" }
    private var patientRut: String { currentUser?.RUT ?? AppStatusManager.rut ?? "" }

    // Datos del paciente: prioridad Account API > Realm
    private var patientFirstName: String { accountFirstName.isEmpty ? (currentUser?.FirstName ?? "") : accountFirstName }
    private var patientLastName: String { accountLastName.isEmpty ? (currentUser?.LastName ?? "") : accountLastName }
    private var patientEmail: String { accountEmail.isEmpty ? (currentUser?.PersonEmail ?? "") : accountEmail }
    private var patientAddress: String { accountAddress.isEmpty ? (currentUser?.BillingAddress?.street ?? "") : accountAddress }
    private var patientBirthdate: String { accountBirthdate }

    var body: some View {
        NavigationViewCustom {
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    Divider()
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            Spacer().frame(height: 1)

                            if !config.categoriasListaConfig.subtitulo.isEmpty {
                                let attr = config.categoriasListaConfig.subtituloAttr
                                let font = attr.font.isEmpty ? "FiraSans-Regular" : attr.font
                                let size = CGFloat(Int(attr.size) ?? 14)
                                let color = Color(hex: attr.color.isEmpty ? "#333F48" : attr.color)
                                parseSalesforceText(config.categoriasListaConfig.subtitulo, font: font, size: size, color: color)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, .margin)
                            }

                            categoriasGrid

                            Spacer(minLength: 80)
                        }
                    }
                }

                // Floating cart button
                if !cartItems.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            cartButton
                                .padding(.trailing, .margin)
                                .padding(.bottom, 20)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                // ══════════════════════════════════════════════════════
                // MARK: - Popup Overlays (in flow order)
                // ══════════════════════════════════════════════════════

                // PASO 2: Disclaimer popup (solo si categoria tiene tip)
                if showDisclaimerPopup, let cat = selectedCategoria {
                    ExamPopupView(
                        config: disclaimerPopupConfig(for: cat),
                        onAccept: {
                            print("✅ [Paso 2] Disclaimer ACEPTAR → buscarExamenes para \"\(cat.nombre)\"")
                            showDisclaimerPopup = false
                            buscarExamenesPorCategoria(for: cat)
                        },
                        onClose: {
                            print("❎ [Paso 2] Disclaimer CERRAR")
                            showDisclaimerPopup = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }

                // PASO 4: Seleccionar examenes de la categoria
                if showSeleccionExamenes, let cat = selectedCategoria {
                    SeleccionarExamenesView(
                        seleccionConfig: config.seleccionExamenes,
                        categoria: cat,
                        examenes: $examenesCategoria,
                        onAgregar: { selected in
                            print("🛒 [Paso 4] SeleccionarExamenes → AGREGAR AL CARRITO: \(selected.count) items")
                            for item in selected {
                                if !cartItems.contains(where: { $0.codigo == item.codigo }) {
                                    cartItems.append(item)
                                    print("   + \"\(item.nombre)\" codigo=\(item.codigo)")
                                } else {
                                    print("   ~ \"\(item.nombre)\" ya en carrito, omitido")
                                }
                            }
                            print("   Carrito total: \(cartItems.count) items")
                            let didAdd = !selected.isEmpty
                            // Cerrar modal con animación para que el botón flotante aparezca animado
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSeleccionExamenes = false
                            }
                            // Animacion bounce del carrito + badge (después de cerrar modal)
                            if didAdd {
                                badgeScale = 0.1
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    // Bounce del carrito entero
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)) {
                                        cartBounceScale = 1.35
                                        badgeScale = 1.4
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                                            cartBounceScale = 1.0
                                            badgeScale = 1.0
                                        }
                                    }
                                }
                            }
                        },
                        onCancelar: {
                            print("❎ [Paso 4] SeleccionarExamenes → CANCELAR")
                            showSeleccionExamenes = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }

                // PASO 6: Confirmar datos personales (editable)
                if showConfirmDatos {
                    PopupConfirmDatosView(
                        config: config.popupConfirmDatos,
                        onConfirm: { nombre, apellido, fechaNac, direccion, hasChanges in
                            print("✅ [Paso 6] ConfirmDatos → nombre=\"\(nombre)\" apellido=\"\(apellido)\" fecha=\"\(fechaNac)\" dir=\"\(direccion)\" cambios=\(hasChanges)")
                            editedNombre = nombre
                            editedApellido = apellido
                            editedFechaNacimiento = fechaNac
                            editedDireccion = direccion

                            if hasChanges {
                                print("🔄 [Paso 6] Hay cambios → mostrando loading y actualizando datos personales...")
                                confirmDatosIsLoading = true
                                updatePatientData(nombre: nombre, apellido: apellido, fechaNac: fechaNac, direccion: direccion)
                            } else {
                                print("ℹ️ [Paso 6] Sin cambios → directo a Consentimiento (Paso 7)")
                                showConfirmDatos = false
                                datosConfirmados = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    showConsentimiento = true
                                }
                            }
                        },
                        onClose: {
                            print("❎ [Paso 6] ConfirmDatos → CERRAR")
                            showConfirmDatos = false
                        },
                        isLoading: $confirmDatosIsLoading,
                        spinnerColor: config.validacion.colorSpinner,
                        originalNombre: patientFirstName,
                        originalApellido: patientLastName,
                        originalRut: patientRut,
                        originalFechaNacimiento: patientBirthdate,
                        originalDireccion: patientAddress
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }

                // PASO 7: Consentimiento informado (checkbox)
                if showConsentimiento {
                    PopupConsentimientoView(
                        config: config.popupConsentimiento,
                        onAccept: {
                            print("✅ [Paso 7] Consentimiento ACEPTAR → mostrando ConfirmEmail (Paso 8)")
                            showConsentimiento = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                showConfirmEmail = true
                            }
                        },
                        onCancel: {
                            print("❎ [Paso 7] Consentimiento CANCELAR → volver a categorias")
                            showConsentimiento = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }

                // PASO 8: Confirmar email
                if showConfirmEmail {
                    PopupConfirmEmailView(
                        config: config.popupEnviarEmail,
                        originalEmail: patientEmail,
                        onConfirm: { email, hasChanges in
                            print("✅ [Paso 8] ConfirmEmail → email=\"\(email)\" cambios=\(hasChanges)")
                            editedEmail = email
                            showConfirmEmail = false

                            if hasChanges {
                                print("🔄 [Paso 8] Email cambio → actualizando correo...")
                                updatePatientEmail(email: email)
                            } else {
                                print("ℹ️ [Paso 8] Email sin cambios → directo a ExamenSinCosto (Paso 9)")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    printPopupExamenSinCostoConfig()
                                    showExamenSinCosto = true
                                }
                            }
                        },
                        onClose: {
                            print("❎ [Paso 8] ConfirmEmail → CERRAR")
                            showConfirmEmail = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }

                // Loading: Actualizando email (entre Paso 8 y 9)
                if showUpdatingEmail {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(
                                    tint: Color(hex: config.validacion.colorSpinner.isEmpty ? "#00BBDC" : config.validacion.colorSpinner)
                                ))
                                .scaleEffect(1.8)
                            Text("Actualizando correo...")
                                .font(Font.custom("FiraSans-Medium", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .zIndex(30)
                }

                // PASO 9: Examen sin costo (ultima confirmacion)
                if showExamenSinCosto {
                    ExamPopupView(
                        config: config.popupExamenSinCosto,
                        onAccept: {
                            print("✅ [Paso 9] ExamenSinCosto → GENERAR ORDEN → mostrando loading (Paso 10)")
                            showExamenSinCosto = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                showGenerandoOrden = true
                                generateExamOrder()
                            }
                        },
                        onClose: {
                            print("❎ [Paso 9] ExamenSinCosto → CANCELAR → volver a categorias")
                            showExamenSinCosto = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }

                // PASO 10: Generando orden (dialog de carga dinamico desde Elemento 9)
                if showGenerandoOrden {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            // 9.6: Spinner circular animado con color dinámico
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(
                                    tint: Color(hex: config.popupCarga.colorSpinner.isEmpty ? "#00BBDC" : config.popupCarga.colorSpinner)
                                ))
                                .scaleEffect(1.8)

                            // Titulo
                            if !config.popupCarga.titulo.isEmpty {
                                let attr = config.popupCarga.tituloAttr
                                Text(config.popupCarga.titulo)
                                    .font(Font.custom(
                                        attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                                        size: CGFloat(Int(attr.size) ?? 18)
                                    ))
                                    .foregroundColor(Color(hex: attr.color.isEmpty ? "#333F48" : attr.color))
                                    .multilineTextAlignment(.center)
                            }

                            // Descripcion
                            if !config.popupCarga.descripcion.isEmpty {
                                let attr = config.popupCarga.descripcionAttr
                                Text(config.popupCarga.descripcion)
                                    .font(Font.custom(
                                        attr.font.isEmpty ? "FiraSans-Regular" : attr.font,
                                        size: CGFloat(Int(attr.size) ?? 14)
                                    ))
                                    .foregroundColor(Color(hex: attr.color.isEmpty ? "#333F48" : attr.color))
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 4)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 28)
                        .frame(maxWidth: 300)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                    }
                    .zIndex(30)
                }

                // PASO 11: Exito - orden generada
                if showExitoOrdenes {
                    exitoPopup
                        .transition(.opacity)
                        .zIndex(10)
                }

                // Error / sin resultados
                if showSugerencia {
                    ExamPopupView(
                        config: config.popupSugerencia,
                        onAccept: {
                            print("✅ [Sugerencia] ACEPTAR")
                            showSugerencia = false
                        },
                        onClose: {
                            print("❎ [Sugerencia] CERRAR")
                            showSugerencia = false
                        }
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }

                // Loading overlay con blur para busqueda de examenes
                if isLoadingExams {
                    Color.clear
                        .background(.ultraThinMaterial)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(
                                    tint: Color(hex: config.validacion.colorSpinner.isEmpty ? "#00BBDC" : config.validacion.colorSpinner)
                                ))
                                .scaleEffect(1.5)
                        )
                    .zIndex(20)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showDisclaimerPopup)
            .animation(.easeInOut(duration: 0.25), value: showSeleccionExamenes)
            .animation(.easeInOut(duration: 0.25), value: showConfirmDatos)
            .animation(.easeInOut(duration: 0.25), value: showConsentimiento)
            .animation(.easeInOut(duration: 0.25), value: showConfirmEmail)
            .animation(.easeInOut(duration: 0.25), value: showExamenSinCosto)
            .animation(.easeInOut(duration: 0.25), value: showGenerandoOrden)
            .animation(.easeInOut(duration: 0.25), value: showExitoOrdenes)
            .onChange(of: showExitoOrdenes) { visible in
                if !visible {
                    print("🧹 [Carrito] Limpiando carrito tras cerrar dialog de éxito")
                    cartItems.removeAll()
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showSugerencia)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    let attr = config.categoriasListaConfig.tituloAttr
                    Text(config.categoriasListaConfig.titulo.isEmpty ? "Generar Examenes" : config.categoriasListaConfig.titulo)
                        .font(Font.custom(
                            attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                            size: CGFloat(Int(attr.size) ?? 18)
                        ))
                        .foregroundColor(Color(hex: attr.color.isEmpty ? "#000000" : attr.color))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        HapticManager.impact(style: .light)
                        dismiss()
                    } label: {
                        Image("back")
                            .renderingMode(.template)
                            .foregroundColor(Color(hex: config.backArrowColorSeccion))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.impact(style: .medium)
                        print("🛒 [Paso 5] Click icono carrito → items: \(cartItems.count)")
                        logCarritoConfig()
                        if !cartItems.isEmpty {
                            showCart = true
                        }
                    } label: {
                        ZStack {
                            // Área invisible para dar espacio y evitar recorte
                            Color.clear
                                .frame(width: 56, height: 66)

                            Image(systemName: "cart.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: config.carrito.carritoColor.isEmpty ? "#00BBDC" : config.carrito.carritoColor))
                                .offset(y: 4)

                            if !cartItems.isEmpty {
                                Text("\(cartItems.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .scaleEffect(badgeScale)
                                    .offset(x: 14, y: -6)
                            }
                        }
                        .scaleEffect(cartBounceScale)
                    }
                }
            }
            .fullScreenCover(isPresented: $showCart) {
                CarritoExamView(
                    carritoConfig: config.carrito,
                    backArrowColor: config.backArrowColorSeccion,
                    cartItems: $cartItems,
                    onVerResumen: {
                        print("🛒 [Paso 5→6] Carrito → VER RESUMEN / CONFIRMAR DATOS PERSONALES")
                        print("   Items en carrito: \(cartItems.count)")
                        for (i, item) in cartItems.enumerated() {
                            print("   [\(i)] \"\(item.nombre)\" codigo=\(item.codigo)")
                        }
                        showCart = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            logConfirmDatosConfig()
                            showConfirmDatos = true
                        }
                    },
                    onLimpiarTodo: {
                        print("🛒 [Paso 5] Carrito → LIMPIAR TODO")
                        withAnimation { cartItems.removeAll() }
                    },
                    onDismiss: {
                        print("🛒 [Paso 5] Carrito → CERRAR (volver a categorias)")
                        showCart = false
                    }
                )
            }
            .sheet(isPresented: $showWebView) {
                if let fileURL = downloadedFileURL {
                    WebView(url: fileURL)
                }
            }
            .confetti(isActive: $showConfetti)
            .configureNavigation()
            .onAppear {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🏥 [AutomatedExamsView] VISTA CARGADA - Generar Examenes")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔹 Titulo: \"\(config.categoriasListaConfig.titulo)\"")
                print("🔹 Subtitulo: \"\(config.categoriasListaConfig.subtitulo.prefix(80))\"")
                print("🔹 BackArrowColor: \(config.categoriasListaConfig.backArrowColor)")
                print("🔹 CarritoColor: \(config.carrito.carritoColor)")
                print("🔹 Categorias: \(config.categorias.count)")
                for (i, cat) in config.categorias.enumerated() {
                    print("   Cat[\(i)]: \"\(cat.nombre)\" claveApi=\(cat.claveApi) tituloTip=\"\(cat.tituloTip)\" descTip=\"\(cat.descripcionTip.prefix(40))\"")
                }
                print("🔹 Validacion: pais=\"\(config.validacion.paisExamen)\" tipo=\"\(config.validacion.tipoExamen)\"")
                print("🔹 Paciente: accountId=\"\(accountId)\" nombre=\"\(patientFirstName) \(patientLastName)\" rut=\"\(patientRut)\" email=\"\(patientEmail)\"")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
                loadAccountData()
            }
        }
    }

    // MARK: - Categorias Grid
    private var categoriasGrid: some View {
        Group {
            if config.categorias.isEmpty {
                VStack(spacing: 12) {
                    // TEMPORAL: Lottie Empty_Box deshabilitado, se restaura icono SF Symbol.
                    // Para reactivar, comenta el Image y descomenta el LottieView.
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(Color(.systemGray3))
                    // LottieView(animationName: "Empty_Box")
                    //     .frame(width: 180, height: 180)
                    Text("No hay categorías disponibles")
                        .font(Font.custom("FiraSans-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)
                .popIn()
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(config.categorias) { categoria in
                        categoriaCard(categoria)
                    }
                }
                .padding(.horizontal, .margin)
            }
        }
    }

    // MARK: - Categoria Card
    private func categoriaCard(_ categoria: CategoriaExamen) -> some View {
        Button {
            HapticManager.selection()
            onCategoriaClick(categoria)
        } label: {
            if !categoria.iconURL.isEmpty, let url = URL(string: categoria.iconURL) {
                WebImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 85, height: 105)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 85, height: 105)
                        .overlay(ProgressView().scaleEffect(0.7))
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 85, height: 105)
                    .overlay(
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Floating Cart Button
    private var cartButton: some View {
        Button {
            HapticManager.impact(style: .medium)
            print("🛒 [Paso 5] Click boton flotante carrito → items: \(cartItems.count)")
            logCarritoConfig()
            showCart = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color(hex: config.carrito.carritoColor.isEmpty ? "#00BBDC" : config.carrito.carritoColor))
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .overlay(
                        Image(systemName: "cart.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    )

                Text("\(cartItems.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.red)
                    .clipShape(Circle())
                    .scaleEffect(badgeScale)
                    .offset(x: 4, y: -4)
            }
            .scaleEffect(cartBounceScale)
        }
    }

    // MARK: - Exito Popup (Paso 11)
    private var exitoPopup: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showExitoOrdenes = false
                }

            VStack(spacing: 16) {
                // Icono
                if !config.popupExamenRealizado.iconURL.isEmpty, let url = URL(string: config.popupExamenRealizado.iconURL) {
                    WebImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                }

                // Titulo
                if !config.popupExamenRealizado.titulo.isEmpty {
                    let attr = config.popupExamenRealizado.tituloAttr
                    Text(config.popupExamenRealizado.titulo)
                        .font(Font.custom(
                            attr.font.isEmpty ? "FiraSans-Bold" : attr.font,
                            size: CGFloat(Int(attr.size) ?? 18)
                        ))
                        .foregroundColor(Color(hex: attr.color.isEmpty ? "#333F48" : attr.color))
                        .multilineTextAlignment(.center)
                }

                // Descripcion (soporta **negrita** y <br> saltos de linea)
                if !config.popupExamenRealizado.descripcion.isEmpty {
                    let attr = config.popupExamenRealizado.descripcionAttr
                    let font = attr.font.isEmpty ? "FiraSans-Regular" : attr.font
                    let size = CGFloat(Int(attr.size) ?? 14)
                    let color = Color(hex: attr.color.isEmpty ? "#333F48" : attr.color)
                    parseSalesforceText(config.popupExamenRealizado.descripcion, font: font, size: size, color: color)
                        .multilineTextAlignment(.center)
                }

                // Botones: Volver al Home + Descargar Documento
                HStack(spacing: 12) {
                    // Boton Volver al Home (solo cierra el dialog)
                    Button {
                        HapticManager.impact(style: .light)
                        print("🏠 [Paso 11] Volver al Home → cerrando dialog")
                        showExitoOrdenes = false
                    } label: {
                        let btn = config.popupExamenRealizado.btnCerrar
                        Text(btn.texto.isEmpty ? "Volver al Home" : btn.texto)
                            .font(Font.custom("FiraSans-Medium", size: 14))
                            .foregroundColor(Color(hex: btn.colorTexto.isEmpty ? "#666666" : btn.colorTexto))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: btn.colorFondo.isEmpty ? "#E0E0E0" : btn.colorFondo))
                            .cornerRadius(8)
                    }

                    // Boton Descargar Documento (oculto si URL vacía, como Android)
                    if !urlOrdenMedicaPdf.isEmpty {
                        Button {
                            HapticManager.impact(style: .medium)
                            downloadExamPdf()
                        } label: {
                            let btn = config.popupExamenRealizado.btnAceptar
                            let txtColor = !btn.colorTextoActivo.isEmpty ? btn.colorTextoActivo : (!btn.colorTexto.isEmpty ? btn.colorTexto : "#FFFFFF")
                            let bgColor = !btn.colorFondoActivo.isEmpty ? btn.colorFondoActivo : (!btn.colorFondo.isEmpty ? btn.colorFondo : "#00BBDC")
                            Text(btn.texto.isEmpty ? "Descargar Documento" : btn.texto)
                                .font(Font.custom("FiraSans-Medium", size: 14))
                                .foregroundColor(Color(hex: txtColor))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: bgColor))
                                .cornerRadius(8)
                        }
                        .disabled(isDownloadingPdf)
                        .opacity(isDownloadingPdf ? 0.6 : 1.0)
                    }
                }

                // Loading de descarga
                if isDownloadingPdf {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(
                            tint: Color(hex: config.validacion.colorSpinner.isEmpty ? "#00BBDC" : config.validacion.colorSpinner)
                        ))
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.horizontal, 32)
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Descarga PDF (misma logica que ordenes de examenes)

    /// Descarga el PDF de la orden usando S3FileHelper + getPresignedUrl (igual que MedicalExamsDetailsView)
    private func downloadExamPdf() {
        let rawUrl = urlOrdenMedicaPdf

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📥 [Paso 11] DESCARGAR DOCUMENTO")
        print("   rawUrl: \(rawUrl)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        guard !rawUrl.isEmpty else {
            print("❌ [Paso 11] URL vacía, no se puede descargar")
            return
        }

        isDownloadingPdf = true

        let fileName = S3FileHelper.extractFileNameFromUrl(rawUrl)
        let objectKey = S3FileHelper.extractObjectKeyFromUrl(rawUrl)

        print("   fileName: \(fileName)")
        print("   objectKey: \(objectKey)")

        // Verificar cache local
        if let cachedFileUrl = S3FileHelper.getCachedFileUrl(fileName: fileName) {
            print("✅ [Paso 11] Archivo encontrado en caché, abriendo directamente")
            isDownloadingPdf = false
            downloadedFileURL = cachedFileUrl
            showWebView = true
            return
        }

        print("📥 [Paso 11] Archivo NO en caché, llamando a getPresignedUrl...")

        Task { @MainActor in
            let result = await Network.shared.getPresignedUrl(objectKey: objectKey, filename: fileName)
            switch result {
            case let .success(response):
                print("✅ [Paso 11] Respuesta getPresignedUrl:")
                print("   url: \(response.url?.prefix(80) ?? "nil")...")
                print("   error: \(response.error)")
                print("   message: \(response.message ?? "nil")")

                guard let presignedUrl = response.url, !response.error else {
                    print("❌ [Paso 11] Respuesta con error o sin URL")
                    isDownloadingPdf = false
                    return
                }

                do {
                    print("📥 [Paso 11] Descargando archivo desde URL pre-firmada...")
                    let localFileUrl = try await S3FileHelper.downloadAndSave(from: presignedUrl, fileName: fileName)
                    print("✅ [Paso 11] Archivo descargado y guardado: \(localFileUrl.path)")
                    isDownloadingPdf = false
                    downloadedFileURL = localFileUrl
                    showWebView = true
                } catch {
                    print("❌ [Paso 11] Error al descargar archivo: \(error.localizedDescription)")
                    isDownloadingPdf = false
                }

            case let .failure(error):
                print("❌ [Paso 11] Error en getPresignedUrl:")
                print("   id: \(error.id)")
                print("   name: \(error.name)")
                print("   message: \(error.message)")
                isDownloadingPdf = false
            }
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Debug Logging

    /// Imprime la configuracion dinamica del Popup ExamenSinCosto (Elemento 7 - PopUpExamenSinCosto)
    private func printPopupExamenSinCostoConfig() {
        let popup = config.popupExamenSinCosto
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [PopupExamenSinCosto] CONFIGURACION DINAMICA (Elemento 7 - PopUpExamenSinCosto)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   iconURL: \"\(popup.iconURL.isEmpty ? "(vacio)" : String(popup.iconURL.prefix(80)))\"")
        print("   titulo: \"\(popup.titulo)\"")
        print("   tituloAttr: font=\(popup.tituloAttr.font) size=\(popup.tituloAttr.size) color=\(popup.tituloAttr.color)")
        print("   descripcion: \"\(popup.descripcion.prefix(80))\"")
        print("   descripcionAttr: font=\(popup.descripcionAttr.font) size=\(popup.descripcionAttr.size) color=\(popup.descripcionAttr.color)")
        let btnA = popup.btnAceptar
        let txtColorResolved = !btnA.colorTextoActivo.isEmpty ? btnA.colorTextoActivo : (!btnA.colorTexto.isEmpty ? btnA.colorTexto : "#FFFFFF")
        let bgColorResolved = !btnA.colorFondoActivo.isEmpty ? btnA.colorFondoActivo : (!btnA.colorFondo.isEmpty ? btnA.colorFondo : "#00BBDC")
        print("   btnAceptar: texto=\"\(btnA.texto)\" colorTexto=\(btnA.colorTexto) colorFondo=\(btnA.colorFondo) colorTextoActivo=\(btnA.colorTextoActivo) colorFondoActivo=\(btnA.colorFondoActivo)")
        print("   btnAceptar [resolved]: txtColor=\(txtColorResolved) bgColor=\(bgColorResolved)")
        print("   btnCerrar: texto=\"\(popup.btnCerrar.texto)\" colorTexto=\(popup.btnCerrar.colorTexto) colorFondo=\(popup.btnCerrar.colorFondo)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    /// Imprime la configuracion dinamica del Popup Exito (Elemento 9 - PopUpExamenRealizado)
    private func printPopupExitoConfig() {
        let popup = config.popupExamenRealizado
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [PopupExitoOrden] CONFIGURACION DINAMICA (Elemento 9 - PopUpExamenRealizado)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   iconURL: \"\(popup.iconURL.isEmpty ? "(vacio)" : String(popup.iconURL.prefix(80)))\"")
        print("   titulo: \"\(popup.titulo)\"")
        print("   tituloAttr: font=\(popup.tituloAttr.font) size=\(popup.tituloAttr.size) color=\(popup.tituloAttr.color)")
        print("   descripcion: \"\(popup.descripcion.prefix(80))\"")
        print("   descripcionAttr: font=\(popup.descripcionAttr.font) size=\(popup.descripcionAttr.size) color=\(popup.descripcionAttr.color)")
        let btnA = popup.btnAceptar
        let txtColorResolved = !btnA.colorTextoActivo.isEmpty ? btnA.colorTextoActivo : (!btnA.colorTexto.isEmpty ? btnA.colorTexto : "#FFFFFF")
        let bgColorResolved = !btnA.colorFondoActivo.isEmpty ? btnA.colorFondoActivo : (!btnA.colorFondo.isEmpty ? btnA.colorFondo : "#00BBDC")
        print("   btnAceptar: texto=\"\(btnA.texto)\" colorTexto=\(btnA.colorTexto) colorFondo=\(btnA.colorFondo) colorTextoActivo=\(btnA.colorTextoActivo) colorFondoActivo=\(btnA.colorFondoActivo)")
        print("   btnAceptar [resolved]: txtColor=\(txtColorResolved) bgColor=\(bgColorResolved)")
        print("   btnCerrar: texto=\"\(popup.btnCerrar.texto)\" colorTexto=\(popup.btnCerrar.colorTexto) colorFondo=\(popup.btnCerrar.colorFondo)")
        print("")
        print("   PDF URL: \"\(urlOrdenMedicaPdf.isEmpty ? "(vacio)" : String(urlOrdenMedicaPdf.prefix(80)))\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    /// Carga datos completos del paciente desde getDefaultAgreement (function_filter → Account)
    private func loadAccountData() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📦 [AutomatedExams] Cargando datos del paciente desde ProfileCache")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // Leer datos desde ProfileCache (previamente guardados en ExamsView via getProfileFields)
        accountFirstName = ProfileCache.firstName
        accountLastName = ProfileCache.lastName
        accountBirthdate = ProfileCache.birthdate
        accountEmail = ProfileCache.email
        accountAddress = ProfileCache.address
        accountGender = ProfileCache.gender
        accountRut = ProfileCache.rut.isEmpty ? patientRut : ProfileCache.rut

        print("   [Cache] firstName: \"\(accountFirstName)\"")
        print("   [Cache] lastName: \"\(accountLastName)\"")
        print("   [Cache] birthdate: \"\(accountBirthdate)\"")
        print("   [Cache] email: \"\(accountEmail)\"")
        print("   [Cache] address: \"\(accountAddress)\"")
        print("   [Cache] gender: \"\(accountGender)\"")
        print("   [Cache] rut: \"\(accountRut)\"")

        // Log de variables computadas (prioridad API > Realm)
        print("   [Computed] patientFirstName: \"\(patientFirstName)\"")
        print("   [Computed] patientLastName: \"\(patientLastName)\"")
        print("   [Computed] patientEmail: \"\(patientEmail)\"")
        print("   [Computed] patientAddress: \"\(patientAddress)\"")
        print("   [Computed] patientBirthdate: \"\(patientBirthdate)\"")
        print("   [Computed] patientRut: \"\(patientRut)\"")

        // Alertar si algun campo critico esta vacio
        if accountFirstName.isEmpty { print("   ⚠️ firstName vacio - se usara Realm fallback: \"\(currentUser?.FirstName ?? "nil")\"") }
        if accountLastName.isEmpty { print("   ⚠️ lastName vacio - se usara Realm fallback: \"\(currentUser?.LastName ?? "nil")\"") }
        if accountBirthdate.isEmpty { print("   ⚠️ birthdate vacio - no hay fallback de Realm para este campo") }
        if accountEmail.isEmpty { print("   ⚠️ email vacio - se usara Realm fallback: \"\(currentUser?.PersonEmail ?? "nil")\"") }
        if accountGender.isEmpty { print("   ⚠️ gender vacio - necesario para filtro de examenes por sexo") }

        // Alimentar validacion con sexo y edad del paciente para filtrar exámenes
        // Sexo: ProfileCache devuelve "Hombre"/"Mujer", Salesforce Sexo__c usa "Mujer"/"Ambos"
        config.validacion.sexoPaciente = accountGender
        print("   [Validacion] sexoPaciente = \"\(config.validacion.sexoPaciente)\"")

        // Edad: calcular a partir de birthdate (formato yyyy-MM-dd)
        if !accountBirthdate.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let birthDate = formatter.date(from: accountBirthdate) {
                let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
                config.validacion.edadPaciente = age
            }
        }
        print("   [Validacion] edadPaciente = \(config.validacion.edadPaciente)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
    }

    private func logConfirmDatosConfig() {
        let p = config.popupConfirmDatos
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [CONFIRM DATOS] Datos del paciente (valores que se setean en el modal):")
        print("   originalNombre          = \"\(patientFirstName)\"")
        print("   originalApellido        = \"\(patientLastName)\"")
        print("   originalRut             = \"\(patientRut)\"")
        print("   originalFechaNacimiento = \"\(patientBirthdate)\"")
        print("   originalDireccion       = \"\(patientAddress)\"")
        print("   originalEmail           = \"\(patientEmail)\"")
        print("   accountGender           = \"\(accountGender)\"")
        print("   ─── Fuentes de datos ───")
        print("   accountFirstName (API)  = \"\(accountFirstName)\"")
        print("   accountLastName (API)   = \"\(accountLastName)\"")
        print("   accountBirthdate (API)  = \"\(accountBirthdate)\"")
        print("   accountEmail (API)      = \"\(accountEmail)\"")
        print("   accountAddress (API)    = \"\(accountAddress)\"")
        print("   Realm FirstName         = \"\(currentUser?.FirstName ?? "(nil)")\"")
        print("   Realm LastName          = \"\(currentUser?.LastName ?? "(nil)")\"")
        print("   Realm PersonEmail       = \"\(currentUser?.PersonEmail ?? "(nil)")\"")
        print("   Realm BillingStreet     = \"\(currentUser?.BillingAddress?.street ?? "(nil)")\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📋 [CONFIRM DATOS] Config dinámica Elemento 5 (estilos del popup):")
        print("   iconURL                = \"\(p.iconURL.prefix(60))\"")
        print("   titulo                 = \"\(p.titulo)\"")
        print("   tituloAttr             = font:\"\(p.tituloAttr.font)\" size:\"\(p.tituloAttr.size)\" color:\"\(p.tituloAttr.color)\" align:\"\(p.tituloAttr.alignment)\"")
        print("   descripcion            = \"\(p.descripcion.prefix(80))\"")
        print("   descripcionAttr        = font:\"\(p.descripcionAttr.font)\" size:\"\(p.descripcionAttr.size)\" color:\"\(p.descripcionAttr.color)\" align:\"\(p.descripcionAttr.alignment)\"")
        print("   labelAttr              = font:\"\(p.labelAttr.font)\" size:\"\(p.labelAttr.size)\" color:\"\(p.labelAttr.color)\" align:\"\(p.labelAttr.alignment)\"")
        print("   respuestaAttr          = font:\"\(p.respuestaAttr.font)\" size:\"\(p.respuestaAttr.size)\" color:\"\(p.respuestaAttr.color)\" align:\"\(p.respuestaAttr.alignment)\"")
        print("   btnAceptar             = texto:\"\(p.btnAceptar.texto)\" colorTexto:\"\(p.btnAceptar.colorTexto)\" colorFondo:\"\(p.btnAceptar.colorFondo)\"")
        print("   btnAceptar activo      = colorTexto:\"\(p.btnAceptar.colorTextoActivo)\" colorFondo:\"\(p.btnAceptar.colorFondoActivo)\"")
        print("   btnAceptar inactivo    = colorTexto:\"\(p.btnAceptar.colorTextoInactivo)\" colorFondo:\"\(p.btnAceptar.colorFondoInactivo)\"")
        print("   btnCerrar              = texto:\"\(p.btnCerrar.texto)\" colorTexto:\"\(p.btnCerrar.colorTexto)\" colorFondo:\"\(p.btnCerrar.colorFondo)\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    private func logCarritoConfig() {
        let c = config.carrito
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🛒 [CARRITO CONFIG] Variables dinámicas del Elemento 5 (Custom):")
        print("   [5.1] titulo               = \"\(c.titulo)\"")
        print("   [5.2] tituloAttr           = font:\"\(c.tituloAttr.font)\" size:\"\(c.tituloAttr.size)\" color:\"\(c.tituloAttr.color)\"")
        print("   [5.3] carritoColor         = \"\(c.carritoColor)\"")
        print("   [5.4] sinExamenesTexto     = \"\(c.sinExamenesTexto)\"")
        print("   [5.5] sinExamenesAttr      = font:\"\(c.sinExamenesAttr.font)\" size:\"\(c.sinExamenesAttr.size)\" color:\"\(c.sinExamenesAttr.color)\"")
        print("   [5.6] totalExamenesTexto   = \"\(c.totalExamenesTexto)\"")
        print("   [5.7] totalExamenesAttr    = font:\"\(c.totalExamenesAttr.font)\" size:\"\(c.totalExamenesAttr.size)\" color:\"\(c.totalExamenesAttr.color)\"")
        print("   [5.8] categoriaAttr        = font:\"\(c.categoriaAttr.font)\" size:\"\(c.categoriaAttr.size)\" color:\"\(c.categoriaAttr.color)\" colorFondo:\"\(c.categoriaAttr.colorFondo)\"")
        print("   [5.9] nombresExamenesAttr  = font:\"\(c.nombresExamenesAttr.font)\" size:\"\(c.nombresExamenesAttr.size)\" color:\"\(c.nombresExamenesAttr.color)\"")
        print("   [5.10] cantidadAttr        = font:\"\(c.cantidadAttr.font)\" size:\"\(c.cantidadAttr.size)\" color:\"\(c.cantidadAttr.color)\"")
        print("   [5.11] basureroColor       = \"\(c.basureroColor)\"")
        print("   [5.12] btnVerResumen       = texto:\"\(c.btnVerResumen.texto)\" font:\"\(c.btnVerResumen.font)\" size:\"\(c.btnVerResumen.size)\" colorTexto:\"\(c.btnVerResumen.colorTexto)\" colorFondo:\"\(c.btnVerResumen.colorFondo)\"")
        print("   [5.13] btnLimpiar          = texto:\"\(c.btnLimpiar.texto)\" font:\"\(c.btnLimpiar.font)\" size:\"\(c.btnLimpiar.size)\" colorTexto:\"\(c.btnLimpiar.colorTexto)\" colorHover:\"\(c.btnLimpiar.colorHover)\"")
        print("   [12.7] antesDeContinuar    = \"\(c.antesDeContinuarTexto)\"")
        print("   [12.8] subAntesDeContinuar = \"\(c.subAntesDeContinuarTexto)\"")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    // MARK: - Flow Logic
    // ══════════════════════════════════════════════════════

    /// PASO 1: Click en categoria
    /// Si tiene tituloTip o descripcionTip → mostrar disclaimer (Paso 2)
    /// Si NO tiene tip → saltar directo a buscar examenes (Paso 3)
    private func onCategoriaClick(_ categoria: CategoriaExamen) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👆 [Paso 1] CATEGORIA SELECCIONADA")
        print("   nombre: \"\(categoria.nombre)\"")
        print("   claveApi: \(categoria.claveApi)")
        print("   tituloTip: \"\(categoria.tituloTip)\"")
        print("   descripcionTip: \"\(categoria.descripcionTip.prefix(60))\"")

        selectedCategoria = categoria

        let hasTip = !categoria.tituloTip.isEmpty || !categoria.descripcionTip.isEmpty
        if hasTip {
            print("   → Tiene tip → mostrando Disclaimer (Paso 2)")
            showDisclaimerPopup = true
        } else {
            print("   → NO tiene tip → directo a buscarExamenes (Paso 3)")
            buscarExamenesPorCategoria(for: categoria)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")
    }

    /// Builds disclaimer popup config using popupCategorias + categoria's tip data
    private func disclaimerPopupConfig(for cat: CategoriaExamen) -> PopupExamConfig {
        var popup = config.popupCategorias
        if !cat.tituloTip.isEmpty {
            popup.titulo = cat.tituloTip
        }
        if !cat.descripcionTip.isEmpty {
            popup.descripcion = cat.descripcionTip
        }
        return popup
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Network Calls
    // ══════════════════════════════════════════════════════

    /// PASO 3: Busca examenes por categoria via function_filter + filtra por sexo/edad
    private func buscarExamenesPorCategoria(for categoria: CategoriaExamen) {
        // Convertir claveApi a formato Salesforce: "Categoria1" → "Categoria_1__c"
        let claveApi = categoria.claveApi
        let salesforceKey: String = {
            // Si ya viene con formato __c, usarlo tal cual
            if claveApi.hasSuffix("__c") { return claveApi }
            // Insertar _ antes del numero: "Categoria1" → "Categoria_1"
            var result = ""
            for char in claveApi {
                if char.isNumber && !result.isEmpty && result.last.map({ !$0.isNumber }) == true {
                    result += "_"
                }
                result.append(char)
            }
            return result + "__c"
        }()

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 [Paso 3] BUSCAR EXAMENES via function_filter")
        print("   Categoria: \"\(categoria.nombre)\"")
        print("   ClaveApi original: \(claveApi)")
        print("   Salesforce key: \(salesforceKey)")
        print("   PaisExamen: \"\(config.validacion.paisExamen)\"")
        print("   TipoExamen: \"\(config.validacion.tipoExamen)\"")
        print("🔄 Enviando request a function_filter...")

        isLoadingExams = true
        Task {
            let result = await Network.shared.searchAutomatedExams(
                categoriaKey: salesforceKey,
                paisExamen: config.validacion.paisExamen,
                tipoExamen: config.validacion.tipoExamen
            )

            await MainActor.run {
                isLoadingExams = false
                switch result {
                case .success(let response):
                    print("✅ [Paso 3] buscarExamenesPorCategoria EXITO - function_filter")

                    // Extraer examenes del response: data[0]["Lista_Examenes_Automaticos__c"]
                    var rawRecords: [AutomatedExamRecord] = []
                    if let dataArray = response.data, let firstItem = dataArray.first {
                        for (key, records) in firstItem {
                            print("   Key en response: \"\(key)\" → \(records.count) records")
                            rawRecords = records
                        }
                    }

                    print("   StatusCode: \(response.statusCode ?? -1)")
                    print("   Examenes crudos del servidor: \(rawRecords.count)")
                    for (i, rec) in rawRecords.enumerated() {
                        print("   [\(i)] Id=\(rec.Id) Name=\(rec.Name ?? "") NombreExamen=\"\(rec.Nombre_Examen__c ?? "")\" Sexo=\"\(rec.Sexo__c ?? "")\" Pais=\"\(rec.Pais_Examen__c ?? "")\" Tipo=\"\(rec.Tipo_de_Examen__c ?? "")\" EdadRango=\(rec.Edad_Inicio__c ?? "0")-\(rec.Edad_Fin__c ?? "999")")
                    }

                    // Filtrar por sexo y edad del usuario
                    let filteredRecords = filterExamsByProfile(rawRecords)
                    print("   Examenes post-filtro perfil: \(filteredRecords.count)")

                    if !filteredRecords.isEmpty {
                        // Extraer numero de categoria desde claveApi: "Categoria_1__c" → 1
                        let catNum: Int = {
                            let digits = salesforceKey.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            return Int(digits) ?? 0
                        }()

                        // Convertir a ExamenItem, marcando los que ya estan en carrito
                        examenesCategoria = filteredRecords.map { rec in
                            let isAlreadyInCart = cartItems.contains(where: { $0.codigo == rec.Id })
                            return ExamenItem(
                                nombre: rec.Nombre_Examen__c ?? rec.Name ?? "Sin nombre",
                                codigo: rec.Id,
                                name: rec.Name ?? "",
                                sexo: rec.Sexo__c ?? "Ambos",
                                edadInicio: Int(rec.Edad_Inicio__c ?? "") ?? 0,
                                edadFin: Int(rec.Edad_Fin__c ?? "") ?? 999,
                                categoria: categoria.nombre,
                                categoriaNum: catNum,
                                isSelected: isAlreadyInCart,
                                isInCart: isAlreadyInCart
                            )
                        }
                        for (i, item) in examenesCategoria.enumerated() {
                            print("   Item[\(i)]: \"\(item.nombre)\" inCart=\(item.isInCart)")
                        }
                        print("   → Mostrando SeleccionarExamenes (Paso 4)")
                        showSeleccionExamenes = true
                    } else {
                        print("   ⚠️ No hay examenes tras filtrar por perfil")
                        print("   → Mostrando ModalSeleccionExamenes con estado vacío")
                        let sel = config.seleccionExamenes
                        print("   📋 [Elemento 6] Config para estado vacío:")
                        print("      sinExamenesTexto: \"\(sel.sinExamenesTexto)\"")
                        print("      sinExamenesAttr: font=\(sel.sinExamenesAttr.font) size=\(sel.sinExamenesAttr.size) color=\(sel.sinExamenesAttr.color)")
                        print("      tituloCategoriaAttr: font=\(sel.tituloCategoriaAttr.font) size=\(sel.tituloCategoriaAttr.size) color=\(sel.tituloCategoriaAttr.color)")
                        print("      btnCancelar: texto=\"\(sel.btnCancelar.texto)\" colorTexto=\(sel.btnCancelar.colorTexto) colorFondo=\(sel.btnCancelar.colorFondo)")
                        examenesCategoria = []
                        showSeleccionExamenes = true
                    }

                case .failure(let error):
                    print("❌ [Paso 3] buscarExamenesPorCategoria ERROR")
                    print("   Error: \(error.name) - \(error.message)")
                    print("   → Mostrando PopupSugerencia")
                    showSugerencia = true
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
            }
        }
    }

    /// Filtra examenes por sexo y edad del usuario (replica filtrarExamenesPorPerfil de Android)
    /// Lee directamente de ProfileCache/accountGender/accountBirthdate en vez de config.validacion
    /// para evitar problemas de timing con @Binding
    private func filterExamsByProfile(_ records: [AutomatedExamRecord]) -> [AutomatedExamRecord] {
        // Sexo: leer de accountGender (@State local) o ProfileCache como fallback
        let userSexo = accountGender.isEmpty ? ProfileCache.gender : accountGender

        // Edad: calcular desde accountBirthdate o ProfileCache
        let birthStr = accountBirthdate.isEmpty ? ProfileCache.birthdate : accountBirthdate
        var userEdad = 0
        if !birthStr.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let birthDate = formatter.date(from: birthStr) {
                userEdad = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
            }
        }

        let total = records.count
        print("   🔬 Filtrando por perfil - Sexo: '\(userSexo.isEmpty ? "N/A" : userSexo)', Edad: \(userEdad)")

        let filtered = records.filter { record in
            // Filtro por sexo: si el examen es para un sexo especifico y no coincide, excluir
            if !userSexo.isEmpty {
                let examSexo = record.Sexo__c ?? "Ambos"
                if examSexo != "Ambos" && examSexo != userSexo {
                    print("      Excluido por sexo: \(record.Nombre_Examen__c ?? "(sin nombre)")")
                    return false
                }
            }

            // Filtro por edad: solo filtra si edadUsuario > 0
            // Si el campo no viene (nil/vacío), no restringe
            if userEdad > 0 {
                let edadInicio = Double(record.Edad_Inicio__c ?? "") ?? -1
                let edadFin = Double(record.Edad_Fin__c ?? "") ?? -1
                if edadInicio > 0 && Double(userEdad) < edadInicio {
                    print("      Excluido por edad: \(record.Nombre_Examen__c ?? "(sin nombre)") (requiere >= \(Int(edadInicio)) años, usuario tiene \(userEdad))")
                    return false
                }
                if edadFin > 0 && Double(userEdad) > edadFin {
                    print("      Excluido por edad: \(record.Nombre_Examen__c ?? "(sin nombre)") (requiere <= \(Int(edadFin)) años, usuario tiene \(userEdad))")
                    return false
                }
            }

            return true
        }

        print("   Examenes filtrados: \(filtered.count) de \(total)")
        print("   Examenes post-filtro: \(filtered.count)")
        return filtered
    }

    /// PASO 6: Actualizar datos personales (si hubo cambios)
    private func updatePatientData(nombre: String, apellido: String, fechaNac: String, direccion: String) {
        // Convertir fecha de formato display (dd/MM/yyyy) a Salesforce (yyyy-MM-dd)
        let fechaSalesforce = convertDateToSalesforce(fechaNac)

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [Paso 6] ACTUALIZAR DATOS PERSONALES")
        print("   AccountId: \"\(accountId)\"")
        print("   Nombre: \"\(nombre)\"")
        print("   Apellido: \"\(apellido)\"")
        print("   FechaNac (display): \"\(fechaNac)\"")
        print("   FechaNac (Salesforce): \"\(fechaSalesforce)\"")
        print("   Direccion: \"\(direccion)\"")
        print("🔄 Enviando request a function_flows...")

        Task {
            let result = await Network.shared.updatePatientDataForExams(
                accountId: accountId,
                nombre: nombre,
                apellido: apellido,
                fechaNacimiento: fechaSalesforce,
                direccion: direccion
            )

            await MainActor.run {
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        print("✅ [Paso 6] updatePatientData EXITO")
                        print("   success: \(response.success ?? false)")
                        print("   status: \"\(response.status ?? "")\"")
                        print("   id: \"\(response.id ?? "")\"")

                        // Actualizar cache con los nuevos datos
                        ProfileCache.save(
                            firstName: nombre,
                            lastName: apellido,
                            birthdate: fechaSalesforce,
                            email: ProfileCache.email,
                            address: direccion,
                            gender: ProfileCache.gender,
                            rut: ProfileCache.rut
                        )
                        print("   💾 ProfileCache actualizado con nuevos datos")

                        confirmDatosIsLoading = false
                        showConfirmDatos = false
                        datosConfirmados = true
                        print("   → Mostrando Consentimiento (Paso 7)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showConsentimiento = true
                        }
                    } else {
                        let errorMsg = response.errorMessage ?? "Error desconocido al actualizar datos"
                        print("⚠️ [Paso 6] updatePatientData FALLO (response no exitosa)")
                        print("   errorMessage: \"\(errorMsg)\"")
                        print("   errors: \(response.errors ?? [])")
                        // Continuar igualmente al consentimiento (igual que Android)
                        confirmDatosIsLoading = false
                        showConfirmDatos = false
                        datosConfirmados = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showConsentimiento = true
                        }
                    }

                case .failure(let error):
                    print("❌ [Paso 6] updatePatientData ERROR HTTP")
                    print("   Error: \(error.name) - \(error.message)")
                    // Continuar igualmente al consentimiento
                    confirmDatosIsLoading = false
                    showConfirmDatos = false
                    datosConfirmados = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showConsentimiento = true
                    }
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
            }
        }
    }

    /// Convierte fecha de dd/MM/yyyy a yyyy-MM-dd (formato Salesforce)
    private func convertDateToSalesforce(_ displayDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        guard let date = inputFormatter.date(from: displayDate) else {
            // Si ya viene en formato yyyy-MM-dd o no se puede parsear, devolver tal cual
            print("⚠️ [Fecha] No se pudo convertir \"\(displayDate)\" desde dd/MM/yyyy, se envia tal cual")
            return displayDate
        }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        return outputFormatter.string(from: date)
    }

    /// PASO 8: Actualizar email (si cambio)
    private func updatePatientEmail(email: String) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [Paso 8] ACTUALIZAR EMAIL")
        print("   AccountId: \(accountId)")
        print("   Email: \(email)")
        print("🔄 Enviando request...")

        showUpdatingEmail = true

        Task {
            let result = await Network.shared.updateEmailForExams(
                accountId: accountId,
                email: email
            )

            await MainActor.run {
                showUpdatingEmail = false

                switch result {
                case .success(let response):
                    print("✅ [Paso 8] updateEmail EXITO")
                    print("   StatusCode: \(response.statusCode ?? -1)")
                    print("   Message: \(response.message ?? "(nil)")")
                case .failure(let error):
                    print("⚠️ [Paso 8] updateEmail ERROR (continuamos igualmente)")
                    print("   Error: \(error.name) - \(error.message)")
                }
                print("   → Mostrando ExamenSinCosto (Paso 9)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    printPopupExamenSinCostoConfig()
                    showExamenSinCosto = true
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
            }
        }
    }

    /// PASO 10: Genera la orden de examenes + busca la orden recien creada
    private func generateExamOrder() {
        guard !cartItems.isEmpty else {
            print("⚠️ [Paso 10] Carrito vacio, no se genera orden")
            showGenerandoOrden = false
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📤 [Paso 10] GENERAR ORDEN DE EXAMEN")
        print("   AccountId: \(accountId)")
        print("   Total items: \(cartItems.count)")
        for (i, item) in cartItems.enumerated() {
            print("   [\(i)] \"\(item.nombre)\" codigo=\(item.codigo) categoria=\"\(item.categoria)\" categoriaNum=\(item.categoriaNum)")
        }
        print("🔄 Enviando request (loading minimo \(config.popupCarga.segundosMostrar)s)...")

        let startTime = Date()

        Task {
            let result = await Network.shared.generateAutomatedExams(
                accountId: accountId,
                cartItems: cartItems
            )

            // Asegurar loading minimo configurable desde Salesforce (CantidadSegundosMostrarPopUp)
            let minSeconds = Double(config.popupCarga.segundosMostrar)
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = max(0, minSeconds - elapsed)
            if remaining > 0 {
                print("   ⏱️ Esperando \(String(format: "%.1f", remaining))s mas (minimo \(Int(minSeconds))s de loading)")
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
            }

            // Obtener la URL del PDF — 1 sola consulta tras el delay del loading (como Android)
            // El loading de N segundos (Elemento 9.7) le da tiempo a Salesforce para generar el PDF
            var pdfUrl = ""
            print("🔍 [Paso 10] Buscando orden recien creada para obtener URL PDF...")
            let latestResult = await Network.shared.getLatestAutomatedExamOrder(accountId: accountId)
            switch latestResult {
            case .success(let latestResponse):
                let records = latestResponse.data?.first?.examenesAutomatizadosC ?? []
                if let latest = records.sorted(by: { ($0.CreatedDate ?? "") > ($1.CreatedDate ?? "") }).first {
                    pdfUrl = latest.urlOrdenMedicaRealC ?? ""
                    if !pdfUrl.isEmpty {
                        print("   ✅ URL PDF encontrada: \(pdfUrl.prefix(80))")
                    } else {
                        print("   ⚠️ URL PDF vacía — el PDF aún no fue generado por Salesforce")
                    }
                } else {
                    print("   ⚠️ No se encontró record de orden reciente")
                }
            case .failure(let error):
                print("   ⚠️ Error buscando orden reciente: \(error.message)")
            }

            await MainActor.run {
                showGenerandoOrden = false

                switch result {
                case .success(let response):
                    print("✅ [Paso 10] generateExamOrder EXITO")
                    print("   StatusCode: \(response.statusCode ?? -1)")
                    print("   Message: \(response.message ?? "(nil)")")
                    print("   OrdenId: \(response.data?.ordenId ?? "(nil)")")
                    urlOrdenMedicaPdf = pdfUrl
                    print("   → Mostrando Exito (Paso 11)")
                    printPopupExitoConfig()
                    self.showConfetti = true
                    showExitoOrdenes = true
                    ReviewManager.shared.requestReviewIfNeeded()
                case .failure(let error):
                    print("❌ [Paso 10] generateExamOrder ERROR")
                    print("   Error: \(error.name) - \(error.message)")
                    print("   → Mostrando PopupSugerencia")
                    showSugerencia = true
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("")
            }
        }
    }
}

// ShakeEffect movido a Components/SpringModifiers.swift
