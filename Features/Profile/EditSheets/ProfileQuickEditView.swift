import SwiftUI

struct ProfileQuickEditView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Account") {
                TextField("Name", text: $profile.name)
                    .textContentType(.name)
                TextField("Email", text: $profile.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                TextField("Phone", text: $profile.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }

            Section("Details") {
                DatePicker("Birthday", selection: $profile.birthdate, displayedComponents: .date)
                Picker("Sex", selection: $profile.sex) {
                    ForEach(UserProfile.Sex.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    // Save happens in parent when binding updates and Done is clicked, 
                    // effectively accepting the changes. 
                    // For persistent save, parent should call store.save()
                    dismiss()
                }
            }
        }
    }
}

