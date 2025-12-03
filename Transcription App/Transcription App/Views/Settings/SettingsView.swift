import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var audioLanguage = "English"
    @State private var selectedModel = "Tiny"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.warmGray100
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    CustomTopBar(
                        title: "Settings",
                        leftIcon: "caret-left",
                        onLeftTap: { dismiss() }
                    )
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Top Section
                            VStack(spacing: 0) {
                                // Audio Language
                                NavigationLink(destination: AudioLanguageView(selectedLanguage: $audioLanguage)) {
                                    HStack(spacing: 16) {
                                        Image("text-aa")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.baseBlack)
                                        
                                        Text("Audio language")
                                            .font(.system(size: 17))
                                            .foregroundColor(.baseBlack)
                                        
                                        Spacer()
                                        
                                        Text(audioLanguage)
                                            .font(.system(size: 17))
                                            .foregroundColor(.warmGray500)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.warmGray400)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                // Model
                                NavigationLink(destination: ModelSelectionView(selectedModel: $selectedModel)) {
                                    HStack(spacing: 16) {
                                        Image("sparkle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.baseBlack)
                                        
                                        Text("Model")
                                            .font(.system(size: 17))
                                            .foregroundColor(.baseBlack)
                                        
                                        Spacer()
                                        
                                        Text(selectedModel)
                                            .font(.system(size: 17))
                                            .foregroundColor(.warmGray500)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.warmGray400)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            
                            // Bottom Section
                            VStack(spacing: 0) {
                                // Feedback and Support
                                NavigationLink(destination: FeedbackSupportView()) {
                                    HStack(spacing: 16) {
                                        Image("seal-question")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.baseBlack)
                                        
                                        Text("Feedback and support")
                                            .font(.system(size: 17))
                                            .foregroundColor(.baseBlack)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.warmGray400)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                // Rate App
                                Button(action: rateApp) {
                                    HStack(spacing: 16) {
                                        Image("star")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.baseBlack)
                                        
                                        Text("Rate app")
                                            .font(.system(size: 17))
                                            .foregroundColor(.baseBlack)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.warmGray400)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                // Share App
                                Button(action: shareApp) {
                                    HStack(spacing: 16) {
                                        Image("export")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.baseBlack)
                                        
                                        Text("Share app")
                                            .font(.system(size: 17))
                                            .foregroundColor(.baseBlack)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.warmGray400)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: 8) {
                        Image("diamond")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.accent)
                        
                        Text("SONO")
                            .font(.custom("LibreBaskerville-Regular", size: 20))
                            .foregroundColor(.baseBlack)
                        
                        Text("Made with love")
                            .font(.system(size: 16))
                            .foregroundColor(.warmGray600)
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 14))
                            .foregroundColor(.warmGray400)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .presentationDragIndicator(.hidden)
    }
    
    // Rate app function
    func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    // Share app function
    func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!
        let activityViewController = UIActivityViewController(
            activityItems: ["Check out this app!", appURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}

// MARK: - Audio Language Selection View
struct AudioLanguageView: View {
    @Binding var selectedLanguage: String
    @Environment(\.dismiss) var dismiss
    
    let languages = ["English", "Spanish", "French", "German", "Italian", "Portuguese", "Chinese", "Japanese", "Korean"]
    
    var body: some View {
        ZStack {
            Color.warmGray50
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomTopBar(
                    title: "Audio language",
                    leftIcon: "caret-left",
                    onLeftTap: { dismiss() }
                )
                
                List {
                    ForEach(languages, id: \.self) { language in
                        Button(action: {
                            selectedLanguage = language
                            dismiss()
                        }) {
                            HStack {
                                Text(language)
                                    .font(.system(size: 17))
                                    .foregroundColor(.baseBlack)
                                Spacer()
                                if selectedLanguage == language {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.accent)
                                }
                            }
                        }
                        .listRowBackground(Color.white)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Model Selection View
struct ModelSelectionView: View {
    @Binding var selectedModel: String
    @Environment(\.dismiss) var dismiss
    
    let models = ["Tiny", "Base", "Small", "Medium", "Large"]
    
    var body: some View {
        ZStack {
            Color.warmGray50
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomTopBar(
                    title: "Model",
                    leftIcon: "caret-left",
                    onLeftTap: { dismiss() }
                )
                
                List {
                    ForEach(models, id: \.self) { model in
                        Button(action: {
                            selectedModel = model
                            dismiss()
                        }) {
                            HStack {
                                Text(model)
                                    .font(.system(size: 17))
                                    .foregroundColor(.baseBlack)
                                Spacer()
                                if selectedModel == model {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.accent)
                                }
                            }
                        }
                        .listRowBackground(Color.white)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Feedback and Support View
struct FeedbackSupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.warmGray50
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomTopBar(
                    title: "Feedback and support",
                    leftIcon: "caret-left",
                    onLeftTap: { dismiss() }
                )
                
                List {
                    Button("Send Feedback") {
                        sendFeedback()
                    }
                    .listRowBackground(Color.white)
                    
                    Button("Contact Support") {
                        contactSupport()
                    }
                    .listRowBackground(Color.white)
                    
                    Button("Privacy Policy") {
                        openPrivacyPolicy()
                    }
                    .listRowBackground(Color.white)
                    
                    Button("Terms of Service") {
                        openTermsOfService()
                    }
                    .listRowBackground(Color.white)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
    }
    
    func sendFeedback() {
        if let url = URL(string: "mailto:support@yourapp.com?subject=Feedback") {
            UIApplication.shared.open(url)
        }
    }
    
    func contactSupport() {
        if let url = URL(string: "mailto:support@yourapp.com?subject=Support Request") {
            UIApplication.shared.open(url)
        }
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://yourapp.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    func openTermsOfService() {
        if let url = URL(string: "https://yourapp.com/terms") {
            UIApplication.shared.open(url)
        }
    }
}
