// WorkflowContactSupportView.swift
import SwiftUI

struct WorkflowContactSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Contact Support").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Subject")
                        .font(.system(size: 11, weight: .semibold))
                    TextField("How can we help?", text: $subject)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Message")
                        .font(.system(size: 11, weight: .semibold))
                    TextEditor(text: $message)
                        .font(.system(size: 11))
                        .frame(height: 120)
                        .scrollContentBackground(.visible)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                }

                Text("Include your macOS version and app version for faster support.")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .padding()

            Spacer()

            Divider()

            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Send") {
                    // Send support email
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(subject.isEmpty || message.isEmpty)
            }
            .padding()
        }
        .frame(width: 450, height: 400)
    }
}
