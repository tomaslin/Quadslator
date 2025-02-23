import SwiftUI
import CoreData

struct TranslatorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sourceText = ""
    @State private var translateAs = ""
    @State private var translatedText: String?
    @State private var isTranslating = false
    @FocusState private var isSourceTextFocused: Bool // Focus state for the TextEditor
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TranslationPreference.timestamp, ascending: true)],
        animation: .default)
    private var preferences: FetchedResults<TranslationPreference>
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Translate:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ZStack {
                    TextEditor(text: $sourceText)
                        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.pink, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .focused($isSourceTextFocused) // Bind focus state to TextEditor
                    
                    if !sourceText.isEmpty {
                        HStack {
                            Spacer()
                            Button(action: {
                                sourceText = ""
                                translatedText = nil
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.pink)
                                    .padding(8)
                            }
                        }
                        .padding(.trailing, 8)
                    }
                }
                
                HStack(spacing: 4) {
                    Text("as")
                        .foregroundColor(.white)
                    TextField("", text: $translateAs)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: translateAs) { newValue in
                            saveTranslationPreference()
                        }
                        .colorScheme(.dark)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button(action: translate) {
                Text("Translate")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(sourceText.isEmpty || translateAs.isEmpty || isTranslating)
            
            if isTranslating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            if let translatedText = translatedText {
                ScrollView { // Wrap in ScrollView
                    Text(translatedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                }
                .frame(maxHeight: 200) // Limit the height of the ScrollView
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
        .onAppear {
            if let lastPreference = preferences.first {
                translateAs = lastPreference.translateAs ?? ""
            }
            isSourceTextFocused = true // Set focus on sourceText on appear
        }
    }
    
    private func saveTranslationPreference() {
        let preference = preferences.first ?? TranslationPreference(context: viewContext)
        preference.translateAs = translateAs
        preference.timestamp = Date()
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving translation preference: \(error)")
        }
    }
    
    private func translate() {
        guard !sourceText.isEmpty && !translateAs.isEmpty else { return }
        
        isTranslating = true
        let chatService = ChatService()
        
        Task {
            do {
                let translationResult = try await chatService.translate(text: sourceText, to: translateAs)
                
                DispatchQueue.main.async {
                    self.translatedText = translationResult
                    self.isTranslating = false
                    
                    // Save translation
                    let translation = TranslationText(context: viewContext)
                    translation.sourceText = sourceText
                    translation.translatedText = translationResult
                    translation.timestamp = Date()
                    
                    do {
                        try viewContext.save()
                    } catch {
                        print("Error saving translation: \(error)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.translatedText = "Translation failed: \(error.localizedDescription)"
                    self.isTranslating = false
                }
            }
        }
    }
}

#Preview {
    TranslatorView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
