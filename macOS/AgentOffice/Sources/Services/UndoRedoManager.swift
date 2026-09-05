// UndoRedoManager.swift
import Foundation
import Combine

class UndoRedoManager: ObservableObject {
    static let shared = UndoRedoManager()

    @Published var canUndo = false
    @Published var canRedo = false

    private var undoStack: [DeskAction] = []
    private var redoStack: [DeskAction] = []

    struct DeskAction {
        let type: ActionType
        let deskIndex: Int
        let agentBefore: Agent?
        let agentAfter: Agent?
        let timestamp: Date

        enum ActionType {
            case assign
            case remove
            case swap
        }
    }

    private init() {}

    func record(_ action: DeskAction) {
        undoStack.append(action)
        redoStack.removeAll()
        updateState()
    }

    func undo() -> DeskAction? {
        guard let action = undoStack.popLast() else { return nil }
        redoStack.append(action)
        updateState()
        return action
    }

    func redo() -> DeskAction? {
        guard let action = redoStack.popLast() else { return nil }
        undoStack.append(action)
        updateState()
        return action
    }

    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateState()
    }

    private func updateState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
}
