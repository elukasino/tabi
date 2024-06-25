//
//  AuthVM.swift
//  myTabi
//
//  Created by Lukáš Cmíral on 24.06.2024.
//

import Foundation
import FirebaseAuth

class AuthVM: ObservableObject {
    @Published var user: User?

    init() {
        self.user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
        } catch {
            throw error
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
    }

    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
        } catch {
            throw error
        }
    }
}
