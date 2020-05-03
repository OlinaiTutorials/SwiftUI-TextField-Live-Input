import SwiftUI

public struct SearchView: View {
    @ObservedObject private var model = SearchModel()
    @State private var searchText = LiveValue("")
    @State private var showSuggestions = false
    
    public init() {}
    
    public var body: some View {
        VStack {
            // a crude version of Google's logo
            HStack {
                Text("G").foregroundColor(.blue).font(.largeTitle)
                Text("o").foregroundColor(.red).font(.largeTitle)
                Text("g").foregroundColor(.blue).font(.largeTitle)
                Text("g").foregroundColor(.yellow).font(.largeTitle)
                Text("l").foregroundColor(.green).font(.largeTitle)
                Text("e").foregroundColor(.pink).font(.largeTitle)
                Text("s").foregroundColor(.purple).font(.largeTitle)
            }
            
            TextField("Search Google", text: $searchText.rawValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if model.isDownloading {
                LoadingView(true)
            }
            
            if showSuggestions {
                List(model.suggestions) { suggestion in
                    Button(action: { self.openResults(suggestion) }) {
                        Text(suggestion)
                    }
                    .onHover(perform: self.setCursor)
                    .buttonStyle(LinkButtonStyle())
                    .foregroundColor(.primary)
                }
                .listStyle(PlainListStyle())
                .frame(minWidth: 400, maxHeight: 250)
            }
            
            Text("Search suggestions provided by Google")
                .foregroundColor(.gray)
                .font(.caption)
                .padding()
        }
        .onAppear(perform: viewDidAppear)
        .frame(width: 420, height: 420)
        .padding(32)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func viewDidAppear() {
        // perform a search when a new value is published
        _ = searchText.valueChangedPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: search)
    }
    
    private func openResults(_ q: String) {
        guard let url = model.resultPageURL(q) else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }
    
    private func setCursor(_ hovering: Bool) {
        let cursor: NSCursor = hovering ? .pointingHand : .arrow
        cursor.set()
    }
    
    private func search(_ searchText: String) {
        model.search(searchText)

        withAnimation(.easeInOut) {
            showSuggestions = !searchText.isEmpty
        }
    }
}
