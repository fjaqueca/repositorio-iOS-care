//
//  ProfileChangePassword.swift
//  CareAssistance
//
//  Created by Lara Dubs on 18/10/2022.
//

import SwiftUI
import RealmSwift

struct ProfileChangePassword: View {
    @Environment(\.presentationMode) var presentation
    @ObservedResults(User.self) private var users
    @State private var oldPasswordField: Field = .oldPassword
    @State private var newPasswordField: Field = .newPassword
    @State private var passwordConfirmField: Field = .passwordConfirm
    @State private var isLoading: Bool = false

    // Animaciones
    @State private var avatarScale: CGFloat = 0.0
    @State private var avatarOpacity: Double = 0.0
    @State private var fieldsAnimated: Bool = false

    // Modal de éxito
    @State private var showSuccessModal: Bool = false
    @State private var successIconScale: CGFloat = 0.0

    private var userFirstName: String {
        guard let user = users.first, !user.isInvalidated,
              let record = user.records.first else { return "" }
        return record.FirstName ?? ""
    }
    private var userLastName: String {
        guard let user = users.first, !user.isInvalidated,
              let record = user.records.first else { return "" }
        return record.LastName ?? ""
    }
    private var userEmail: String {
        guard let user = users.first, !user.isInvalidated,
              let record = user.records.first else { return "" }
        return record.PersonEmail ?? ""
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

                // MARK: - Botón guardar
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
            fieldsAnimated = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { fieldsAnimated = true }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Cambiar Contraseña")
                    .font(Font.custom("FiraSans-Bold", size: 21))
                    .foregroundColor(Color(hex: "#00BBDC"))
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    HapticManager.impact(style: .light)
                    presentation.wrappedValue.dismiss()
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
            // Avatar con borde circular (paridad Android)
            ZStack {
                Circle()
                    .stroke(Color(hex: "#00BBDC").opacity(0.3), lineWidth: 2.5)
                    .frame(width: 84, height: 84)

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

            Text("\(userFirstName) \(userLastName)")
                .font(Font.custom("FiraSans-Bold", size: 18))
                .foregroundColor(Color(hex: "#222222"))

            if !userEmail.isEmpty {
                Text(userEmail)
                    .font(Font.custom("FiraSans-Regular", size: 14))
                    .foregroundColor(Color(hex: "#888888"))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Form Section
    // ══════════════════════════════════════════════════════

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Subtítulo
            Text("Seguridad")
                .font(Font.custom("FiraSans-Bold", size: 15))
                .foregroundColor(Color(hex: "#00BBDC"))
                .padding(.bottom, 2)
                .cascadeAnimation(animated: fieldsAnimated, index: 0)

            // Descripción
            Text("Crea una contraseña que contenga mínimo 8 dígitos, una mayúscula, un número y un carácter especial.")
                .font(Font.custom("FiraSans-Regular", size: 13))
                .foregroundColor(Color(hex: "#777777"))
                .padding(.bottom, 4)
                .cascadeAnimation(animated: fieldsAnimated, index: 0)

            // Contraseña actual
            cardFieldPassword(
                icon: "lock",
                label: "Contraseña actual",
                field: $oldPasswordField
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 1)

            // Nueva contraseña
            cardFieldPassword(
                icon: "lock.rotation",
                label: "Nueva contraseña",
                field: $newPasswordField
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 2)

            // Confirmar contraseña
            cardFieldPassword(
                icon: "lock.shield",
                label: "Confirmar contraseña",
                field: $passwordConfirmField
            )
            .cascadeAnimation(animated: fieldsAnimated, index: 3)
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Card Field Password (paridad Android)
    // ══════════════════════════════════════════════════════

    private func cardFieldPassword(icon: String, label: String, field: Binding<Field>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "#00BBDC"))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                        .foregroundColor(Color(hex: "#888888"))

                    FieldView(field: field)
                }

                Spacer(minLength: 0)
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
        }
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Submit Button
    // ══════════════════════════════════════════════════════

    private var submitButton: some View {
        Button {
            changePassword()
        } label: {
            ZStack {
                Text("Guardar")
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
        .bounceOnTap()
        .disabled(!passwordConfirmField.isValid || isLoading)
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

                    Text("¡Contraseña actualizada!")
                        .font(Font.custom("FiraSans-Bold", size: 17))
                        .foregroundColor(Color(hex: "#333333"))
                        .multilineTextAlignment(.center)

                    Text("Su contraseña ha sido actualizada correctamente.")
                        .font(Font.custom("FiraSans-Regular", size: 13))
                        .foregroundColor(Color(hex: "#777777"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                    Button {
                        HapticManager.success()
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
                    .bounceOnTap()
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
    }

    // ══════════════════════════════════════════════════════
    // MARK: - Network
    // ══════════════════════════════════════════════════════

    public func changePassword() {
        guard let oldPassword = oldPasswordField.value, let newPassword = passwordConfirmField.value else {
            isLoading = false
            return
        }
        isLoading = true
        Task {
            let result = await Network.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            isLoading = false
            switch result {
            case .success:
                successIconScale = 0.0
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSuccessModal = true
                }
            case let .failure(error):
                AppStatusManager.error(error)
            }
        }
    }
}

// ══════════════════════════════════════════════════════
// MARK: - Cascade Animation Modifier
// ══════════════════════════════════════════════════════

private struct PasswordFieldCascadeModifier: ViewModifier {
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
        modifier(PasswordFieldCascadeModifier(animated: animated, index: index))
    }
}
