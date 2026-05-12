//
//  FamilyGroupView.swift
//  CareAssistance
//
//  Created by The App Master on 18/07/2024.
//

import SwiftUI
import CachedAsyncImage
import RealmSwift

struct FamilyGroupView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedResults(User.self) private var users
    @ObservedResults(BrandAccounts.self) var items
    @State var preLoginState: PreLoginUIState = PreLoginUIState()
    @State var fgConfig = FamilyGroupUIState()
    @State var isLoading: Bool = true
    @State private var selectedEnterprise: CompanyAgreementR? = AppStatusManager.selectedEnterprise

    // MARK: - Member list state
    @State private var members: [FamilyGroupMember] = []
    @State private var membersAnimated: Bool = false

    // MARK: - Add form state (paridad con web AddCargaModal.tsx)
    @State private var showAddModal: Bool = false
    @State private var isAddLoading: Bool = false
    @State private var addRut: String = ""
    @State private var addName: String = ""
    @State private var addLastName: String = ""
    @State private var addEmail: String = ""
    @State private var addPhone: String = ""
    @State private var addBirthdate: Date? = nil
    @State private var addIsMinor: Bool = false
    @State private var addShowCalendar: Bool = false
    // Errores inline por campo
    @State private var addRutError: String? = nil
    @State private var addNameError: String? = nil
    @State private var addLastNameError: String? = nil
    @State private var addBirthdateError: String? = nil
    @State private var addEmailError: String? = nil
    @State private var addPhoneError: String? = nil

    // MARK: - Edit state
    @State private var editingMember: FamilyGroupMember? = nil
    @State private var editRut: String = ""
    @State private var editFirstName: String = ""
    @State private var editLastName: String = ""
    @State private var editEmail: String = ""
    @State private var editPhone: String = ""
    @State private var editAddress: String = ""
    @State private var editBirthdate: Date = .now
    @State private var editGender: String = ""
    @State private var showEditCalendar: Bool = false
    @State private var isEditLoading: Bool = false
    @State private var showEditModal: Bool = false
    // Snapshot inicial para detectar cambios (isDirty) — paridad con web
    @State private var initialEditValues: EditSnapshot? = nil
    // Errores inline por campo
    @State private var editFirstNameError: String? = nil
    @State private var editLastNameError: String? = nil
    @State private var editEmailError: String? = nil
    @State private var editPhoneError: String? = nil
    @State private var editBirthdateError: String? = nil

    // MARK: - Delete state
    @State private var deletingMember: FamilyGroupMember? = nil
    @State private var isDeletingLoading: Bool = false
    @State private var deleteIconScale: CGFloat = 0.0

    // MARK: - Over-limit state
    @State private var showOverLimitModal: Bool = false

    // MARK: - Generic Error Modal state
    @State private var showGenericErrorModal: Bool = false
    @State private var errorIconScale: CGFloat = 0.0

    // MARK: - Edit Success Modal state
    @State private var showEditSuccessModal: Bool = false
    @State private var editSuccessIconScale: CGFloat = 0.0

    // MARK: - Delete Success Modal state
    @State private var showDeleteSuccessModal: Bool = false
    @State private var deleteSuccessIconScale: CGFloat = 0.0

    // MARK: - Confetti hearts state
    @State private var showConfettiHearts: Bool = false

    private let maxCargas = 5

    // Snapshot para comparación isDirty en el modal de editar
    private struct EditSnapshot: Equatable {
        let firstName: String
        let lastName: String
        let email: String
        let phone: String
        let address: String
        let gender: String
        let birthdate: Date
    }

    private var isFamilyGroupAddEnabled: Bool {
        selectedEnterprise?.grupoFamiliarC ?? false
    }

    private var shouldSendEmpresaSolicitada: Bool {
        let grupoActivo = selectedEnterprise?.grupoFamiliarC ?? false
        let flujo = selectedEnterprise?.nombreFlujoC ?? ""
        return grupoActivo && !flujo.isEmpty
    }

    /// RUT del titular normalizado: solo alfanuméricos + UPPERCASE (dígito verificador en mayúscula).
    /// Usar SIEMPRE que se envíe a cualquier endpoint para garantizar consistencia entre
    /// creación, consulta y filtros (Salesforce SOQL es case-sensitive en `equal`).
    private var titularRutNormalized: String {
        (AppStatusManager.rut ?? "")
            .filter { $0.isLetter || $0.isNumber }
            .uppercased()
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                SkeletonList(rows: 3)
                    .padding(.top, 20)
                Spacer(minLength: 0)
            } else {
                memberListView
            }
        }
        .blur(radius: (deletingMember != nil || showOverLimitModal || showEditModal || showAddModal || showGenericErrorModal || showEditSuccessModal || showDeleteSuccessModal) ? 3 : 0.000001)
        .overlay(
            ZStack {
                // Modal agregar carga
                if showAddModal {
                    addMemberModal
                        .zIndex(30)
                        .transition(.opacity)
                }

                // Modal editar miembro
                if showEditModal {
                    editMemberModal
                        .zIndex(40)
                        .transition(.opacity)
                }

                // Modal sobre-límite
                if showOverLimitModal {
                    overLimitModal
                        .zIndex(50)
                        .transition(.opacity)
                }

                // Modal eliminar miembro (zIndex superior para que se muestre encima del overlimit)
                if let member = deletingMember {
                    deleteMemberModal(member: member)
                        .zIndex(60)
                        .transition(.opacity)
                }

                // Modal de error genérico
                if showGenericErrorModal {
                    genericErrorModal
                        .zIndex(70)
                        .transition(.opacity)
                }

                // Modal de éxito edición
                if showEditSuccessModal {
                    editSuccessModal
                        .zIndex(80)
                        .transition(.opacity)
                }

                // Modal de éxito eliminación
                if showDeleteSuccessModal {
                    deleteSuccessModal
                        .zIndex(90)
                        .transition(.opacity)
                }
            }
        )
        .confettiHearts(isActive: $showConfettiHearts)
        .onAppear {
            isLoading = true
            loadUIState()
            fgConfig = loadFamilyGroupConfig()
            logFamilyGroupState()
            loadMembers()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                toolbarTitle
            }
            ToolbarItem(placement: .navigationBarLeading) {
                toolbarBackButton
            }
        }
        .background(
            Group {
                if preLoginState.singUpFormUIState.imageBackground != "" {
                    CachedAsyncImage(
                        url: URL(string: preLoginState.singUpFormUIState.imageBackground),
                        content: { image in
                            image.resizable().edgesIgnoringSafeArea(.all).aspectRatio(contentMode: .fill)
                        },
                        placeholder: { ProgressView() }
                    )
                    .eraseToAnyView()
                }
            }
        )
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Member List View
    // ══════════════════════════════════════════════════════

    private var memberListView: some View {
        let dAttr = fgConfig.seccionPrincipal.descripcionAttr
        let btnAddCfg = fgConfig.seccionPrincipal.botonAgregar

        return VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    Divider()

                    Text(fgConfig.seccionPrincipal.descripcion.isEmpty
                         ? "Aquí tienes la lista de cargas disponibles, puedes modificar los datos en cualquier momento:"
                         : fgConfig.seccionPrincipal.descripcion)
                        .font(Font.custom(
                            dAttr.font.isEmpty ? "FiraSans-Regular" : dAttr.font,
                            size: CGFloat(Int(dAttr.size) ?? 14)
                        ))
                        .foregroundColor(Color(hex: dAttr.color.isEmpty ? "#555555" : dAttr.color))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .margin)
                        .padding(.top, 16)
                        .padding(.bottom, 16)

                    if members.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                                memberCard(member: member, index: index)
                                    .opacity(membersAnimated ? 1.0 : 0.0)
                                    .offset(y: membersAnimated ? 0 : 20)
                                    .scaleEffect(membersAnimated ? 1.0 : 0.92)
                                    .animation(
                                        .spring(response: 0.65, dampingFraction: 0.75)
                                            .delay(Double(index) * 0.08),
                                        value: membersAnimated
                                    )
                            }
                        }
                        .padding(.horizontal, .margin)
                        .padding(.bottom, .margin)
                    }
                }
            }

            // Botón agregar (solo si habilitado Y < 5 cargas)
            if isFamilyGroupAddEnabled && members.count < maxCargas {
                Button {
                    HapticManager.impact(style: .medium)
                    resetAddForm()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showAddModal = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text(btnAddCfg.texto.isEmpty ? "Agregar Carga" : btnAddCfg.texto)
                            .font(Font.custom("FiraSans-Bold", size: 15))
                    }
                    .foregroundColor(Color(hex: btnAddCfg.colorTexto.isEmpty ? "#FFFFFF" : btnAddCfg.colorTexto))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: btnAddCfg.colorFondo.isEmpty ? "#00BBDC" : btnAddCfg.colorFondo))
                    )
                }
                .bounceOnTap()
                .padding(.horizontal, .margin)
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Member Card
    private func memberCard(member: FamilyGroupMember, index: Int) -> some View {
        let nAttr = fgConfig.seccionPrincipal.nombresAttr
        let editColor = fgConfig.seccionPrincipal.colorIconoEditar
        let deleteColor = fgConfig.seccionPrincipal.colorIconoEliminar
        let avatarBg = fgConfig.fondoAvatar.colorFondoAvatar

        return HStack(spacing: 14) {
            // Avatar: icono dinámico o iniciales como fallback
            memberAvatar(member: member, size: 46)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(member.fullName)
                    .font(Font.custom(
                        nAttr.font.isEmpty ? "FiraSans-Bold" : nAttr.font,
                        size: CGFloat(Int(nAttr.size) ?? 15)
                    ))
                    .foregroundColor(Color(hex: nAttr.color.isEmpty ? "#333333" : nAttr.color))
                    .lineLimit(1)

                if !member.email.isEmpty {
                    Text(member.email)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                        .foregroundColor(Color(hex: "#888888"))
                        .lineLimit(1)
                }

                if !member.rut.isEmpty {
                    Text(member.rut)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                        .foregroundColor(Color(hex: "#AAAAAA"))
                }
            }

            Spacer()

            // Botón editar
            Button {
                HapticManager.selection()
                prepareEdit(member: member)
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: editColor.isEmpty ? "#00BBDC" : editColor))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: avatarBg.isEmpty ? "#E6F9FC" : avatarBg))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)

            // Botón eliminar
            Button {
                deletingMember = member
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: deleteColor.isEmpty ? "#FF4D4F" : deleteColor))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: avatarBg.isEmpty ? "#FFF1F0" : avatarBg))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        let esAttr = fgConfig.seccionPrincipal.textoSinCargasAttr
        let esIconUrl = fgConfig.seccionPrincipal.iconoSinCargas

        return VStack(spacing: 16) {
            Spacer().frame(height: 20)

            LottieView(animationName: "Empty_box_alert")
                .frame(width: 180, height: 180)

            Text(fgConfig.seccionPrincipal.textoSinCargas.isEmpty
                 ? "No se encontraron cargas asociadas a tu usuario y esta empresa..."
                 : fgConfig.seccionPrincipal.textoSinCargas)
                .font(Font.custom(
                    esAttr.font.isEmpty ? "FiraSans-Regular" : esAttr.font,
                    size: CGFloat(Int(esAttr.size) ?? 14)
                ))
                .foregroundColor(Color(hex: esAttr.color.isEmpty ? "#777777" : esAttr.color))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .popIn()
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Add Member Modal (Dialog)
    // ══════════════════════════════════════════════════════

    private var addMemberModal: some View {
        let agCfg = fgConfig.seccionAgregar
        let agTAttr = agCfg.tituloAttr

        return ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isAddLoading { closeAddModal() }
                }

            VStack(spacing: 0) {
                // Header — título centrado, botón X a la derecha
                ZStack {
                    Text(agCfg.titulo.isEmpty ? "Agregar Carga" : agCfg.titulo)
                        .font(Font.custom(
                            agTAttr.font.isEmpty ? "FiraSans-Bold" : agTAttr.font,
                            size: CGFloat(Int(agTAttr.size) ?? 16)
                        ))
                        .foregroundColor(Color(hex: agTAttr.color.isEmpty ? "#333333" : agTAttr.color))
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Spacer()
                        Button {
                            if !isAddLoading { closeAddModal() }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#777777"))
                                .frame(width: 28, height: 28)
                                .background(Color(hex: "#F2F2F2"))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(isAddLoading)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 12)

                Divider()

                // Form
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // RUT: solo alfanuméricos UPPERCASE, max 25
                        transformedEditField(
                            label: fgAddLabel(0, fallback: "RUT") + " *",
                            text: $addRut,
                            error: $addRutError,
                            maxLength: 25,
                            transform: { $0.filter { $0.isLetter || $0.isNumber }.uppercased() }
                        )

                        // Nombre: Title Case, trim en blur
                        transformedEditField(
                            label: fgAddLabel(2, fallback: "Nombre") + " *",
                            text: $addName,
                            error: $addNameError,
                            transform: { titleCase($0) },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces) }
                        )

                        // Apellido: Title Case, trim en blur
                        transformedEditField(
                            label: fgAddLabel(3, fallback: "Apellido") + " *",
                            text: $addLastName,
                            error: $addLastNameError,
                            transform: { titleCase($0) },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces) }
                        )

                        // Fecha de nacimiento
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fgAddLabel(4, fallback: "Fecha de Nacimiento") + " *")
                                .font(Font.custom("FiraSans-Medium", size: 13))
                                .foregroundColor(Color(hex: "#555555"))
                            Button {
                                addShowCalendar.toggle()
                            } label: {
                                HStack {
                                    Text(addBirthdate != nil ? formattedDate(addBirthdate!) : "Seleccionar fecha")
                                        .font(Font.custom("FiraSans-Regular", size: 15))
                                        .foregroundColor(addBirthdate == nil ? .gray.opacity(0.5) : Color(hex: "#333333"))
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(hex: fgConfig.seccionAgregar.colorIconoCalendario.isEmpty ? "#00BBDC" : fgConfig.seccionAgregar.colorIconoCalendario))
                                }
                                .padding(10)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(
                                    addBirthdateError != nil ? Color(hex: "#FF4D4F") : Color.gray,
                                    lineWidth: 1
                                ))
                            }
                            .buttonStyle(.plain)
                            if let error = addBirthdateError {
                                Text(error)
                                    .font(Font.custom("FiraSans-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#FF4D4F"))
                            }
                        }

                        // Email: lowercased, trim en blur. Deshabilitado si menor.
                        transformedEditField(
                            label: addIsMinor ? "\(fgAddLabel(5, fallback: "Correo Electrónico")) (del titular)" : fgAddLabel(5, fallback: "Correo Electrónico") + " *",
                            text: $addEmail,
                            error: $addEmailError,
                            keyboard: .emailAddress,
                            disabled: addIsMinor,
                            transform: { $0.lowercased() },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                        )

                        // Teléfono: solo dígitos, max 12, trim en blur. Deshabilitado si menor.
                        transformedEditField(
                            label: addIsMinor ? "\(fgAddLabel(6, fallback: "Teléfono")) (del titular)" : fgAddLabel(6, fallback: "Teléfono") + " *",
                            text: $addPhone,
                            error: $addPhoneError,
                            keyboard: .phonePad,
                            maxLength: 12,
                            disabled: addIsMinor,
                            transform: { $0.filter { $0.isNumber } },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces) }
                        )
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                }
                .frame(maxHeight: 640)

                Divider()

                // Footer con botones
                addModalFooter
            }
            .frame(maxWidth: 420)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
            .padding(.horizontal, 12)
            .popup(isPresented: $addShowCalendar) {
                addDatePickerPopup
            }
        }
        .onChange(of: addBirthdate) { newValue in
            handleAddBirthdateChange(newValue)
        }
    }

    // DatePicker popup específico del add (fecha opcional + no futuras)
    private var addDatePickerPopup: some View {
        let cal = fgConfig.seccionAgregar.coloresCalendario
        let accentHex = cal.colorFondoSeleccion.isEmpty ? "#7F35B2" : cal.colorFondoSeleccion
        let titleHex = cal.colorMes.isEmpty ? "#3A3A3A" : cal.colorMes

        return VStack {
            HStack {
                Text("Fecha de nacimiento")
                    .foregroundColor(Color(hex: titleHex))
                Spacer()
                Button {
                    addShowCalendar = false
                    if addBirthdate == nil {
                        // El usuario confirmó sin tocar el wheel: inicializar con hoy
                        addBirthdate = Date()
                    }
                } label: {
                    Text("Aceptar")
                        .font(.appBodyBold)
                        .foregroundColor(Color(hex: accentHex))
                }
            }
            DatePicker(
                "",
                selection: Binding(
                    get: { addBirthdate ?? Date() },
                    set: { addBirthdate = $0 }
                ),
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .accentColor(Color(hex: accentHex))
            .environment(\.locale, Locale(identifier: "es_ES"))
        }
        .padding()
    }

    private func handleAddBirthdateChange(_ newValue: Date?) {
        guard let date = newValue else {
            addIsMinor = false
            return
        }
        let age = calculateAge(from: date)
        if age < 18 {
            let titularEmail = users.first?.records.first?.PersonEmail ?? ""
            let titularPhone = (users.first?.records.first?.Phone ?? "").filter { $0.isNumber }
            addEmail = titularEmail
            addPhone = titularPhone
            addEmailError = nil
            addPhoneError = nil
            addIsMinor = true
        } else {
            if addIsMinor {
                // Venía de menor → limpiar email/phone para forzar nueva entrada
                addEmail = ""
                addPhone = ""
            }
            addIsMinor = false
        }
        addBirthdateError = nil
    }

    private func closeAddModal() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showAddModal = false
        }
        resetAddForm()
    }

    // Title Case: primera letra de cada palabra mayúscula, resto minúscula
    private func titleCase(_ input: String) -> String {
        input.split(separator: " ", omittingEmptySubsequences: false)
            .map { word -> String in
                guard let first = word.first else { return "" }
                return String(first).uppercased() + word.dropFirst().lowercased()
            }
            .joined(separator: " ")
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Edit Member Modal (Dialog)
    // ══════════════════════════════════════════════════════

    private var editMemberModal: some View {
        let modCfg = fgConfig.seccionModificar
        let modTAttr = modCfg.tituloAttr

        return ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isEditLoading { closeEditModal() }
                }

            VStack(spacing: 0) {
                // Header — título centrado, botón X a la derecha
                ZStack {
                    Text(modCfg.titulo.isEmpty ? "Modificar Datos" : modCfg.titulo)
                        .font(Font.custom(
                            modTAttr.font.isEmpty ? "FiraSans-Bold" : modTAttr.font,
                            size: CGFloat(Int(modTAttr.size) ?? 16)
                        ))
                        .foregroundColor(Color(hex: modTAttr.color.isEmpty ? "#333333" : modTAttr.color))
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Spacer()
                        Button {
                            if !isEditLoading { closeEditModal() }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#777777"))
                                .frame(width: 28, height: 28)
                                .background(Color(hex: "#F2F2F2"))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(isEditLoading)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 12)

                Divider()

                // Form (orden paridad web: RUT → Nombre → Apellido → Dirección → Fecha → Sexo → Email → Teléfono)
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // RUT (solo lectura, no se envía)
                        editField(label: fgEditLabel(0, fallback: "RUT"), text: $editRut, disabled: true)

                        // Nombre: Title Case + trim
                        transformedEditField(
                            label: fgEditLabel(1, fallback: "Nombre") + " *",
                            text: $editFirstName,
                            error: $editFirstNameError,
                            transform: { titleCase($0) },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces) }
                        )

                        // Apellido: Title Case + trim
                        transformedEditField(
                            label: fgEditLabel(2, fallback: "Apellido") + " *",
                            text: $editLastName,
                            error: $editLastNameError,
                            transform: { titleCase($0) },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces) }
                        )

                        // Dirección (opcional): Title Case + trim
                        transformedEditField(
                            label: fgEditLabel(3, fallback: "Dirección"),
                            text: $editAddress,
                            error: .constant(nil),
                            transform: { titleCase($0) },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces) }
                        )

                        // Fecha de nacimiento (no futuras)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fgEditLabel(4, fallback: "Fecha de Nacimiento") + " *")
                                .font(Font.custom("FiraSans-Medium", size: 13))
                                .foregroundColor(Color(hex: "#555555"))
                            Button {
                                showEditCalendar.toggle()
                            } label: {
                                HStack {
                                    Text(formattedDate(editBirthdate))
                                        .font(Font.custom("FiraSans-Regular", size: 15))
                                        .foregroundColor(Color(hex: "#333333"))
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(hex: fgConfig.seccionModificar.colorIconoCalendario.isEmpty ? "#00BBDC" : fgConfig.seccionModificar.colorIconoCalendario))
                                }
                                .padding(10)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(
                                    editBirthdateError != nil ? Color(hex: "#FF4D4F") : Color.gray,
                                    lineWidth: 1
                                ))
                            }
                            .buttonStyle(.plain)
                            if let err = editBirthdateError {
                                Text(err)
                                    .font(Font.custom("FiraSans-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#FF4D4F"))
                            }
                        }

                        // Sexo (opcional)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fgEditLabel(5, fallback: "Sexo"))
                                .font(Font.custom("FiraSans-Medium", size: 13))
                                .foregroundColor(Color(hex: "#555555"))
                            Menu {
                                Button("Hombre") { editGender = "Male" }
                                Button("Mujer") { editGender = "Female" }
                                Button("No especificar") { editGender = "" }
                            } label: {
                                HStack {
                                    Text(editGender == "Male" ? "Hombre" : editGender == "Female" ? "Mujer" : (fgConfig.seccionModificar.textoPreSeleccion.isEmpty ? "Seleccionar" : fgConfig.seccionModificar.textoPreSeleccion))
                                        .font(Font.custom("FiraSans-Regular", size: 15))
                                        .foregroundColor(editGender.isEmpty ? .gray.opacity(0.5) : Color(hex: "#333333"))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: fgConfig.seccionModificar.colorIconoCalendario.isEmpty ? "#00BBDC" : fgConfig.seccionModificar.colorIconoCalendario))
                                }
                                .padding(10)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            }
                        }

                        // Email: lowercased + trim.lowercased onBlur
                        transformedEditField(
                            label: fgEditLabel(6, fallback: "Correo Electrónico") + " *",
                            text: $editEmail,
                            error: $editEmailError,
                            keyboard: .emailAddress,
                            transform: { $0.lowercased() },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                        )

                        // Teléfono: solo dígitos + max 12 + trim
                        transformedEditField(
                            label: fgEditLabel(7, fallback: "Teléfono") + " *",
                            text: $editPhone,
                            error: $editPhoneError,
                            keyboard: .phonePad,
                            maxLength: 12,
                            transform: { $0.filter { $0.isNumber } },
                            onBlur: { $0.trimmingCharacters(in: .whitespaces) }
                        )
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                }
                .frame(maxHeight: 640)

                Divider()

                // Footer con botones
                editModalFooter
            }
            .frame(maxWidth: 420)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
            .padding(.horizontal, 12)
            .popup(isPresented: $showEditCalendar) {
                editDatePickerPopup
            }
        }
    }

    // DatePicker popup del edit (fecha requerida + no futuras)
    private var editDatePickerPopup: some View {
        let cal = fgConfig.seccionModificar.coloresCalendario
        let accentHex = cal.colorFondoSeleccion.isEmpty ? "#7F35B2" : cal.colorFondoSeleccion
        let titleHex = cal.colorMes.isEmpty ? "#3A3A3A" : cal.colorMes

        return VStack {
            HStack {
                Text("Fecha de nacimiento")
                    .foregroundColor(Color(hex: titleHex))
                Spacer()
                Button {
                    showEditCalendar = false
                    editBirthdateError = nil
                } label: {
                    Text("Aceptar")
                        .font(.appBodyBold)
                        .foregroundColor(Color(hex: accentHex))
                }
            }
            DatePicker(
                "",
                selection: $editBirthdate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .accentColor(Color(hex: accentHex))
            .environment(\.locale, Locale(identifier: "es_ES"))
        }
        .padding()
    }

    private func closeEditModal() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showEditModal = false
        }
        editingMember = nil
        initialEditValues = nil
        editFirstNameError = nil
        editLastNameError = nil
        editEmailError = nil
        editPhoneError = nil
        editBirthdateError = nil
    }

    /// Variante avanzada del editField con transformaciones onChange/onBlur en TIEMPO REAL,
    /// maxLength y error inline. Replica Ant Design rules del web AddCargaModal.
    ///
    /// Nota: usa `.onChange(of:)` (no Binding custom) para que la transformación se vea
    /// mientras el usuario tipea, no solo al salir del campo (bug conocido de SwiftUI con
    /// Bindings que mutan el valor en el set).
    private func transformedEditField(
        label: String,
        text: Binding<String>,
        error: Binding<String?>,
        keyboard: UIKeyboardType = .default,
        maxLength: Int? = nil,
        disabled: Bool = false,
        transform: ((String) -> String)? = nil,
        onBlur: ((String) -> String)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Font.custom("FiraSans-Medium", size: 13))
                .foregroundColor(Color(hex: "#555555"))
            TextField("", text: text, onEditingChanged: { isEditing in
                if !isEditing, let onBlur = onBlur {
                    let next = onBlur(text.wrappedValue)
                    if next != text.wrappedValue { text.wrappedValue = next }
                }
            })
            .font(Font.custom("FiraSans-Regular", size: 15))
            .foregroundColor(disabled ? Color(hex: "#999999") : Color(hex: "#333333"))
            .padding(10)
            .background(disabled ? Color(hex: "#F2F2F2") : Color.clear)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(
                error.wrappedValue != nil ? Color(hex: "#FF4D4F") :
                (disabled ? Color(hex: "#D0D0D0") : Color.gray),
                lineWidth: 1
            ))
            .cornerRadius(8)
            .keyboardType(keyboard)
            .autocapitalization(.none) // Title Case / UPPERCASE / lowercase lo aplica el transform manual
            .disabled(disabled)
            .onChange(of: text.wrappedValue) { newValue in
                var v = newValue
                if let transform = transform { v = transform(v) }
                if let maxLength = maxLength, v.count > maxLength {
                    v = String(v.prefix(maxLength))
                }
                // Solo reasignar si hubo cambio — evita loop de onChange infinito
                if v != newValue {
                    text.wrappedValue = v
                }
                // Limpia el error apenas el usuario empieza a corregir
                if !v.isEmpty && error.wrappedValue != nil {
                    error.wrappedValue = nil
                }
            }
            if let err = error.wrappedValue {
                Text(err)
                    .font(Font.custom("FiraSans-Regular", size: 12))
                    .foregroundColor(Color(hex: "#FF4D4F"))
            }
        }
    }

    private func editField(label: String, text: Binding<String>, keyboard: UIKeyboardType = .default, disabled: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Font.custom("FiraSans-Medium", size: 13))
                .foregroundColor(Color(hex: "#555555"))
            TextField("", text: text)
                .font(Font.custom("FiraSans-Regular", size: 15))
                .foregroundColor(disabled ? Color(hex: "#999999") : Color(hex: "#333333"))
                .padding(10)
                .background(disabled ? Color(hex: "#F2F2F2") : Color.clear)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(disabled ? Color(hex: "#D0D0D0") : Color.gray, lineWidth: 1))
                .cornerRadius(8)
                .keyboardType(keyboard)
                .autocapitalization(keyboard == .emailAddress ? .none : .words)
                .disabled(disabled)
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Delete Confirmation Modal
    // ══════════════════════════════════════════════════════

    private func deleteMemberModal(member: FamilyGroupMember) -> some View {
        let popCfg = fgConfig.popupEliminar
        let tAttr = popCfg.tituloAttr
        let dAttr = popCfg.textoAttr

        return ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isDeletingLoading { deletingMember = nil }
                }

            VStack(spacing: 16) {
                // Icono: URL dinámica o SF Symbol fallback
                if !popCfg.iconUrl.isEmpty, let url = URL(string: popCfg.iconUrl) {
                    CachedAsyncImage(
                        url: url,
                        content: { image in
                            image.resizable().scaledToFit().frame(width: 56, height: 56)
                        },
                        placeholder: {
                            ProgressView().frame(width: 56, height: 56)
                        }
                    )
                    .scaleEffect(deleteIconScale)
                    .opacity(Double(deleteIconScale))
                    .padding(.top, 20)
                    .onAppear {
                        deleteIconScale = 0.0
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            deleteIconScale = 1.0
                        }
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#FFF3E0"))
                            .frame(width: 56, height: 56)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "#FF9800"))
                    }
                    .scaleEffect(deleteIconScale)
                    .opacity(Double(deleteIconScale))
                    .padding(.top, 20)
                    .onAppear {
                        deleteIconScale = 0.0
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            deleteIconScale = 1.0
                        }
                    }
                }

                // Título dinámico
                Text(popCfg.titulo.isEmpty ? "¿Estás seguro de que deseas eliminar a \(member.firstName)?" : popCfg.titulo)
                    .font(Font.custom(
                        tAttr.font.isEmpty ? "FiraSans-Bold" : tAttr.font,
                        size: CGFloat(Int(tAttr.size) ?? 16)
                    ))
                    .foregroundColor(Color(hex: tAttr.color.isEmpty ? "#333333" : tAttr.color))
                    .multilineTextAlignment(.center)

                // Texto dinámico (soporta **bold** vía parseSalesforceText)
                if !popCfg.texto.isEmpty {
                    parseSalesforceText(
                        popCfg.texto,
                        font: dAttr.font.isEmpty ? "FiraSans-Regular" : dAttr.font,
                        size: CGFloat(Int(dAttr.size) ?? 14),
                        color: Color(hex: dAttr.color.isEmpty ? "#777777" : dAttr.color)
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                } else {
                    Text("Esta acción dará de baja la carga del grupo familiar y no se puede deshacer.")
                        .font(Font.custom("FiraSans-Regular", size: 13))
                        .foregroundColor(Color(hex: "#777777"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)

                    Text("Una vez eliminada, deberá esperar 24 horas antes de poder volver a agregar esta carga.")
                        .font(Font.custom("FiraSans-Bold", size: 13))
                        .foregroundColor(Color(hex: "#555555"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }

                deleteModalButtons(member: member, popCfg: popCfg)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 380)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Over-Limit Modal (>5 cargas)
    // ══════════════════════════════════════════════════════

    private var overLimitModal: some View {
        let olTAttr = fgConfig.seccionOverLimit.tituloAttr
        let olDAttr = fgConfig.seccionOverLimit.textoAttr
        let olTextoBase = fgConfig.seccionOverLimit.texto

        return GeometryReader { geo in
            let dialogWidth = geo.size.width * 0.92

            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    // 1) Icono warning — círculo amarillo con "!" blanco (paridad Android ic_warning_circle_yellow 56x56dp)
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#FFC01F"))
                            .frame(width: 56, height: 56)
                        Text("!")
                            .font(Font.custom("FiraSans-Bold", size: 28))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // 2) Título dinámico
                    Text(fgConfig.seccionOverLimit.titulo.isEmpty ? "Límite de cargas excedido" : fgConfig.seccionOverLimit.titulo)
                        .font(Font.custom(
                            olTAttr.font.isEmpty ? "FiraSans-Bold" : olTAttr.font,
                            size: CGFloat(Int(olTAttr.size) ?? 17)
                        ))
                        .foregroundColor(Color(hex: olTAttr.color.isEmpty ? "#0254A5" : olTAttr.color))

                    // 3) Descripción dinámica (reemplaza "/" por conteos)
                    Text(overLimitText(template: olTextoBase, memberCount: members.count, maxCount: maxCargas))
                        .font(Font.custom(
                            olDAttr.font.isEmpty ? "FiraSans-Regular" : olDAttr.font,
                            size: CGFloat(Int(olDAttr.size) ?? 13)
                        ))
                        .foregroundColor(Color(hex: olDAttr.color.isEmpty ? "#666666" : olDAttr.color))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 8)

                    // 4) Lista de miembros — max 320pt scrolleable, cards con animación cascada
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                                overLimitMemberCard(member: member, index: index)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                    .frame(maxHeight: geo.size.height * 0.70)
                    .padding(.bottom, 20)
                }
                .padding(20)
                .frame(width: dialogWidth)
                .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    /// Card de miembro dentro del dialog overlimit (paridad Android item_miembro_grupo_familiar.xml con hideEditButton=true)
    private func overLimitMemberCard(member: FamilyGroupMember, index: Int) -> some View {
        HStack(spacing: 12) {
            // Avatar: icono dinámico o iniciales como fallback
            memberAvatar(member: member, size: 48)

            // Info: nombre (bold 15sp), correo y RUT (grises 12sp)
            VStack(alignment: .leading, spacing: 2) {
                Text(member.fullName)
                    .font(Font.custom("FiraSans-Bold", size: 15))
                    .foregroundColor(Color(hex: "#333333"))
                    .lineLimit(1)

                if !member.email.isEmpty {
                    Text(member.email)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                        .foregroundColor(Color(hex: "#888888"))
                        .lineLimit(1)
                }

                if !member.rut.isEmpty {
                    Text(member.rut)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                        .foregroundColor(Color(hex: "#AAAAAA"))
                }
            }

            Spacer()

            // Solo botón eliminar — abre modal de confirmación (mismo que la vista principal)
            Button {
                deletingMember = member
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: fgConfig.seccionPrincipal.colorIconoEliminar.isEmpty ? "#FF4D4F" : fgConfig.seccionPrincipal.colorIconoEliminar))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "#FFF1F0"))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        .pressable()
        // Animación cascada spring (paridad Android: alpha 0→1, translationY +20→0, scale 0.92→1.0, 650ms, 80ms delay)
        .opacity(membersAnimated ? 1 : 0)
        .offset(y: membersAnimated ? 0 : 20)
        .scaleEffect(membersAnimated ? 1.0 : 0.92)
        .animation(
            .spring(response: 0.65, dampingFraction: 0.75)
                .delay(Double(index) * 0.08),
            value: membersAnimated
        )
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Generic Error Modal
    // ══════════════════════════════════════════════════════

    private var genericErrorModal: some View {
        ZStack {
            Color.black.opacity(0.30)
                .ignoresSafeArea()
                .onTapGesture { showGenericErrorModal = false }

            VStack(spacing: 16) {
                // Ícono de error con bounce-in animado (~800ms)
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFEBEE"))
                        .frame(width: 64, height: 64)
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#FF4D4F"))
                }
                .scaleEffect(errorIconScale)
                .opacity(Double(errorIconScale))
                .padding(.top, 24)
                .onAppear {
                    errorIconScale = 0.0
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                        errorIconScale = 1.0
                    }
                }

                Text("Se produjo un error!")
                    .font(Font.custom("FiraSans-Bold", size: 17))
                    .foregroundColor(Color(hex: "#333333"))
                    .multilineTextAlignment(.center)

                Text("Por favor contactarse con Atención al Cliente")
                    .font(Font.custom("FiraSans-Regular", size: 13))
                    .foregroundColor(Color(hex: "#777777"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Button {
                    showGenericErrorModal = false
                } label: {
                    Text("Aceptar")
                        .font(Font.custom("FiraSans-Bold", size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: "#00BBDC")))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                .padding(.bottom, 18)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 380)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Edit Success Modal
    // ══════════════════════════════════════════════════════

    private var editSuccessModal: some View {
        GeometryReader { geo in
            let dialogWidth = min(geo.size.width * 0.85, 340)

            ZStack {
                Color.black.opacity(0.30)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Botón X para cerrar (paridad con imagen de referencia)
                    HStack {
                        Spacer()
                        Button {
                            dismissEditSuccessModal()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#999999"))
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 4)

                    // Ícono de éxito con bounce-in animado
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E8F5E9"))
                            .frame(width: 64, height: 64)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(Color(hex: "#00BBDC"))
                    }
                    .scaleEffect(editSuccessIconScale)
                    .opacity(Double(editSuccessIconScale))
                    .onAppear {
                        editSuccessIconScale = 0.0
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            editSuccessIconScale = 1.0
                        }
                    }

                    Text("¡Listo!")
                        .font(Font.custom("FiraSans-Bold", size: 17))
                        .foregroundColor(Color(hex: "#333333"))
                        .multilineTextAlignment(.center)

                    Text("Datos actualizados correctamente")
                        .font(Font.custom("FiraSans-Regular", size: 13))
                        .foregroundColor(Color(hex: "#777777"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                    Button {
                        dismissEditSuccessModal()
                    } label: {
                        Text("Aceptar")
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: "#00BBDC")))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .padding(.bottom, 18)
                }
                .padding(.horizontal, 20)
                .frame(width: dialogWidth)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
                .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Delete Success Modal
    // ══════════════════════════════════════════════════════

    private var deleteSuccessModal: some View {
        GeometryReader { geo in
            let dialogWidth = min(geo.size.width * 0.85, 340)

            ZStack {
                Color.black.opacity(0.30)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Botón X para cerrar
                    HStack {
                        Spacer()
                        Button {
                            dismissDeleteSuccessModal()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#999999"))
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 4)

                    // Ícono de éxito con bounce-in animado
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E8F5E9"))
                            .frame(width: 64, height: 64)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(Color(hex: "#00BBDC"))
                    }
                    .scaleEffect(deleteSuccessIconScale)
                    .opacity(Double(deleteSuccessIconScale))
                    .onAppear {
                        deleteSuccessIconScale = 0.0
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            deleteSuccessIconScale = 1.0
                        }
                    }

                    Text("¡Listo!")
                        .font(Font.custom("FiraSans-Bold", size: 17))
                        .foregroundColor(Color(hex: "#333333"))
                        .multilineTextAlignment(.center)

                    Text("Carga eliminada correctamente")
                        .font(Font.custom("FiraSans-Regular", size: 13))
                        .foregroundColor(Color(hex: "#777777"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                    Button {
                        dismissDeleteSuccessModal()
                    } label: {
                        Text("Aceptar")
                            .font(Font.custom("FiraSans-Bold", size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: "#00BBDC")))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .padding(.bottom, 18)
                }
                .padding(.horizontal, 20)
                .frame(width: dialogWidth)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
                .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func dismissDeleteSuccessModal() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showDeleteSuccessModal = false
        }
        // Si el overlimit sigue activo, recargar para actualizar
        if showOverLimitModal {
            // No recargar — la eliminación optimista ya actualizó members[]
        } else {
            isLoading = true
            loadMembers()
        }
    }

    private func dismissEditSuccessModal() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showEditSuccessModal = false
        }
        isLoading = true
        loadMembers()
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Validation
    // ══════════════════════════════════════════════════════

    var isAddFormValid: Bool {
        guard !addRut.isEmpty,
              !addName.trimmingCharacters(in: .whitespaces).isEmpty,
              !addLastName.trimmingCharacters(in: .whitespaces).isEmpty,
              addBirthdate != nil
        else { return false }
        if addIsMinor { return true }
        // Adulto: email válido y teléfono 8-12 dígitos
        guard isValidEmail(addEmail.trimmingCharacters(in: .whitespaces)) else { return false }
        let phoneLen = addPhone.count
        guard phoneLen >= 8, phoneLen <= 12, addPhone.allSatisfy({ $0.isNumber }) else { return false }
        return true
    }

    /// Valida cada campo y asigna errores inline. Retorna true si el formulario es válido.
    @discardableResult
    private func runAddValidation() -> Bool {
        var ok = true
        if addRut.isEmpty {
            addRutError = "Por favor ingrese el RUT"
            ok = false
        } else { addRutError = nil }

        if addName.trimmingCharacters(in: .whitespaces).isEmpty {
            addNameError = "Por favor ingrese el nombre"
            ok = false
        } else { addNameError = nil }

        if addLastName.trimmingCharacters(in: .whitespaces).isEmpty {
            addLastNameError = "Por favor ingrese el apellido"
            ok = false
        } else { addLastNameError = nil }

        if addBirthdate == nil {
            addBirthdateError = "Por favor ingrese la fecha de nacimiento"
            ok = false
        } else { addBirthdateError = nil }

        if !addIsMinor {
            let emailTrim = addEmail.trimmingCharacters(in: .whitespaces)
            if emailTrim.isEmpty {
                addEmailError = "Por favor ingrese el correo"
                ok = false
            } else if !isValidEmail(emailTrim) {
                addEmailError = "Por favor ingrese un correo válido"
                ok = false
            } else { addEmailError = nil }

            if addPhone.isEmpty {
                addPhoneError = "Por favor ingrese el teléfono"
                ok = false
            } else if !addPhone.allSatisfy({ $0.isNumber }) {
                addPhoneError = "Solo se permiten números"
                ok = false
            } else if addPhone.count < 8 || addPhone.count > 12 {
                addPhoneError = "El teléfono debe tener entre 8 y 12 dígitos"
                ok = false
            } else { addPhoneError = nil }
        } else {
            addEmailError = nil
            addPhoneError = nil
        }
        return ok
    }

    /// isDirty — hay cambios respecto al snapshot inicial (paridad con web)
    var isEditDirty: Bool {
        guard let s = initialEditValues else { return false }
        return s.firstName != editFirstName ||
               s.lastName != editLastName ||
               s.email != editEmail ||
               s.phone != editPhone ||
               s.address != editAddress ||
               s.gender != editGender ||
               !Calendar.current.isDate(s.birthdate, inSameDayAs: editBirthdate)
    }

    var isEditFormValid: Bool {
        guard !editFirstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !editLastName.trimmingCharacters(in: .whitespaces).isEmpty,
              isValidEmail(editEmail.trimmingCharacters(in: .whitespaces)),
              editPhone.allSatisfy({ $0.isNumber }),
              editPhone.count >= 8, editPhone.count <= 12
        else { return false }
        return isEditDirty
    }

    /// Valida cada campo del edit y asigna errores inline. Retorna true si es válido.
    @discardableResult
    private func runEditValidation() -> Bool {
        var ok = true

        if editFirstName.trimmingCharacters(in: .whitespaces).isEmpty {
            editFirstNameError = "Por favor ingrese el nombre"
            ok = false
        } else { editFirstNameError = nil }

        if editLastName.trimmingCharacters(in: .whitespaces).isEmpty {
            editLastNameError = "Por favor ingrese el apellido"
            ok = false
        } else { editLastNameError = nil }

        let emailTrim = editEmail.trimmingCharacters(in: .whitespaces)
        if emailTrim.isEmpty {
            editEmailError = "Por favor ingrese el correo"
            ok = false
        } else if !isValidEmail(emailTrim) {
            editEmailError = "Por favor ingrese un email válido"
            ok = false
        } else { editEmailError = nil }

        if editPhone.isEmpty {
            editPhoneError = "Por favor ingrese el teléfono"
            ok = false
        } else if !editPhone.allSatisfy({ $0.isNumber }) {
            editPhoneError = "Solo se permiten números"
            ok = false
        } else if editPhone.count < 8 || editPhone.count > 12 {
            editPhoneError = "El teléfono debe tener entre 8 y 12 dígitos"
            ok = false
        } else { editPhoneError = nil }

        // Fecha: el picker ya evita futuras, pero si el valor precargado del backend
        // viniera en el futuro (data corrupta), lo atrapamos acá.
        if editBirthdate > Date() {
            editBirthdateError = "La fecha no puede ser futura"
            ok = false
        } else { editBirthdateError = nil }

        return ok
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Network Functions
    // ══════════════════════════════════════════════════════

    func loadMembers() {
        // RUT normalizado (alfanuméricos + UPPERCASE) — debe coincidir EXACTO con el
        // `cedula_titular` enviado en registerUser, porque Salesforce SOQL `equal` es
        // case-sensitive. Si difiere, los registros recién creados no aparecen.
        let rut = titularRutNormalized
        let empresa = selectedEnterprise?.empresaC ?? ""

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] loadMembers()")
        print("   rut (normalized): \(rut)")
        print("   rut (raw AppStatusManager): \(AppStatusManager.rut ?? "(nil)")")
        print("   empresa: \(empresa)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        Task {
            let result = await Network.shared.getFamilyGroupMembers(rut: rut, empresa: empresa)

            var didSucceed = false
            await MainActor.run {
                switch result {
                case .success(let response):
                    let allMembers = response.data?.first?.values.first ?? []
                    // Reset de animación ANTES de renderizar las cards (estado inicial: invisible)
                    membersAnimated = false
                    // 1º actualizar datos, 2º apagar loading (Clean Transitions — CLAUDE.md)
                    members = allMembers
                    isLoading = false
                    print("👨‍👩‍👧 [GrupoFamiliar] Miembros cargados: \(members.count)")

                    // Check sobre-límite (después de apagar loading para no competir con la transición)
                    if members.count > maxCargas {
                        showOverLimitModal = true
                    }
                    didSucceed = true
                case .failure(let error):
                    print("👨‍👩‍👧 [GrupoFamiliar] Error cargando miembros: \(error.message)")
                    members = []
                    isLoading = false
                    membersAnimated = false
                }
            }

            // Pequeño buffer (~100ms) para que SwiftUI complete el render del memberListView
            // con las cards en su estado inicial (opacity 0, offset 18). Luego disparar la
            // animación en un frame separado evita que se hagan batching con isLoading=false.
            if didSucceed {
                try? await Task.sleep(nanoseconds: 100_000_000)
                await MainActor.run {
                    withAnimation { membersAnimated = true }
                }
            }
        }
    }

    func registerUser() {
        // 1) Validación inline — si falla, no continúa
        guard runAddValidation() else { return }

        // 2) Loading ON inmediatamente (antes de cualquier trabajo síncrono)
        //    para que el spinner aparezca apenas el usuario toca "Agregar".
        isAddLoading = true

        // 3) Transformaciones finales (paridad con web onFinish)
        let rutClean = addRut.filter { $0.isLetter || $0.isNumber }.uppercased()
        // RUT del titular: misma normalización vía helper compartido. Garantiza que
        // `cedula_titular` enviado aquí matche exactamente el filtro de `loadMembers()`.
        let titularRutClean = titularRutNormalized
        let nameTrim = addName.trimmingCharacters(in: .whitespaces)
        let lastNameTrim = addLastName.trimmingCharacters(in: .whitespaces)
        let titularEmail: String = {
            guard let user = users.first, !user.isInvalidated,
                  let record = user.records.first else { return "" }
            return record.PersonEmail ?? ""
        }()
        let titularPhone: String = {
            guard let user = users.first, !user.isInvalidated,
                  let record = user.records.first else { return "" }
            return (record.Phone ?? "").filter { $0.isNumber }
        }()
        let emailFinal = addIsMinor ? titularEmail : addEmail.trimmingCharacters(in: .whitespaces).lowercased()
        let phoneFinal = addIsMinor ? titularPhone : addPhone.trimmingCharacters(in: .whitespaces)

        // 3) Construcción del request body (paridad con AddCargaModal.tsx onFinish)
        var values: [String: String?] = [
            "nomenclatura_id": "RUT",
            "cedula_id": rutClean,
            "name": nameTrim,
            "lastName": lastNameTrim,
            "email": emailFinal,
            "phone": phoneFinal,
            "relacion_titular": "",
            "cedula_titular": titularRutClean
        ]
        if let empresaId = selectedEnterprise?.empresaC, !empresaId.isEmpty {
            values["company"] = empresaId
        }
        if shouldSendEmpresaSolicitada {
            values["empresa_solicitada"] = selectedEnterprise?.nombreFlujoC
        }
        let formValues = values.compactMapValues { $0 }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] REGISTRAR CARGA — DEBUG COMPLETO")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("   📌 INPUTS:")
        print("      addRut (raw): \"\(addRut)\"")
        print("      rutClean: \"\(rutClean)\"")
        print("      addName (raw): \"\(addName)\"")
        print("      nameTrim: \"\(nameTrim)\"")
        print("      addLastName (raw): \"\(addLastName)\"")
        print("      lastNameTrim: \"\(lastNameTrim)\"")
        print("      addIsMinor: \(addIsMinor)")
        print("      addEmail (raw): \"\(addEmail)\"")
        print("      emailFinal: \"\(emailFinal)\"")
        print("      addPhone (raw): \"\(addPhone)\"")
        print("      phoneFinal: \"\(phoneFinal)\"")
        print("   📌 TITULAR:")
        print("      AppStatusManager.rut: \"\(AppStatusManager.rut ?? "nil")\"")
        print("      titularRutNormalized: \"\(titularRutNormalized)\"")
        print("      titularRutClean: \"\(titularRutClean)\"")
        print("      titularEmail: \"\(titularEmail)\"")
        print("      titularPhone: \"\(titularPhone)\"")
        print("   📌 EMPRESA:")
        print("      selectedEnterprise: \(selectedEnterprise != nil ? "EXISTS" : "NIL")")
        print("      selectedEnterprise?.empresaC: \"\(selectedEnterprise?.empresaC ?? "nil")\"")
        print("      selectedEnterprise?.nombreFlujoC: \"\(selectedEnterprise?.nombreFlujoC ?? "nil")\"")
        print("      selectedEnterprise?.grupoFamiliarC: \(selectedEnterprise?.grupoFamiliarC ?? false)")
        print("      shouldSendEmpresaSolicitada: \(shouldSendEmpresaSolicitada)")
        print("   📌 CONDICIONES:")
        let hasCompany = (selectedEnterprise?.empresaC != nil && !(selectedEnterprise?.empresaC ?? "").isEmpty)
        print("      ¿Se agrega 'company'? \(hasCompany) (empresaC no nil ni vacío)")
        print("      ¿Se agrega 'empresa_solicitada'? \(shouldSendEmpresaSolicitada)")
        print("   📌 BODY FINAL (formValues):")
        for (k, v) in formValues.sorted(by: { $0.key < $1.key }) {
            print("      \(k): \"\(v)\"")
        }
        print("   📌 KEYS PRESENTES: \(formValues.keys.sorted())")
        print("   📌 COMPARACIÓN CON WEB:")
        print("      ¿Tiene 'company'? \(formValues["company"] != nil)")
        print("      ¿Tiene 'empresa_solicitada'? \(formValues["empresa_solicitada"] != nil)")
        print("      ¿Tiene 'cedula_titular'? \(formValues["cedula_titular"] != nil)")
        print("      ¿Tiene 'nomenclatura_id'? \(formValues["nomenclatura_id"] != nil)")
        if let prettyData = try? JSONSerialization.data(withJSONObject: formValues, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("   📦 REQUEST BODY JSON (pretty):")
            print(prettyString)
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        Task {
            print("👨‍👩‍👧 [GrupoFamiliar] ⏳ Llamando sendSignUpForm...")
            let result = await Network.shared.sendSignUpForm(formValues)
            print("👨‍👩‍👧 [GrupoFamiliar] 📬 sendSignUpForm retornó")
            switch result {
            case .success(let response):
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("👨‍👩‍👧 [GrupoFamiliar] ✅ Registro exitoso")
                print("   statusCode: \(response.statusCode)")
                print("   message: \(response.message)")
                print("   error: \(response.error ?? false)")
                print("   → esperando 4s para propagación Salesforce...")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                // Delay de 4s (paridad web)
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                print("👨‍👩‍👧 [GrupoFamiliar] 🔄 4s transcurridos → recargando lista de miembros...")
                await MainActor.run {
                    isAddLoading = false
                    showAddModal = false
                    resetAddForm()
                    showConfettiHearts = true
                    HapticManager.success()
                    isLoading = true
                    loadMembers()
                    ReviewManager.shared.requestReviewIfNeeded()
                }
            case let .failure(error):
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("👨‍👩‍👧 [GrupoFamiliar] ❌ Error en registro")
                print("   id: \(error.id)")
                print("   name: \(error.name)")
                print("   message: \(error.message)")
                print("   httpCode: \(error.httpCode ?? -1)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                await MainActor.run { isAddLoading = false }

                // Detección "usuario ya existe" (paridad web: httpCode 400 o mensaje contiene keywords)
                let msg = error.message.lowercased()
                let userExists = error.httpCode == 400
                    || msg.contains("existe")
                    || msg.contains("already exists")
                    || msg.contains("duplicate")

                if userExists {
                    AppStatusManager.error(AppError(
                        id: "api.error.AllReadyExist",
                        name: "",
                        message: "El usuario que intenta agregar ya existe."
                    ))
                } else {
                    // Modal local con icono animado (paridad con otros dialogs del módulo)
                    await MainActor.run { showGenericErrorModal = true }
                }
            }
        }
    }

    func prepareEdit(member: FamilyGroupMember) {
        editingMember = member
        editRut = member.rut
        editFirstName = member.firstName
        editLastName = member.lastName
        editEmail = member.email
        editPhone = member.phone
        editAddress = member.address
        editGender = member.gender

        // Parsear fecha
        let bd = member.birthdate
        if !bd.isEmpty {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            editBirthdate = f.date(from: bd) ?? Date()
        } else {
            editBirthdate = Date()
        }

        // Guardar snapshot para detectar cambios (isDirty) — paridad con web
        initialEditValues = EditSnapshot(
            firstName: editFirstName,
            lastName: editLastName,
            email: editEmail,
            phone: editPhone,
            address: editAddress,
            gender: editGender,
            birthdate: editBirthdate
        )

        // Limpiar errores previos
        editFirstNameError = nil
        editLastNameError = nil
        editEmailError = nil
        editPhoneError = nil
        editBirthdateError = nil

        withAnimation(.easeInOut(duration: 0.25)) {
            showEditModal = true
        }
    }

    func saveEdit() {
        // 1) Validación inline — si falla, no continúa
        guard runEditValidation() else { return }

        guard let pacienteId = editingMember?.pacienteC, !pacienteId.isEmpty else {
            print("❌ [GrupoFamiliar] No se puede editar: Paciente__c es nil o vacío")
            return
        }

        // 2) Loading ON inmediato
        isEditLoading = true

        // 3) Transformaciones finales (paridad con web handleEditSubmit)
        let nameTrim = editFirstName.trimmingCharacters(in: .whitespaces)
        let lastNameTrim = editLastName.trimmingCharacters(in: .whitespaces)
        let emailFinal = editEmail.trimmingCharacters(in: .whitespaces).lowercased()
        let phoneFinal = editPhone.trimmingCharacters(in: .whitespaces)
        let addressFinal = editAddress.trimmingCharacters(in: .whitespaces)

        // Gender a español para backend (paridad web: Male→Hombre, Female→Mujer, vacío→"")
        let genderToSend: String = {
            switch editGender {
            case "Male": return "Hombre"
            case "Female": return "Mujer"
            default: return ""
            }
        }()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let birthdateStr = formatter.string(from: editBirthdate)

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] EDITAR MIEMBRO")
        print("   Paciente__c: \(pacienteId)")
        print("   ECC Id: \(editingMember?.Id ?? "(nil)")")
        print("   nombre: \(nameTrim) \(lastNameTrim)")
        print("   email: \(emailFinal) phone: \(phoneFinal)")
        print("   address: \(addressFinal)")
        print("   birthdate: \(birthdateStr) gender: \(genderToSend) (raw: \(editGender))")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        Task {
            let result = await Network.shared.editFamilyGroupMember(
                pacienteId: pacienteId,
                firstName: nameTrim,
                lastName: lastNameTrim,
                email: emailFinal,
                phone: phoneFinal,
                birthdate: birthdateStr,
                address: addressFinal,
                gender: genderToSend
            )
            await MainActor.run {
                isEditLoading = false
                switch result {
                case .success:
                    print("👨‍👩‍👧 [GrupoFamiliar] ✅ Edición exitosa → mostrando modal éxito")
                    showEditModal = false
                    editingMember = nil
                    initialEditValues = nil
                    // Mostrar modal de éxito con animación
                    editSuccessIconScale = 0.0
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showEditSuccessModal = true
                    }
                case .failure(let error):
                    print("👨‍👩‍👧 [GrupoFamiliar] ❌ Error edición: \(error.message)")
                    showGenericErrorModal = true
                }
            }
        }
    }

    func performDelete(member: FamilyGroupMember) {
        guard let eccId = member.Id, !eccId.isEmpty else { return }
        isDeletingLoading = true

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] ELIMINAR MIEMBRO: \(member.fullName)")
        print("   ECC Id (Campo_2__c): \(eccId)")
        print("   Paciente__c: \(member.pacienteC ?? "(nil)")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        Task {
            let result = await Network.shared.deleteFamilyGroupMember(eccId: eccId)
            await MainActor.run {
                isDeletingLoading = false
                deletingMember = nil
                switch result {
                case .success:
                    print("👨‍👩‍👧 [GrupoFamiliar] ✅ Eliminado exitosamente")
                    // Actualización optimista
                    members.removeAll { $0.Id == eccId }
                    if members.count <= maxCargas {
                        showOverLimitModal = false
                    }
                    // Mostrar modal de éxito con animación
                    deleteSuccessIconScale = 0.0
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showDeleteSuccessModal = true
                    }
                case .failure(let error):
                    print("👨‍👩‍👧 [GrupoFamiliar] ❌ Error eliminación: \(error.message)")
                    showGenericErrorModal = true
                }
            }
        }
    }

    func resetAddForm() {
        addRut = ""
        addName = ""
        addLastName = ""
        addEmail = ""
        addPhone = ""
        addBirthdate = nil
        addIsMinor = false
        addRutError = nil
        addNameError = nil
        addLastNameError = nil
        addBirthdateError = nil
        addEmailError = nil
        addPhoneError = nil
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Extracted Sub-Views (evita let en @ViewBuilder)
    // ══════════════════════════════════════════════════════

    private var toolbarTitle: some View {
        let tAttr = fgConfig.seccionPrincipal.tituloAttr
        return Text(fgConfig.seccionPrincipal.titulo.isEmpty ? "Grupo Familiar" : fgConfig.seccionPrincipal.titulo)
            .font(Font.custom(
                tAttr.font.isEmpty ? "FiraSans-Bold" : tAttr.font,
                size: CGFloat(Int(tAttr.size) ?? 21)
            ))
            .foregroundColor(Color(hex: tAttr.color.isEmpty ? "#00BBDC" : tAttr.color))
    }

    private var toolbarBackButton: some View {
        let backColor = fgConfig.backArrow.colorBackArrow
        return Button {
            HapticManager.impact(style: .light)
            presentation.wrappedValue.dismiss()
        } label: {
            Image("back")
                .renderingMode(.template)
                .foregroundColor(Color(hex: backColor.isEmpty ? "#00BBDC" : backColor))
        }
    }

    /// Avatar de miembro: muestra el icono de LinkIconoUsuarios sobre el círculo,
    /// o las iniciales del miembro como fallback si la URL está vacía.
    @ViewBuilder
    private func memberAvatar(member: FamilyGroupMember, size: CGFloat) -> some View {
        let iconUrl = fgConfig.seccionPrincipal.iconoUsuarios
        let avatarBg = fgConfig.fondoAvatar.colorFondoAvatar
        ZStack {
            Circle()
                .fill(Color(hex: avatarBg.isEmpty ? "#00BBDC" : avatarBg))
                .frame(width: size, height: size)

            if !iconUrl.isEmpty, let url = URL(string: iconUrl) {
                CachedAsyncImage(
                    url: url,
                    content: { image in
                        image.resizable().scaledToFit()
                            .frame(width: size * 0.55, height: size * 0.55)
                    },
                    placeholder: {
                        ProgressView().frame(width: size * 0.55, height: size * 0.55)
                    }
                )
                .colorMultiply(.white)
            } else {
                Text(member.initials)
                    .font(Font.custom("FiraSans-Bold", size: size * 0.37))
                    .foregroundColor(.white)
            }
        }
    }

    private var addModalFooter: some View {
        let btnCancel = fgConfig.seccionAgregar.botonCancelar
        let btnAdd = fgConfig.seccionAgregar.botonAgregar

        return HStack(spacing: 12) {
            Button {
                if !isAddLoading { closeAddModal() }
            } label: {
                Text(btnCancel.texto.isEmpty ? "Cancelar" : btnCancel.texto)
                    .font(Font.custom("FiraSans-Bold", size: 15))
                    .foregroundColor(Color(hex: btnCancel.colorTextoActivo.isEmpty ? "#555555" : btnCancel.colorTextoActivo))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: btnCancel.colorFondoActivo.isEmpty ? "#FFFFFF" : btnCancel.colorFondoActivo)))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(hex: "#CCCCCC"), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isAddLoading)

            Button {
                registerUser()
            } label: {
                ZStack {
                    Text(btnAdd.texto.isEmpty ? "Agregar" : btnAdd.texto)
                        .font(Font.custom("FiraSans-Bold", size: 15))
                        .foregroundColor(Color(hex: btnAdd.colorTextoActivo.isEmpty ? "#FFFFFF" : btnAdd.colorTextoActivo))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(isAddFormValid
                                      ? Color(hex: btnAdd.colorFondoActivo.isEmpty ? "#00BBDC" : btnAdd.colorFondoActivo)
                                      : Color(hex: btnAdd.colorFondoInactivo.isEmpty ? "#EDEDED" : btnAdd.colorFondoInactivo))
                        )
                        .opacity(isAddLoading ? 0.5 : 1.0)
                    if isAddLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isAddFormValid || isAddLoading)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private var editModalFooter: some View {
        let btnCancel = fgConfig.seccionModificar.botonCancelar
        let btnMod = fgConfig.seccionModificar.botonModificar

        return HStack(spacing: 12) {
            Button {
                if !isEditLoading { closeEditModal() }
            } label: {
                Text(btnCancel.texto.isEmpty ? "Cancelar" : btnCancel.texto)
                    .font(Font.custom("FiraSans-Bold", size: 15))
                    .foregroundColor(Color(hex: btnCancel.colorTextoActivo.isEmpty ? "#555555" : btnCancel.colorTextoActivo))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: btnCancel.colorFondoActivo.isEmpty ? "#FFFFFF" : btnCancel.colorFondoActivo)))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(hex: "#CCCCCC"), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isEditLoading)

            Button {
                saveEdit()
            } label: {
                ZStack {
                    Text(btnMod.texto.isEmpty ? "Modificar Datos" : btnMod.texto)
                        .font(Font.custom("FiraSans-Bold", size: 15))
                        .foregroundColor(Color(hex: btnMod.colorTextoActivo.isEmpty ? "#FFFFFF" : btnMod.colorTextoActivo))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(isEditFormValid
                                      ? Color(hex: btnMod.colorFondoActivo.isEmpty ? "#00BBDC" : btnMod.colorFondoActivo)
                                      : Color(hex: btnMod.colorFondoInactivo.isEmpty ? "#EDEDED" : btnMod.colorFondoInactivo))
                        )
                        .opacity(isEditLoading ? 0.5 : 1.0)
                    if isEditLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isEditFormValid || isEditLoading)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private func deleteModalButtons(member: FamilyGroupMember, popCfg: FGPopupEliminarConfig) -> some View {
        let btnSi = popCfg.botonSi
        let btnNo = popCfg.botonNo

        return HStack(spacing: 12) {
            Button {
                performDelete(member: member)
            } label: {
                ZStack {
                    Text(btnSi.texto.isEmpty ? "Eliminar" : btnSi.texto)
                        .font(Font.custom("FiraSans-Bold", size: 15))
                        .foregroundColor(Color(hex: btnSi.colorTexto.isEmpty ? "#FFFFFF" : btnSi.colorTexto))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: btnSi.colorFondo.isEmpty ? "#FF4D4F" : btnSi.colorFondo)))
                        .opacity(isDeletingLoading ? 0.5 : 1.0)
                    if isDeletingLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.8)
                    }
                }
            }
            .disabled(isDeletingLoading)

            Button {
                deletingMember = nil
            } label: {
                Text(btnNo.texto.isEmpty ? "Cancelar" : btnNo.texto)
                    .font(Font.custom("FiraSans-Bold", size: 15))
                    .foregroundColor(Color(hex: btnNo.colorTexto.isEmpty ? "#555555" : btnNo.colorTexto))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: btnNo.colorFondo.isEmpty ? "#FFFFFF" : btnNo.colorFondo)))
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(hex: "#CCCCCC"), lineWidth: 1))
            }
            .disabled(isDeletingLoading)
        }
        .padding(.top, 4)
        .padding(.bottom, 18)
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Helpers
    // ══════════════════════════════════════════════════════

    func logFamilyGroupState() {
        let relation = selectedEnterprise?.relaciNConAseguradoC ?? "(nil)"
        let grupoFamiliar = selectedEnterprise?.grupoFamiliarC
        let nombreFlujo = selectedEnterprise?.nombreFlujoC ?? ""
        let enterpriseName = selectedEnterprise?.identificadorC ?? "(nil)"

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👨‍👩‍👧 [GrupoFamiliar] VISTA CARGADA")
        print("   Enterprise: \(enterpriseName)")
        print("   relaciNConAseguradoC: \"\(relation)\"")
        print("   grupoFamiliarC: \(grupoFamiliar != nil ? String(describing: grupoFamiliar!) : "(nil)")")
        print("   nombreFlujoC: \"\(nombreFlujo)\"")
        print("   isFamilyGroupAddEnabled: \(isFamilyGroupAddEnabled)")
        print("   shouldSendEmpresaSolicitada: \(shouldSendEmpresaSolicitada)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    /// Retorna el label dinámico para el campo en posición `index` del modal Editar.
    /// Labels del JSON: "Identificacion;Nombre;Apellido;Direccion;FechaNacimiento;Sexo;Correo;Telefono"
    func fgEditLabel(_ index: Int, fallback: String) -> String {
        let labels = fgConfig.seccionModificar.labels
        guard index < labels.count, !labels[index].isEmpty else { return fallback }
        return labels[index]
    }

    /// Retorna el label dinámico para el campo en posición `index` del modal Agregar.
    /// Labels del JSON: "Identificacion;TipoAfiliado;Nombre;Apellido;FechaNacimiento;Correo;Telefono"
    func fgAddLabel(_ index: Int, fallback: String) -> String {
        let labels = fgConfig.seccionAgregar.labels
        guard index < labels.count, !labels[index].isEmpty else { return fallback }
        return labels[index]
    }

    /// Genera el texto del modal over-limit reemplazando "/" por conteos dinámicos.
    /// Template de SF: "Actualmente posee / cargas activas, el máximo permitido es /.\n\nElimine / carga para poder continuar."
    func overLimitText(template: String, memberCount: Int, maxCount: Int) -> String {
        guard !template.isEmpty else {
            return "Tienes \(memberCount) cargas, el máximo es \(maxCount). Debes eliminar \(memberCount - maxCount) carga(s) para continuar."
        }
        let excess = memberCount - maxCount
        // Reemplaza los "/" de izquierda a derecha: 1er "/" → memberCount, 2do "/" → maxCount, 3ro "/" → excess
        var result = template
        let replacements = ["\(memberCount)", "\(maxCount)", "\(excess)"]
        for replacement in replacements {
            if let range = result.range(of: "/") {
                result = result.replacingCharacters(in: range, with: replacement)
            }
        }
        return result
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    func calculateAge(from birthDate: Date) -> Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
}
