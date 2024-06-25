//
//  AuthView.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 25.06.2024.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthVM
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button(isSignUp ? "Sign Up" : "Sign In") {
                Task {
                    do {
                        if isSignUp {
                            try await authVM.signUp(email: email, password: password)
                        } else {
                            try await authVM.signIn(email: email, password: password)
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5.0)

            Button(isSignUp ? "Have an account? Sign In" : "Don't have an account? Sign Up") {
                isSignUp.toggle()
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthVM())
}
