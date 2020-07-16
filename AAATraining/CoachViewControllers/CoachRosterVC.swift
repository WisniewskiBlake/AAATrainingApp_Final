//
//  CoachRosterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/13/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CoachRosterVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CoachRosterCellDelegate {
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    // search obj
    var searchBar = UISearchBar()
    
    var skip = 0
    var limit = 10
    
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
//        DispatchQueue.main.async {
//           let lock = DispatchSemaphore(value: 0)
//           // Load any saved meals, otherwise load sample data.
//           self.loadUsers(offset: self.skip, limit: self.limit, completion: {
//               lock.signal()
//           })
//           lock.wait()
//           // finished fetching data
//           self.tableView.reloadData()
//        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUsers), name: NSNotification.Name(rawValue: "register"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUsers), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(loadNewUsers), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        
        //self.tableView.reloadData()
        // Do any additional setup after loading the view.
        createSearchBar()
        
       
        
        loadUsers(offset: skip, limit: limit)
        //self.tableView.reloadData()
        // add observer of the notifications received/sent to current vc
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        loadUsers(offset: skip, limit: limit)
    }
    
    // exec-d when new post is published
//    @objc func loadNewUsers() {
//
//        // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
//
//        //loadUsers(offset: 0, limit: skip + 1)
//
//        DispatchQueue.global().async {
//            let lock = DispatchSemaphore(value: 0)
//            // Load any saved meals, otherwise load sample data.
//            self.loadUsers(offset: self.skip, limit: self.limit, completion: {
//                lock.signal()
//            })
//            lock.wait()
//            // finished fetching data
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        DispatchQueue.main.async {
//            let lock = DispatchSemaphore(value: 0)
//            // Load any saved meals, otherwise load sample data.
//            self.loadUsers(offset: self.skip, limit: self.limit, completion: {
//                lock.signal()
//            })
//            lock.wait()
//            self.tableView.reloadData()
//        }
        
        //loadUsers(offset: skip, limit: limit)
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
    
    // MARK: - Search Bar
    // once the searchBar is tapped
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // show cancel button
        searchBar.setShowsCancelButton(true, animated: true)
       
    }
    
    
    // cancel button in the searchBar has been clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        // hide cancel button
        searchBar.setShowsCancelButton(false, animated: true)
        
        // hide tableView that presents searched users        
        
        // hide keyboard
        searchBar.resignFirstResponder()
        // remove all searched results
        
        
        tableView.reloadData()
        
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

                   // self.avas.removeAll(keepingCapacity: false)

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
        //sleep(UInt32(1.0))
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
            //completion!()
        }.resume()

    }
    
    
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return users.count
        
        if searching{
            return searchQuery.count
        }else{
            return users.count
        }
        
    }
    
    // heights of the cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
     // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
                   
        // accessing the cell from main.storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachRosterCell", for: indexPath) as! CoachRosterCell
        
        if searching {
            let firstName = filteredArray[indexPath.row]!["firstName"] as! String
            let lastName = filteredArray[indexPath.row]!["lastName"] as! String
            cell.coachFirstNameLabel.text = firstName.capitalized + " " + lastName.capitalized
            
            // avas logic
            let avaString = filteredArray[indexPath.row]!["ava"] as! String
            
            // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
            if (avaString).count > 10 {
                cell.coachAvaImage.image = filteredArray[indexPath.row]!["ava"] as? UIImage
            
            } else {
                cell.coachAvaImage.image = UIImage(named: "user.png")
                
            }
            
            Helper().downloadImage(from: avaString, showIn: cell.coachAvaImage, orShow: "HomeCover.jpg")
            
            if(currentUser?["lastName"] as! String == users[indexPath.row]!["lastName"] as! String) {
                cell.coachDeleteButton.isHidden = true
                cell.coachAvaImage.image = currentUser_ava
            } else {
               cell.coachDeleteButton.isHidden = false
            }
            
            cell.coachDeleteButton.tag = indexPath.row
            cell.coachConfirmButton.tag = indexPath.row
        } else {
            // fullname logic
            let firstName = users[indexPath.row]!["firstName"] as! String
            let lastName = users[indexPath.row]!["lastName"] as! String
            cell.coachFirstNameLabel.text = firstName.capitalized + " " + lastName.capitalized
            
            
            
            if(currentUser?["lastName"] as! String == users[indexPath.row]!["lastName"] as! String) {
                cell.coachDeleteButton.isHidden = true
                cell.coachAvaImage.image = currentUser_ava
            } else {
                // avas logic
                let avaString = users[indexPath.row]!["ava"] as! String
                
                // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
                if (avaString).count > 10 {
                    cell.coachAvaImage.image = users[indexPath.row]!["ava"] as? UIImage
                
                } else {
                    cell.coachAvaImage.image = UIImage(named: "user.png")
                    
                }
                
                Helper().downloadImage(from: avaString, showIn: cell.coachAvaImage, orShow: "user.png")
               cell.coachDeleteButton.isHidden = false
            }
            
            cell.coachDeleteButton.tag = indexPath.row
            cell.coachConfirmButton.tag = indexPath.row
            
        }
        
        
        
        
//        print(avaString)
//        print(lastName)
//        print(indexPath.row)
//        var avaURL = URL(string: "http://")
//
//        if avaString.isEmpty == false {
//            avaURL = URL(string: avaString)
//            cell.coachAvaImage.image = users[indexPath.row]!["ava"] as? UIImage
//        }
        
     //    if there are still avas to be loaded
//        if users.count != avas.count {
//
//            URLSession(configuration: .default).dataTask(with: avaURL!) { (data, response, error) in
//
//                // failed downloading - assign placeholder
//                if error != nil {
//                    if let image = UIImage(named: "user.png") {
//
//                        self.avas.append(image)
//
//                        DispatchQueue.main.async {
//                            cell.coachAvaImage.image = image
//                        }
//                    }
//                }
//
//                // downloaded
//                if let image = UIImage(data: data!) {
//
//                    self.avas.append(image)
//
//                    DispatchQueue.main.async {
//                        cell.coachAvaImage.image = image
//                    }
//                }
//            }.resume()
//
//        // cached ava
//        } else {
//
//            DispatchQueue.main.async {
//                cell.coachAvaImage.image = self.avas[indexPath.row]
//            }
//        }
        
        // picture logic
        //pictures.append(UIImage())
        
        // get the index of the cell in order to get the certain post's id
        
        
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
//            DispatchQueue.main.async {
//                let lock = DispatchSemaphore(value: 0)
//                // Load any saved meals, otherwise load sample data.
//                self.loadMore(offset: self.skip, limit: self.limit, completion: {
//                    lock.signal()
//                })
//                lock.wait()
//                // finished fetching data
//            }
        }
    }
    
    // MARK: - Delete functions
    func deleteUserPermanent(from cell: UITableViewCell) {
            // getting indexPath of the cell
    //        guard let indexPath = tableView.indexPath(for: cell) else {
    //            return
    //        }
    //        guard let user_id = users[indexPath.row]!["id"] else {
    //                   return
    //        }
            let indexPathRow = cell.tag
            self.deleteUser(_: indexPathRow)
        }
        
        @IBAction func coachConfirmButton_clicked(_ confirmButton: UIButton) {
            let indexPathRow = confirmButton.tag
            deleteUser(_: indexPathRow)
        }
        
        //DELETING FROM UI BUT NOT FROM DATABASE
        // sends request to the server to delete the post
        public func deleteUser(_ row: Int) {
            
            // accessing id of the post which is stored in the tapped cell
            guard let id = users[row]?["id"] as? Int else {
                return
            }
            
            // prepare request
            let url = URL(string: "http://localhost/fb/deleteUser.php")!
            let body = "id=\(id)"
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = body.data(using: .utf8)
            
            // clean up of the data stored in the background of our logic in order to keep everything synchronized
            users.remove(at: row)
            //avas.remove(at: row)
            //pictures.remove(at: row)
            
            // remove the cell itself from the tableView
            let indexPath = IndexPath(row: row, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            tableView.reloadData()
            
            // execute request
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    
                    // error occured
                    if error != nil {
                        Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    // receive data from the server
                    do {
                        // safe mode of casting data
                        guard let data = data else {
                            Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                            return
                        }
                        
                        // accessing json via data received
                        let _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                        
                    // json error
                    } catch {
                        Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                        return
                    }
                    
                }
            }.resume()
            
        }

}
