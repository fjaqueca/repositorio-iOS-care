//
//  ProfileUpdateInformation.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/02/2023.
//

import SwiftUI
import RealmSwift

struct ProfileUpdateInformation: View {
    @Environment(\.presentationMode) var presentation
    @ObservedResults(User.self) private var users
    @State private var rut: String = ""
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var email: Field = .email
    @State private var phone: Field = .phone
    @State private var popup: Popup?
    @State private var isLoading: Bool = false
    @Binding var isObligatori: Bool

    // Animaciones
    @State private var avatarScale: CGFloat = 0.0
    @State private var avatarOpacity: Double = 0.0
    @State private var fieldsAnimated: Bool = false

    // Modal de éxito
    @State private var showSuccessModal: Bool = false
    @State private var successIconScale: CGFloat = 0.0

    private var userFirstName: String {
        users.first?.records.first?.FirstName ?? ""
    }
    private var userLastName: String {
        users.first?.records.first?.LastName ?? ""
    }
    private var userEmail: String {
        users.first?.records.first?.PersonEmail ?? ""
    }
    private var userInitials: String {
        let first = userFirstName.prefix(1).uppercased()
        let last = userLastName.prefix(1).uppercased()
        return "\(first)\(last)"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        Divider()

                        // MARK: - Header con avatar
                        profileHeader
                            .padding(.top, 24)
                            .padding(.bottom, 20)

                        Divider()
                            .padding(.horizontal, .margin)

                        // MARK: - Formulario
                        formSection
                            .padding(.top, 20)
                            .padding(.horizontal, .margin)
                    }
                }

                Spacer()

                // MARK: - Botón enviar
                submitButton
                    .padding(.horizontal, .margin)
                    .padding(.bottom, 16)
            }
            .blur(radius: showSuccessModal ? 3 : 0.000001)

            // Modal de éxito
            if showSuccessModal {
                successModal
                    .zIndex(80)
                    .transition(.opacity)
            }
        }
        .onAppear {
            email.value = users.first?.records.first?.PersonEmail ?? ""
            phone.value = users.first?.records.first?.Phone ?? ""
            name = users.first?.records.first?.FirstName ?? ""
            lastName = users.first?.records.first?.LastName ?? ""

            // Animación cascada campos
            fieldsAnimated = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { fieldsAnimated = true }
            }
        }
        .popup(item: $popup)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Datos Personales")
                    .font(Font.custom("FiraSans-Bold", size: 21))
                    .foregroundColor(Color(hex: "#00BBDC"))
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if isObligatori {
                        exit(0)
                    } else {
                        presentation.wrappedValue.dismiss()
                    }
                } label: {
                    Image("back")
                        .renderingMode(.template)
                        .foregroundColor(Color(hex: "#00BBDC"))
                }
            }
        }
        .tabBarHidden(true)
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Profile Header
    // ══════════════════════════════════════════════════════

    private var profileHeader: some View {
        VStack(spacing: 10) {
            // Avatar con iniciales + borde circular (paridad Android)
            ZStack {
                // Borde exterior
                Circle()
                    .stroke(Color(hex: "#00BBDC").opacity(0.3), lineWidth: 2.5)
                    .frame(width: 84, height: 84)

                // Círculo relleno
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0095B3"), Color(hex: "#00BBDC"), Color(hex: "#33CFEA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Text(userInitials)
                    .font(Font.custom("FiraSans-Bold", size: 26))
                    .foregroundColor(.white)
            }
            .scaleEffect(avatarScale)
            .opacity(avatarOpacity)
            .onAppear {
                avatarScale = 0.0
                avatarOpacity = 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.3)) {
                        avatarScale = 1.0
                        avatarOpacity = 1.0
                    }
                }
            }

            // Nombre
            Text("\(userFirstName) \(userLastName)")
                .font(Font.custom("FiraSans-Bold", size: 18))
                .foregroundColor(Color(hex: "#222222"))

            // Email
            if !userEmail.isEmpty {
                Text(userEmail)
                    .font(Font.custom("FiraSans-Regular", size: 14))
                    .foregroundColor(Color(hex: "#888888"))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Form Section (paridad Android)
    // ══════════════════════════════════════════════════════

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Subtítulo "Información personal"
            Text("Información personal")
                .font(Font.custom("FiraSans-Bold", size: 15))
                .foregroundColor(Color(hex: "#00BBDC"))
                .padding(.bottom, 2)
                .cascadeAnimation(animated: fieldsAnimated, index: 0)

            // Número de identificación (RUT — solo lectura)
            cardField(
                icon: "person.text.rectangle",
                label: "Número de identificación",
                text: .constant(AppStatusManager.rut ?? ""),
                disabled: true
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 1)

            // Nombre
            cardField(
                icon: "person",
                label: "Nombre",
                text: $name
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 2)

            // Apellido
            cardField(
                icon: "person",
                label: "Apellido",
                text: $lastName
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 3)

            // Email
            cardFieldWithValidation(
                icon: "envelope.fill",
                label: "Email",
                field: $email
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 4)

            // Teléfono
            cardFieldWithValidation(
                icon: "phone.fill",
                label: "Teléfono",
                field: $phone
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 5)
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Card Field (paridad Android cards con ícono)
    // ══════════════════════════════════════════════════════

    /// Campo estilo card con ícono a la izquierda + label arriba del valor (paridad Android)
    private func cardField(icon: String, label: String, text: Binding<String>, keyboard: UIKeyboardType = .default, disabled: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Ícono
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: "#00BBDC"))
                .frame(width: 24)

            // Label + TextField
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(Font.custom("FiraSans-Regular", size: 12))
                    .foregroundColor(Color(hex: "#888888"))

                TextField("", text: text)
                    .font(Font.custom("FiraSans-Regular", size: 15))
                    .foregroundColor(disabled ? Color(hex: "#999999") : Color(hex: "#333333"))
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .disabled(disabled)
            }

            Spacer()

            // Candado para campos readonly
            if disabled {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#CCCCCC"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
        )
    }

    /// Card field que usa FieldView para validación (email, teléfono)
    private func cardFieldWithValidation(icon: String, label: String, field: Binding<Field>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // Ícono
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "#00BBDC"))
                    .frame(width: 24)

                // Label + FieldView
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                        .foregroundColor(Color(hex: "#888888"))

                    // Extraer el TextField del FieldView — usamos el binding directo
                    TextField(field.wrappedValue.description, text: Binding(
                        get: { field.wrappedValue.value ?? "" },
                        set: { field.wrappedValue.value = $0 }
                    ))
                    .font(Font.custom("FiraSans-Regular", size: 15))
                    .foregroundColor(Color(hex: "#333333"))
                    .keyboardType(field.wrappedValue.keyboardType)
                    .autocapitalization(.none)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        field.wrappedValue.validationErrorMessage != nil
                            ? Color(hex: "#FF4D4F")
                            : Color(hex: "#E0E0E0"),
                        lineWidth: 1
                    )
            )

            // Error inline debajo de la card
            if let error = field.wrappedValue.validationErrorMessage {
                Text(error)
                    .font(Font.custom("FiraSans-Regular", size: 12))
                    .foregroundColor(Color(hex: "#FF4D4F"))
                    .padding(.leading, 50)
                    .padding(.top, 4)
            }
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Submit Button
    // ══════════════════════════════════════════════════════

    private var submitButton: some View {
        Button {
            updateProfile()
        } label: {
            ZStack {
                Text("Enviar")
                    .font(Font.custom("FiraSans-Bold", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isLoading ? Color.gray.opacity(0.4) : Color(hex: "#00BBDC"))
                    )
                    .opacity(isLoading ? 0.5 : 1.0)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading || (!phone.isValid && ((users.first?.records.first?.Phone?.isEmpty) == nil)) || (!email.isValid && ((users.first?.records.first?.PersonEmail) == nil)))
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Success Modal
    // ══════════════════════════════════════════════════════

    private var successModal: some View {
        GeometryReader { geo in
            let dialogWidth = min(geo.size.width * 0.85, 340)

            ZStack {
                Color.black.opacity(0.30)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Button {
                            dismissSuccessModal()
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

                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E8F5E9"))
                            .frame(width: 64, height: 64)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(Color(hex: "#00BBDC"))
                    }
                    .scaleEffect(successIconScale)
                    .opacity(Double(successIconScale))
                    .onAppear {
                        successIconScale = 0.0
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            successIconScale = 1.0
                        }
                    }

                    Text("¡Solicitud enviada!")
                        .font(Font.custom("FiraSans-Bold", size: 17))
                        .foregroundColor(Color(hex: "#333333"))
                        .multilineTextAlignment(.center)

                    Text("Será verificada por nuestro equipo y lo contactaremos a la brevedad.")
                        .font(Font.custom("FiraSans-Regular", size: 13))
                        .foregroundColor(Color(hex: "#777777"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                    Button {
                        dismissSuccessModal()
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

    private func dismissSuccessModal() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showSuccessModal = false
        }
        presentation.wrappedValue.dismiss()
        isObligatori = false
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Network
    // ══════════════════════════════════════════════════════

    public func updateProfile() {
        Task {
            isLoading = true
            let result = await Network.shared.updateProfile(
                rut: AppStatusManager.rut ?? "",
                lastName: lastName,
                firstName: name,
                email: email.value,
                phone: phone.value
            )
            isLoading = false
            switch result {
            case .success:
                if isObligatori {
                    presentation.wrappedValue.dismiss()
                    isObligatori = false
                } else {
                    successIconScale = 0.0
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSuccessModal = true
                    }
                }
                await AppStatusManager.loadUser()
            case let .failure(error):
                AppStatusManager.error(error)
            }
        }
    }
}

// ══════════════════════════════════════════════════════
// MARK: - Cascade Animation Modifier
// ══════════════════════════════════════════════════════

private struct CascadeAnimationModifier: ViewModifier {
    let animated: Bool
    let index: Int

    func body(content: Content) -> some View {
        content
            .opacity(animated ? 1.0 : 0.0)
            .offset(y: animated ? 0 : 20)
            .scaleEffect(animated ? 1.0 : 0.92)
            .animation(
                .spring(response: 0.65, dampingFraction: 0.75)
                    .delay(Double(index) * 0.08),
                value: animated
            )
    }
}

private extension View {
    func cascadeAnimation(animated: Bool, index: Int) -> some View {
        modifier(CascadeAnimationModifier(animated: animated, index: index))
    }
}
