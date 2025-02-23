import SwiftUI
import CoreData

struct TranslatorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sourceText = ""
    @State private var translateAs = ""
    @State private var translatedText: String?
    @State private var isTranslating = false
    
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
                        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200) // Increased height
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
                Text(translatedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
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
        // TODO: Implement OpenAI translation
        // For now, just simulate translation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            translatedText = "[Translation will be implemented with OpenAI]: \(sourceText)"
            isTranslating = false
            
            // Save translation
            let translation = TranslationText(context: viewContext)
            translation.sourceText = sourceText
            translation.translatedText = translatedText
            translation.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving translation: \(error)")
            }
        }
    }
}

#Preview {
    TranslatorView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
