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
      
        if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
            urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
          
            guard let url = urlComponents.url else {
                return
            }
          
            self.dataTask = self.defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
              
                if let error = error {
                    self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self?.updateSearchResults(data)
                  
                    DispatchQueue.main.async {
                        completion(self?.tracks, self?.errorMessage ?? "")
                    }
                }
            }
            self.dataTask?.resume()
      
        }
      
    }
  
// MARK: - Private logic

    private func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        self.tracks.removeAll()
    
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            self.errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
    
        guard let array = response!["results"] as? [Any] else {
            self.errorMessage += "Dictionary does not contain results key\n"
            return
        }
    
        var index = 0
    
        for trackDictionary in array {
            if let trackDictionary = trackDictionary as? JSONDictionary,
               let previewURLString = trackDictionary["previewUrl"] as? String,
               let previewURL = URL(string: previewURLString),
               let name = trackDictionary["trackName"] as? String,
               let artist = trackDictionary["artistName"] as? String {
                self.tracks.append(MusicTrack(name: name, artist: artist, previewURL: previewURL, index: index))
                index += 1
            } else {
                self.errorMessage += "Problem parsing trackDictionary\n"
            }
        }
        
    }
    
}
