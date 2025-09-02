
import SwiftUI

@Observable
class SessionStore {
    var isLoggedIn: Bool = false

    func login(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        isLoggedIn = true
        return true
    }

    func logout() {
        isLoggedIn = false
    }
}
