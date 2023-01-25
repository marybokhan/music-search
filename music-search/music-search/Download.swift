import Foundation

class Download {
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var track: MusicTrack
    
    init(track: MusicTrack) {
        self.track = track
    }
}
