import UIKit

// MARK: - Track Cell Delegate Protocol

protocol TableCellDelegate {
    func pauseTapped(_ cell: TableCell)
    func cancelTapped(_ cell: TableCell)
    func downloadTapped(_ cell: TableCell)
    func resumeTapped(_ cell: TableCell)
}

// MARK: - TableCell

class TableCell: UITableViewCell {
    
    // MARK: - Internal properties
    
    static let identifier = "TableCell"
    
    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pause", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(self.pauseOrResumeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(self.cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(self.downloadTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .default
        view.contentMode = .scaleToFill
        view.isUserInteractionEnabled = true
        view.progressTintColor = .red
        return view
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.isEnabled = true
        label.baselineAdjustment = .alignBaselines
        label.lineBreakMode = .byTruncatingTail
        label.shadowOffset = CGSize(width: 0, height: -1)
        label.contentMode = .left
        return label
    }()
    
    var delegate: TableCellDelegate?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal logic
    
    func configure(track: MusicTrack, downloaded: Bool, download: Download?) {
        self.titleLabel.text = track.name
        self.artistLabel.text = track.artist
        
        var showDownloadControls = false
        
        if let download = download {
            showDownloadControls = true
            let title = download.isDownloading ? "Pause" : "Resume"
            self.pauseButton.setTitle(title, for: .normal)
            self.progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
        }
        
        self.pauseButton.isHidden = !showDownloadControls
        self.cancelButton.isHidden = !showDownloadControls
        self.progressView.isHidden = !showDownloadControls
        self.progressLabel.isHidden = !showDownloadControls
        
        // If the track is already downloaded, enable cell selection and hide the Download button.
        self.selectionStyle = downloaded ? .gray : .none
        self.downloadButton.isHidden = downloaded || showDownloadControls
    }
    
    func updateDisplay(progress: Float, totalSize: String) {
        self.progressView.progress = progress
        self.progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
    // MARK: - Private logic
    
    private func setupUI() {
        self.contentView.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        
        [self.titleLabel, self.artistLabel, self.downloadButton, self.pauseButton, self.cancelButton, self.progressView, self.progressLabel].forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 20),
            self.titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 6),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 300),
            
            self.artistLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.artistLabel.heightAnchor.constraint(equalToConstant: 20),
            self.artistLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 6),
            self.artistLabel.widthAnchor.constraint(equalToConstant: 300),
            
            self.downloadButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.downloadButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10),
            
            self.cancelButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.cancelButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10),
            self.cancelButton.widthAnchor.constraint(equalToConstant: 55),
            
            self.pauseButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.pauseButton.rightAnchor.constraint(equalTo: self.cancelButton.leftAnchor, constant: -5),
            self.pauseButton.widthAnchor.constraint(equalToConstant: 57),
            
            self.progressView.topAnchor.constraint(equalTo: self.artistLabel.bottomAnchor, constant: 6),
            self.progressView.heightAnchor.constraint(equalToConstant: 3),
            self.progressView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 6),
            self.progressView.rightAnchor.constraint(equalTo: self.pauseButton.leftAnchor),
            
            self.progressLabel.centerYAnchor.constraint(equalTo: self.progressView.centerYAnchor),
            self.progressLabel.leftAnchor.constraint(equalTo: self.progressView.rightAnchor, constant: 6),
            self.progressLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -6)
        ])
    }
    
    @objc private func pauseOrResumeTapped(_ sender: AnyObject) {
        if(self.pauseButton.titleLabel?.text == "Pause") {
            self.delegate?.pauseTapped(self)
        } else {
            self.delegate?.resumeTapped(self)
        }
    }
    
    @objc private func cancelTapped(_ sender: AnyObject) {
        self.delegate?.cancelTapped(self)
    }
    
    @objc private func downloadTapped(_ sender: AnyObject) {
        self.delegate?.downloadTapped(self)
    }
    
}
