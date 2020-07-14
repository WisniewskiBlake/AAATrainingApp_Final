//
//  CoachRosterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/13/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CoachRosterVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
       
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    // search obj
    var searchBar = UISearchBar()
    var searchedUsers = [NSDictionary]()
    var searchedUsers_avas = [UIImage]()
    
    // int
    var searchLimit = 15
    var searchSkip = 0
    var skip = 0
    var limit = 10
    
    var users = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    
    var friendshipStatus = [Int]()
    
    
    // PART 2. Requests
    var requestedUsers = [NSDictionary]()
    var requestedUsers_avas = [UIImage]()
    var requestedUsersLimit = 10
    var requestedUsersSkip = 0
    
    // bool
    var isLoading = false
    var isSearchedUserStatusUpdated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createSearchBar()
        loadUsers(offset: skip, limit: limit)
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
    
    // once the searchBar is tapped
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // show cancel button
        searchBar.setShowsCancelButton(true, animated: true)

        // show tableView that presents searched users
        searchTableView.isHidden = false
    }
    
    
    // cancel button in the searchBar has been clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // hide cancel button
        searchBar.setShowsCancelButton(false, animated: true)
        
        // hide tableView that presents searched users
        searchTableView.isHidden = true
        
        // hide keyboard
        searchBar.resignFirstResponder()
        
        // remove all searched results
        searchBar.text = ""
        searchedUsers.removeAll(keepingCapacity: false)
        searchedUsers_avas.removeAll(keepingCapacity: false)
        friendshipStatus.removeAll(keepingCapacity: false)
        searchTableView.reloadData()
        
    }
    
    // called whenever we typed any letter in the searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       //searchUsers()
    }
    
    // loading posts from the server via@objc  PHP protocol
    func loadUsers(offset: Int, limit: Int) {

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

                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.users = users

                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = users.count


                    // clean up likes for the refetching
                    //self.liked.removeAll(keepingCapacity: false)
                    // clean up likes for the refetching
                    //self.numLiked.removeAll(keepingCapacity: false)


                    // logic of tracking liked posts
//                    for post in posts {
//                        if post["liked"] is NSNull {
//                            self.liked.append(Int())
//                        } else {
//                            self.liked.append(1)
//
//                        }
//                    }


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

    // loading more posts from the server via PHP protocol
    func loadMore(offset: Int, limit: Int) {

        isLoading = true

        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
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
    
    
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    // heights of the cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
     // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
        let pictureURL = users[indexPath.row]!["ava"] as! String
                   
        // accessing the cell from main.storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
        
        
        // fullname logic
        let firstName = posts[indexPath.row]!["firstName"] as! String
        let lastName = posts[indexPath.row]!["lastName"] as! String
        cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
        cell.numberCompleted.text = numOfLikes
        
        // date logic
        let dateString = posts[indexPath.row]!["date_created"] as! String
        
        // taking the date received from the server and putting it in the following format to be recognized as being Date()
        let formatterGet = DateFormatter()
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatterGet.date(from: dateString)!
        
        // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
        cell.dateLabel.text = formatterShow.string(from: date)
        
        
        // text logic
        let text = posts[indexPath.row]!["text"] as! String
        cell.postTextLabel.text = text
        
        
        // avas logic
        let avaString = posts[indexPath.row]!["ava"] as! String
        let avaURL = URL(string: avaString)!
        
        // if there are still avas to be loaded
        if posts.count != avas.count {
            
            URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                
                // failed downloading - assign placeholder
                if error != nil {
                    if let image = UIImage(named: "user.png") {
                        
                        self.avas.append(image)
                        
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                }
                
                // downloaded
                if let image = UIImage(data: data!) {
                    
                    self.avas.append(image)
                    
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }
                }
            }.resume()
            
        // cached ava
        } else {
            
            DispatchQueue.main.async {
                cell.avaImageView.image = self.avas[indexPath.row]
            }
        }
        
        // picture logic
        pictures.append(UIImage())
        
        // get the index of the cell in order to get the certain post's id
        cell.numberCompleted.tag = indexPath.row
        cell.optionsButton.tag = indexPath.row
        
        return cell
    
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
