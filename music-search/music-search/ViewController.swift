import UIKit

class ViewController: UIViewController {
    

// MARK: Constants
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = .orange
        searchBar.placeholder = "Song name or artist"
        searchBar.isTranslucent = true
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .lightGray
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.isUserInteractionEnabled = true
        tableView.clipsToBounds = true
        tableView.register(TableCell.self, forCellReuseIdentifier: "TableCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
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
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    
}

