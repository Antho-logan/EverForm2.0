import SwiftUI

struct CreateAccountView: View {
	@State private var email: String = ""
	@State private var password: String = ""
	@State private var confirm: String = ""

	var body: some View {
		Form {
			Section(header: Text("Create Account")) {
				TextField("Email", text: $email)
					.textContentType(.emailAddress)
					.keyboardType(.emailAddress)
				SecureField("Password", text: $password)
				SecureField("Confirm Password", text: $confirm)
			}
			Section {
				EFButton(title: "Create", style: .primary, fullWidth: true, accessibilityId: "create_account_primary_button") {}
			}
		}
		.navigationTitle("Create Account")
	}
}


