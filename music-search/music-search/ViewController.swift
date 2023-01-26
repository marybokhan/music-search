import UIKit
import AVKit

class ViewController: UIViewController {
    
// MARK: Properties
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = .orange
        searchBar.placeholder = "Song name or artist"
        searchBar.isTranslucent = true
        searchBar.isUserInteractionEnabled = true
        searchBar.delegate = self
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGray4
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.isUserInteractionEnabled = true
        tableView.clipsToBounds = true
        tableView.register(TableCell.self, forCellReuseIdentifier: "TableCell")
        return tableView
    }()
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let downloadService = DownloadService()
    let queryService = QueryService()
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration,
                          delegate: self,
                          delegateQueue: nil)
    }()
    
    var searchResults: [MusicTrack] = []
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
      var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
      return recognizer
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.tableView.tableFooterView = UIView()
        self.downloadService.downloadsSession = self.downloadsSession
        
    }

// MARK: Private logic
    private func setupUI() {
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
        
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.searchBar.heightAnchor.constraint(equalToConstant: 60),
            self.searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.searchBar.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    func localFilePath(for url: URL) -> URL {
        return self.documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    func playDownload(_ track: MusicTrack) {
        let playerViewController = AVPlayerViewController()
        self.present(playerViewController, animated: true, completion: nil)
        let url = self.localFilePath(for: track.previewURL)
        let player = AVPlayer(url: url)
        playerViewController.player = player
        player.play()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
      return .topAttached
    }
    
    func reload(_ row: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TableCell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifier,
                                                            for: indexPath) as! TableCell
        cell.delegate = self
        
        let track = self.searchResults[indexPath.row]
        // TODO 13
        cell.configure(track: track, downloaded: track.downloaded, download: self.downloadService.activeDownloads[track.previewURL])
        return cell
    }
    
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = self.searchResults[indexPath.row]
        if track.downloaded {
            self.playDownload(track)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 62.0
    }
    
}


extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismissKeyboard()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
            }
      
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        self.queryService.getSearchResults(searchTerm: searchText) { [weak self] results, errorMessage in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if let results = results {
          self?.searchResults = results
          self?.tableView.reloadData()
          self?.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
        
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addGestureRecognizer(self.tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.removeGestureRecognizer(self.tapRecognizer)
    }
    
}


extension ViewController: TableCellDelegate {
    
    func cancelTapped(_ cell: TableCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            let track = self.searchResults[indexPath.row]
            self.downloadService.cancelDownload(track)
            self.reload(indexPath.row)
        }
    }
    
    func downloadTapped(_ cell: TableCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            let track = self.searchResults[indexPath.row]
            self.downloadService.startDownload(track)
            self.reload(indexPath.row)
        }
    }
    
    func pauseTapped(_ cell: TableCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            let track = self.searchResults[indexPath.row]
            self.downloadService.pauseDownload(track)
            self.reload(indexPath.row)
        }
    }
    
    func resumeTapped(_ cell: TableCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            let track = self.searchResults[indexPath.row]
            self.downloadService.resumeDownload(track)
            self.reload(indexPath.row)
        }
    }
    
}

// TODO 19

extension ViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else {
            return
        }
        
        let download = self.downloadService.activeDownloads[sourceURL]
        self.downloadService.activeDownloads[sourceURL] = nil
        
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.track.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        if let index = download?.track.index {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
              let download = self.downloadService.activeDownloads[url]
        else {
            return
        }
        
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        
        DispatchQueue.main.async {
            if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.track.index, section: 0)) as? TableCell {
                trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
            }
        }
    }
}

