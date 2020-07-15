//
//  PlayerRosterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/13/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class PlayerRosterVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // search obj
    var searchBar = UISearchBar()
    
    var skip = 0
    var limit = 15
    
    var filteredArray = [NSDictionary?]()
    var lastNames : [String] = []
    var searchQuery = [String]()
    var searching = false
    
    var users = [NSDictionary?]()
    var avas = [UIImage]()
    //var pictures = [UIImage]()
    
    // bool
    var isLoading = false
    var isSearchedUserStatusUpdated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUsers), name: NSNotification.Name(rawValue: "register"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUsers), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(loadNewUsers), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
        createSearchBar()
        loadUsers(offset: skip, limit: limit)
        
        // add observer of the notifications received/sent to current vc
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
    }
    
    // creates search bar programmatically
    func createSearchBar() {
        // creating search bar and configuring it
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        
        // accessing childView - textField inside of the searchBar
        let searchBar_textField = searchBar.value(forKey: "searchField") as? UITextField
        searchBar_textField?.textColor = .white
        searchBar_textField?.tintColor = .white
        
        // insert searchBar into navigationBar
        self.navigationItem.titleView = searchBar
        
    }
    
    
    

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       <#code#>
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       <#code#>
   }

}
