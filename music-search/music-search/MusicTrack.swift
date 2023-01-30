import Foundation

final class MusicTrack {

    // MARK: - Properties
    
    let name: String
    let artist: String
    let previewURL: URL
    let index: Int
    var downloaded = false

    // MARK: - Init

    init(name: String,
         artist: String,
         previewURL: URL,
         index: Int) {
        self.name = name
        self.artist = artist
        self.previewURL = previewURL
        self.index = index
    }
}

