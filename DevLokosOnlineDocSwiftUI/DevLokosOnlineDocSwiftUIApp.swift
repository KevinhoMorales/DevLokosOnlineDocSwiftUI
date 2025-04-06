//
//  DevLokosOnlineDocSwiftUIApp.swift
//  DevLokosOnlineDocSwiftUI
//
//  Created by Kevinho Morales on 1/4/25.
//

import SwiftUI
import Firebase

@main
struct DevLokosOnlineDocSwiftUIApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            OnlineDocView()
        }
    }
}
