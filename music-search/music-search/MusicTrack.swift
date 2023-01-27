import Foundation

class MusicTrack {

  // MARK: - Properties
    
    let name: String
    let artist: String
    let index: Int
    let previewURL: URL
    
    var downloaded = false
  
  // MARK: - Init

  init(name: String, artist: String, previewURL: URL, index: Int) {
      self.name = name
      self.artist = artist
      self.index = index
      self.previewURL = previewURL
  }
    
}

