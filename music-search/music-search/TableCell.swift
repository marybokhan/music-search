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
    
// MARK: - Private properties
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var pauseButton: UIButton?
    var cancelButton: UIButton?
    
    lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(self.downloadTapped), for: .touchUpInside)
        return button
    }()
    
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    
    var delegate: TableCellDelegate?

// MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - Private logic
    
    private func setupUI() {
        self.contentView.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        
        [self.titleLabel, self.artistLabel, self.downloadButton].forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 20),
            self.titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        NSLayoutConstraint.activate([
            self.artistLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.artistLabel.heightAnchor.constraint(equalToConstant: 20),
            self.artistLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.artistLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        NSLayoutConstraint.activate([
            self.downloadButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.downloadButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10)
        ])
    }
    
    func pauseOrResumeTapped(_ sender: AnyObject) {
      if(pauseButton?.titleLabel?.text == "Pause") {
        delegate?.pauseTapped(self)
      } else {
        delegate?.resumeTapped(self)
      }
    }
    
    func cancelTapped(_ sender: AnyObject) {
      delegate?.cancelTapped(self)
    }
    
    @objc func downloadTapped(_ sender: AnyObject) {
        delegate?.downloadTapped(self)
    }
    
    // TODO 12
    
    func configure(track: MusicTrack, downloaded: Bool) {
        self.titleLabel.text = track.name
        self.artistLabel.text = track.artist
      
      // Show/hide download controls Pause/Resume, Cancel buttons, progress info.
      // TODO 14
      
      // Non-nil Download object means a download is in progress.
      // TODO 15
      
      // If the track is already downloaded, enable cell selection and hide the Download button.
      selectionStyle = downloaded ? UITableViewCell.SelectionStyle.gray : UITableViewCell.SelectionStyle.none
      downloadButton.isHidden = downloaded
    }
    
    // TODO 16

}
