import Foundation

class DownloadService {

  // MARK: - Properties

    var activeDownloads: [URL: Download] = [:]
    var downloadsSession: URLSession?
  
  // MARK: - Internal logic
    
    func startDownload(_ track: MusicTrack) {
        guard let downloadsSession = self.downloadsSession else { return }
        
        let download = Download(track: track)
        download.task = downloadsSession.downloadTask(with: track.previewURL)
        download.task?.resume()
        download.isDownloading = true
        self.activeDownloads[download.track.previewURL] = download
    }

    func cancelDownload(_ track: MusicTrack) {
        guard let download = self.activeDownloads[track.previewURL] else { return }
        download.task?.cancel()
        self.activeDownloads[track.previewURL] = nil
    }
  
    func pauseDownload(_ track: MusicTrack) {
        guard let download = self.activeDownloads[track.previewURL],
              download.isDownloading else {
            return
        }
        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        download.isDownloading = false
    }
  
    func resumeDownload(_ track: MusicTrack) {
        guard let downloadsSession = self.downloadsSession,
              let download = self.activeDownloads[track.previewURL]
        else { return }
        
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.track.previewURL)
        }
        
        download.task?.resume()
        download.isDownloading = true
    }

}
