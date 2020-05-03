import Foundation
import Combine

extension String: Identifiable {
    public var id: String { return self }
}

public class SearchModel: ObservableObject {
    @Published public var suggestions = [String]()
    @Published public var isDownloading = false
    
    public init() {}
    
    private var cancellable: AnyCancellable?
        { didSet { oldValue?.cancel() } }
    
    /// Get Google Search suggestions
    /// - Parameters:
    ///   - query: query string
    ///   - region: general search location (region code reference: https://redirect.is/1vnucvt)
    public func search(_ query: String, region: String?=nil) {
        suggestions.removeAll()
        guard !query.isEmpty else { isDownloading = false; return }
        
        var components = URLComponents(string: "https://suggestqueries.google.com/complete/search")

        // form the URL request
        components?.queryItems = [
            .init(name: "client", value: "Firefox"),
            .init(name: "q", value: query)
        ]
        
        // if a region code is provided, add it to the URL
        if let region = region {
            components?.queryItems?.append(
                .init(name: "gl", value: region)
            )
        }
        
        guard let url = components?.url else { return }
        let request = URLRequest(url: url)
        
        isDownloading = true
        
        // set up the processing chain
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .compactMap { $0.data }
            .map { SearchModel.decodeSuggestions($0) }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .sink {
                self.isDownloading = false
                self.suggestions = $0
            }
    }
    
    public func resultPageURL(_ query: String) -> URL? {
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [ .init(name: "q", value: query) ]
        
        return components?.url
    }
    
    static private func decodeSuggestions(_ data: Data?) -> [String] {
        // response example:
        // ['query', ['suggestion1', 'suggestion2', 'suggestion3', ...]]
        guard let data = data,
            let root = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let items = (root as? [Any])?.last as? [String]
            else { return [] }
        
        return items
    }
}
