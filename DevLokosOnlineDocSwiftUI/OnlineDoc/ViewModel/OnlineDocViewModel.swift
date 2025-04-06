//
//  OnlineDocViewModel.swift
//  DevLokosOnlineDocSwiftUI
//
//  Created by Kevinho Morales on 1/4/25.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth
import Combine

class OnlineDocViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var activeViewers: Int = 0
    @Published var notificationMessage: String? = nil

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var viewerListener: ListenerRegistration?
    private var isTyping = false
    private var userId: String?
    private var lastViewerIDs: Set<String> = []

    init() {
        signIn()
    }

    private func signIn() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self = self, let user = result?.user else { return }
            self.userId = user.uid
            self.startListening()
            self.addViewer()
            self.observeViewers()
        }
    }

    func startListening() {
        listener = db.collection("shared").document("editor")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let data = snapshot?.data(),
                      let text = data["content"] as? String else { return }
                if !(self?.isTyping ?? false) {
                    self?.content = text
                }
            }
    }

    func updateContent(_ newText: String) {
        isTyping = true
        content = newText
        db.collection("shared").document("editor").setData(["content": newText]) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.isTyping = false
            }
        }
    }

    func addViewer() {
        guard let uid = userId else { return }
        let ref = db.collection("viewers").document(uid)
        ref.setData([
            "timestamp": FieldValue.serverTimestamp()
        ])
    }

    func removeViewer() {
        guard let uid = userId else { return }
        db.collection("viewers").document(uid).delete()
    }

    func observeViewers() {
        viewerListener = db.collection("viewers")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                let currentIDs = Set(snapshot?.documents.map { $0.documentID } ?? [])
                self.activeViewers = currentIDs.count

                let added = currentIDs.subtracting(self.lastViewerIDs)
                let removed = self.lastViewerIDs.subtracting(currentIDs)

                if !added.isEmpty {
                    self.showNotification("USUARIO CONECTADO")
                } else if !removed.isEmpty {
                    self.showNotification("USUARIO SALIÓ")
                }

                self.lastViewerIDs = currentIDs
            }
    }

    private func showNotification(_ message: String) {
        DispatchQueue.main.async {
            self.notificationMessage = message
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.notificationMessage = nil
            }
        }
    }
}
