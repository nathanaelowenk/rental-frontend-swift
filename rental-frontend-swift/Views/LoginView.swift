import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var isRegistering = false
    @State private var username = ""
    @State private var password = ""
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Logo and Header
                VStack(spacing: 16) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                        .symbolEffect(.bounce, value: isAnimating)
                        .onAppear {
                            isAnimating.toggle()
                        }
                    
                    Text(isRegistering ? "Create Account" : "Welcome Back")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.top, 60)
                
                // Form fields
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("Email", text: $username)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                            .textContentType(isRegistering ? .newPassword : .password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            if isRegistering {
                                await viewModel.register(username: username, password: password)
                            } else {
                                await viewModel.login(username: username, password: password)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: isRegistering ? "person.badge.plus.fill" : "arrow.right.circle.fill")
                            Text(isRegistering ? "Create Account" : "Sign In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                    .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1)
                    
                    Button(action: {
                        withAnimation {
                            isRegistering.toggle()
                            viewModel.errorMessage = nil
                        }
                    }) {
                        HStack {
                            Image(systemName: isRegistering ? "arrow.left" : "person.badge.plus")
                            Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Register")
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay {
                if viewModel.isLoading {
                    Color(.systemBackground)
                        .opacity(0.8)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
}

#Preview("Login") {
    LoginView()
        .environmentObject(AppViewModel())
}

#Preview("Registration") {
    struct RegistrationPreview: View {
        @State private var isRegistering = true
        
        var body: some View {
            LoginView()
                .environmentObject(AppViewModel())
                .onAppear {
                    isRegistering = true
                }
        }
    }
    
    return RegistrationPreview()
}
