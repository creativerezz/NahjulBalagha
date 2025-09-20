import SwiftUI

struct SermonsView: View {
    var body: some View {
        List {
            Text("Sermons list placeholder")
        }
        .navigationTitle("Sermons")
    }
}

#Preview {
    NavigationStack { SermonsView() }
}
