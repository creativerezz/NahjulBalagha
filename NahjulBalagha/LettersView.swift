import SwiftUI

struct LettersView: View {
    var body: some View {
        List {
            Section("Collections") {
                Text("Letters to Governors")
                Text("Private Correspondence")
            }
            Section("All Letters") {
                ForEach(1..<31) { i in
                    Text("Letter \(i)")
                }
            }
        }
        .navigationTitle("Letters")
    }
}

#Preview {
    NavigationStack { LettersView() }
}
