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
    
    // MARK: - Search Bar
    // once the searchBar is tapped
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // show cancel button
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    // cancel button in the searchBar has been clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // hide cancel button
        searchBar.setShowsCancelButton(false, animated: true)
        // hide tableView that presents searched users
        
        // hide keyboard
        searchBar.resignFirstResponder()
        // remove all searched results
        searchBar.text = ""
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
    
    // called whenever we typed any letter in the searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = lastNames.filter({$0.prefix(searchText.count).lowercased() == searchText.lowercased()})
        
        if(filteredArray.count >= 1){
            for i in 0 ..< filteredArray.count{
                filteredArray.remove(at: 0)
            }
        }
        for i in 0 ..< searchQuery.count{
            for j in 0 ..< users.count{
                if(users[j]!["lastName"] as! String == searchQuery[i]){
                    filteredArray.append(users[j])
                }
            }
        }
        searching = true
        self.tableView.reloadData()
    }
    
    // MARK: - loadUsers
    // loading posts from the server via@objc  PHP protocol
    @objc func loadUsers(offset: Int, limit: Int) {

        isLoading = true

        // prepare request
        let url = URL(string: "http://localhost/fb/selectUsers.php")!
        let body = "offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                do {
                    // access data - safe mode
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        self.isLoading = false
                        return
                    }
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary

                    // accessing json data - safe mode
                    guard let users = json?["users"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    // assigning all successfully loaded users to our Class Var - posts (after it got loaded successfully)
                    self.users = users
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = users.count
                    
                    for user in users {
                        self.lastNames.append(user["lastName"] as! String)
                    }

                    self.avas.removeAll(keepingCapacity: false)

                    // reloading tableView to have an affect - show posts
                    self.tableView.reloadData()

                    self.isLoading = false

                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }

            }
        }.resume()

    }
    
    // MARK: - loadMore
    // loading more posts from the server via PHP protocol
    func loadMore(offset: Int, limit: Int) {
        isLoading = true

        // prepare request
        let url = URL(string: "http://localhost/fb/selectUsers.php")!
        let body = "offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // error occured
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                do {
                    // access data - safe mode
                    guard let data = data else {
                        self.isLoading = false
                        return
                    }
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary

                    // accessing json data - safe mode
                    guard let users = json?["users"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.users.append(contentsOf: users)

                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip += users.count
                    // reloading tableView to have an affect - show posts
                    self.tableView.beginUpdates()

                    for i in 0 ..< users.count {
                        let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: .fade)
                    }

                    self.tableView.endUpdates()
                    self.isLoading = false

                } catch {
                    self.isLoading = false
                    return
                }

            }
        }.resume()

    }
    
    
    

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
   }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searching{
            return searchQuery.count
        }else{
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // accessing the cell from main.storyboard
       let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerRosterCell", for: indexPath) as! PlayerRosterCell
       
       if searching {
           let firstName = filteredArray[indexPath.row]!["firstName"] as! String
           let lastName = filteredArray[indexPath.row]!["lastName"] as! String
           cell.fullNameLabel.text = firstName.capitalized + " " + lastName.capitalized
           
           // avas logic
           let avaString = filteredArray[indexPath.row]!["ava"] as! String
           
           // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
           if (avaString).count > 10 {
               cell.avaImageView.image = filteredArray[indexPath.row]!["ava"] as? UIImage
           
           } else {
               cell.avaImageView.image = UIImage(named: "user.png")
               
           }
           
           Helper().downloadImage(from: avaString, showIn: cell.avaImageView, orShow: "user.png")
                    
                      
       } else {
           // fullname logic
           let firstName = users[indexPath.row]!["firstName"] as! String
           let lastName = users[indexPath.row]!["lastName"] as! String
           cell.fullNameLabel.text = firstName.capitalized + " " + lastName.capitalized
           
           // avas logic
           let avaString = users[indexPath.row]!["ava"] as! String
           
           // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
           if (avaString).count > 10 {
               cell.avaImageView.image = users[indexPath.row]!["ava"] as? UIImage
           
           } else {
               cell.avaImageView.image = UIImage(named: "user.png")
               
           }
           
           Helper().downloadImage(from: avaString, showIn: cell.avaImageView, orShow: "user.png")
       
           
       }
       
       print(avas)
       return cell
   }
    
    // MARK: - Update and scrollDidScroll
    // updates any button with following params
    func update(button: UIButton, icon: String, color: UIColor) {
        
        // setting icon / background image
        button.setBackgroundImage(UIImage(named: icon), for: .normal)
        
        // setting color of the button
        button.tintColor = color
        
    }
    
    // executed always whenever tableView is scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
        let b = -tableView.frame.height
        
        if a > b && isLoading == false {
            loadMore(offset: skip, limit: limit)
        }
    }
    
    

}
