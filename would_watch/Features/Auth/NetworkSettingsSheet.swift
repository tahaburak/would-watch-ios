//
//  NetworkSettingsSheet.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct NetworkSettingsSheet: View {
    @Binding var isPresented: Bool
    @State private var customURL: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    Text("Current URL:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(AppConfig.backendBaseURL)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                    
                    TextField("Enter Custom URL (e.g. http://192.168.1.5:8080/api)", text: $customURL)
                        #if os(iOS)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        #endif
                }
                
                Section(footer: Text("Default: https://would.watch/api\nFor local development, use http://127.0.0.1:8080/api (Simulator) or your Mac's LAN IP (physical device).")) {
                    Button("Reset to Default") {
                        AppConfig.customBaseURL = nil
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Network Settings")
            .navigationTitle("Network Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !customURL.isEmpty {
                            // Ensure it ends with /api if not present? Or let user decide.
                            // Ideally validate URL
                            var url = customURL
                            if url.hasSuffix("/") {
                                url.removeLast()
                            }
                            AppConfig.customBaseURL = url
                        }
                        isPresented = false
                    }
                    .disabled(customURL.isEmpty)
                }
            }
            .onAppear {
                customURL = AppConfig.customBaseURL ?? ""
            }
        }
    }
}
