import Foundation

class QueryService {

  // MARK: - Constants

  // TODO 1
  

  // MARK: - Properties

  // TODO 2
  var errorMessage = ""
  var tracks: [MusicTrack] = []
  

  // MARK: - Type Alias

  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([MusicTrack]?, String) -> Void
  

  // MARK: - Internal Methods

  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    // TODO 3
    DispatchQueue.main.async {
      completion(self.tracks, self.errorMessage)
    }
  }
  

  // MARK: - Private Methods

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

