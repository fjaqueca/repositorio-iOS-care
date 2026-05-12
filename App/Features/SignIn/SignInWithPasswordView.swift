//
//  SignInWithPasswordView.swift
//  CareAssistance
//
//  Created by The App Master on 19/11/2025.
//

import SwiftUI
import CachedAsyncImage

extension String {
    fileprivate static var signInRut: String {
        "sign_in_rut"
    }
}
struct SignInWithPasswordView: View {
    @State private var isPresenting = false
    @State var rut: String
    @State private var passwordField: Field = .password
    @State private var isLoading: Bool = false
    @Binding var UIState: PreLoginUIState
    @State private var showCustomPopup: Bool = false
    @State private var back: Bool = false
    @State private var isPasswordVisible: Bool = false
    @FocusState private var isPasswordFocused: Bool
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        ZStack{
            VStack(spacing: .margin) {
                ScrollView{
                    title
                        .padding(.bottom, 6)
                    subtitle
                        .padding(.bottom, 6)
                    subText
                        .padding(.bottom, 24)
                    passwordInputField
                    
                    Button {
                        isPresenting = true
                    } label: {
                        Text(UIState.loginUIState.btnMissPassword.textBtn != "" ? UIState.loginUIState.btnMissPassword.textBtn : "¿Olvidaste tu contraseña?")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .font(.appCallout)
                    .foregroundColor(UIState.loginUIState.btnMissPassword.colorTextBtn != "" ? Color(hex:UIState.loginUIState.btnMissPassword.colorTextBtn) : .secondaryText)
                }
                Spacer()
                
                PrimaryButton(title: "Iniciar Sesion", UIStateBtn: UIState.loginUIState.btnLogin) {
                    HapticManager.impact(style: .medium)
                    signIn()
                }
                .bounceOnTap()
                .disabled(passwordField.value?.isEmpty ?? true || isLoading)
                .opacity(isLoading ? 0.6 : 1.0)
                .padding(.bottom, .margin)
            }
            .padding(.horizontal, .margin)
            .padding(.bottom, .margin)
            .slideInFromRight()
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Group {
                    if UIState.loginUIState.imageBackground != "" {
                        CachedAsyncImage(
                            url: URL(string: UIState.loginUIState.imageBackground ),
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
            .navigationLink(isActive: $isPresenting) {
                SignInPasswordRecovery(UIState: $UIState, isPresenting: $isPresenting)
            }
            
            // 🔒 Overlay de loading para prevenir interacción durante login
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Iniciando sesión...")
                            .foregroundColor(.white)
                            .font(.appBodyBold)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: isLoading)
            }
            
        }
        .allowsHitTesting(!isLoading)  // 🔒 Bloquear toda interacción durante login
    }
    public var title: some View {
        Text(UIState.loginUIState.title.text != "" ? UIState.loginUIState.title.text : "¡Hola de nuevo!")
            .font(Font.custom("FiraSans-Bold", size: CGFloat(Int(UIState.loginUIState.title.sizeText) ?? 14)))
            .foregroundColor(UIState.loginUIState.title.colorText != "" ? Color(hex: UIState.loginUIState.title.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public var subtitle: some View {
        Text(UIState.loginUIState.subTitle.text != "" ? UIState.loginUIState.subTitle.text : "Bienvenido, descubramos juntos cómo vivir sano y saludable.")
            .font(Font.custom("FiraSans-Regular", size: CGFloat(Int(UIState.loginUIState.subTitle.sizeText) ?? 14)))
            .foregroundColor(UIState.loginUIState.subTitle.colorText != "" ? Color(hex: UIState.loginUIState.subTitle.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    public var subText: some View {
        Text(UIState.loginUIState.subTextPassword.text)
            .font(Font.custom(UIState.loginUIState.subTextPassword.font, size: CGFloat(Int(UIState.loginUIState.subTextPassword.sizeText) ?? 14)))
            .foregroundColor(UIState.loginUIState.subTextPassword.colorText != "" ? Color(hex: UIState.loginUIState.subTextPassword.colorText) : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var passwordInputField: some View {
        let hasValue = !(passwordField.value ?? "").isEmpty
        let isError = passwordField.validationErrorMessage != nil
        let accentColor = Color(hex: "#00BBDC")
        let borderColor = isError ? Color(hex: "#E74C3C") :
                          (isPasswordFocused || hasValue) ? accentColor :
                          Color(hex: "#C8CDD2")

        return VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isPasswordFocused ? accentColor : Color(hex: "#8A9199"))

                    if isPasswordVisible {
                        TextField("Contraseña", text: Binding(
                            get: { passwordField.value ?? "" },
                            set: { passwordField.value = $0 }
                        ))
                        .font(Font.custom("FiraSans-Regular", size: 16))
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .focused($isPasswordFocused)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    } else {
                        SecureField("Contraseña", text: Binding(
                            get: { passwordField.value ?? "" },
                            set: { passwordField.value = $0 }
                        ))
                        .font(Font.custom("FiraSans-Regular", size: 16))
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .focused($isPasswordFocused)
                    }

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isPasswordFocused ? accentColor : Color(hex: "#8A9199"))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: isPasswordFocused ? 1.5 : 1)
                )

                // Label flotante incrustado en el borde
                Text(" Contraseña ")
                    .font(Font.custom("FiraSans-Medium", size: 12))
                    .foregroundColor(isPasswordFocused ? accentColor : Color(hex: "#6B7680"))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.97))
                    )
                    .padding(.leading, 14)
                    .offset(y: -8)
            }
            .animation(.easeInOut(duration: 0.2), value: isPasswordFocused)
            .animation(.easeInOut(duration: 0.2), value: isError)

            if let error = passwordField.validationErrorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                    Text(error)
                        .font(Font.custom("FiraSans-Regular", size: 12))
                }
                .foregroundColor(Color(hex: "#E74C3C"))
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 2)
        .animation(.easeInOut(duration: 0.25), value: passwordField.validationErrorMessage != nil)
    }

    public func signIn() {
        guard let password = passwordField.value else {
            return
        }
        
        // 🔒 SEGURIDAD: Prevenir múltiples intentos de login simultáneos
        guard !isLoading else {
            print("⚠️ [UI SECURITY] Login ya en progreso, ignorando tap del usuario")
            return
        }
        
        isLoading = true
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔐 USUARIO INTENTA LOGIN DESDE UI")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("👤 RUT: \(rut)")
        print("⏰ UI Timestamp: \(Date())")
        
        Task {
            let result = await AppStatusManager.signIn(rut: rut.filter { $0.isLetter || $0.isNumber }, password: password)
            
            // 🔒 IMPORTANTE: Asegurarse de actualizar isLoading en el thread principal
            await MainActor.run {
                isLoading = false
            }
            
            switch result {
                case .success:
                    print("✅ [UI] Login exitoso, guardando RUT")
                    UserDefaults.standard.set(rut, forKey: .signInRut)
                    
                case let .failure(error):
                    print("❌ [UI] Login fallido: \(error.localizedDescription)")
                    print("❌ [UI] HTTP Code: \(error.httpCode ?? -1)")
                    
                    // 📊 Registrar error específico en Firebase
                    FirebaseLogger.shared.log("❌ [UI] Error de login mostrado al usuario: \(error.message)")
                    
                    // Mostrar error al usuario
                    AppStatusManager.error(.unauthorized)
            }
            
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🏁 FIN DEL PROCESO DE LOGIN DESDE UI")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
    }
}
