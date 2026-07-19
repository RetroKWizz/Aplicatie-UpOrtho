import SwiftUI

/// Ecran de login la nivel de aplicatie — afisat inainte de orice continut
/// (Home/Catalog necesita o sesiune Odoo autentificata, altfel raman pe date mock).
struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 72, height: 72)
                        .overlay {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(Color.accentColor)
                        }
                    Text("Autentificare")
                        .font(.title2.bold())
                    Text("Conecteaza-te cu contul tau UpOrtho pentru a continua.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 24)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    SecureField("Parola", text: $password)
                        .textContentType(.password)
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    if let error = session.loginError {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await session.login(username: email, password: password) }
                    } label: {
                        HStack {
                            Spacer()
                            if session.isLoggingIn {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Autentificare")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(session.isLoggingIn)
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionStore(client: MockOdooClient()))
}
