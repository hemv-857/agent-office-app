// WorkflowFeedbackView.swift
import SwiftUI

struct WorkflowFeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var rating = 0
    @State private var feedback = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Feedback").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 16) {
                // Rating
                VStack(spacing: 8) {
                    Text("How was your experience?")
                        .font(.system(size: 12))
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: { rating = star }) {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundStyle(star <= rating ? .yellow : .gray)
                                    .font(.system(size: 20))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Feedback text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Additional feedback:")
                        .font(.system(size: 11))
                    TextEditor(text: $feedback)
                        .font(.system(size: 11))
                        .frame(height: 80)
                        .scrollContentBackground(.visible)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                }

                // Submit
                Button("Submit") {
                    // Submit feedback
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(rating == 0)
            }
            .padding()

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 380)
    }
}
