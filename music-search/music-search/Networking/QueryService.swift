import Foundation

class QueryService {
    
// MARK: - Private Properties

    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    private var errorMessage = ""
    private var tracks: [MusicTrack] = []
  
// MARK: - Type Alias

    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([MusicTrack]?, String) -> Void
  
// MARK: - Internal logic

    func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
        self.dataTask?.cancel()
      
        guard var urlComponents = URLComponents(string: "https://itunes.apple.com/search") else { return }
        
        urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
      
        guard let url = urlComponents.url else { return }
      
        self.dataTask = self.defaultSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { self.dataTask = nil }
          
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self.updateSearchResults(data)
              
                DispatchQueue.main.async {
                    completion(self.tracks, self.errorMessage)
                }
            }
        }
        self.dataTask?.resume()
    }
  
// MARK: - Private logic

    private func updateSearchResults(_ data: Data) {
        self.tracks.removeAll()

        do {
            let decodedResponce = try JSONDecoder().decode(MusicTracksResponse.self, from: data)
            self.tracks = decodedResponce.getMusicTracks()
        } catch {
            self.errorMessage += "\(error)\n"
            return
        }
    }
}
