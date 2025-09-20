import SwiftUI

struct SayingsView: View {
    var body: some View {
        List {
            Section("Popular") {
                Text("On Knowledge and Action")
                Text("On Patience and Gratitude")
            }
            Section("All Sayings") {
                ForEach(1..<51) { i in
                    Text("Saying \(i)")
                }
            }
        }
        .navigationTitle("Sayings")
    }
}

#Preview {
    NavigationStack { SayingsView() }
}
