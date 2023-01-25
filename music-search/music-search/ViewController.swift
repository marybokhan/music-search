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
        cell.configure(track: track, downloaded: track.downloaded)
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
        print("Finished downloading to \(location)")
    }
}

