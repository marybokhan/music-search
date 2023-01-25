import Foundation

class DownloadService {

  // MARK: - Properties

    var activeDownloads: [URL: Download] = [:]
    var downloadsSession: URLSession!
  
  // MARK: - Internal Methods
    
    // TODO 8
    func startDownload(_ track: MusicTrack) {
        let download = Download(track: track)
        download.task = self.downloadsSession.downloadTask(with: track.previewURL)
        download.task?.resume()
        download.isDownloading = true
        self.activeDownloads[download.track.previewURL] = download
        
    }

  // TODO 9
    func cancelDownload(_ track: MusicTrack) {
        
    }
  
  // TODO 10
    func pauseDownload(_ track: MusicTrack) {
        
    }
  
  // TODO 11
    func resumeDownload(_ track: MusicTrack) {
        
    }
  

}
