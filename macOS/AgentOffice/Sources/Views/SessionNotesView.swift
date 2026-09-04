// SessionNotesView.swift
import SwiftUI

struct SessionNotesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var newNote = ""
    @State private var filterTag = ""

    var filtered: [SessionNote] {
        if filterTag.isEmpty { return store.sessionNotes }
        return store.sessionNotes.filter { $0.tags.contains(filterTag) }
    }

    var allTags: [String] {
        Array(Set(store.sessionNotes.flatMap { $0.tags })).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Notes").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Add note
            HStack(spacing: 8) {
                TextField("Add a note...", text: $newNote)
                    .textFieldStyle(.plain)
                Button("Add") {
                    guard !newNote.isEmpty else { return }
                    store.addNote(newNote)
                    newNote = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(newNote.isEmpty)
            }
            .padding(10)

            // Tag filter
            if !allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        FilterPill(title: "All", isSelected: filterTag.isEmpty) { filterTag = "" }
                        ForEach(allTags, id: \.self) { tag in
                            FilterPill(title: tag, isSelected: filterTag == tag) { filterTag = tag }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.bottom, 6)
            }

            Divider()

            // Notes list
            List {
                ForEach(filtered.reversed()) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.text).font(.system(size: 13))
                        HStack {
                            Text(note.timestamp, style: .relative).font(.caption).foregroundStyle(.secondary)
                            if !note.tags.isEmpty {
                                Text(note.tags.joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.blue)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteNote(note) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .frame(width: 450, height: 450)
    }
}
