import UIKit

class TableCell: UITableViewCell {
    
    static let identifier = "TableCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .yellow
        label.textColor = .black
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.text = "22"
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .yellow
        label.textColor = .gray
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.text = "Taylor Swift"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        self.contentView.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        
        [self.titleLabel, self.artistLabel].forEach {
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.titleLabel.heightAnchor.constraint(equalToConstant: 20),
            self.titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        NSLayoutConstraint.activate([
            self.artistLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.artistLabel.heightAnchor.constraint(equalToConstant: 20),
            self.artistLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.artistLabel.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
}
