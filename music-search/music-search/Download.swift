import Foundation

class Download {
    
// MARK: - Properties
    
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    let track: MusicTrack
    
// MARK: - Init
    
    init(track: MusicTrack) {
        self.track = track
    }
    
}
