//
//  FeedVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/15/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class FeedVC_Coach: UITableViewController {
    
    // posts obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 10
    var isLoading = false
    var liked = [Int]()
    
    // color obj
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        
        // run function
        loadPosts(offset: skip, limit: limit)
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    // exec-d when new post is published
    @objc func loadNewPosts() {
        
        // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
        loadPosts(offset: 0, limit: skip + 1)
    }
    
    // MARK: - Load Posts
    // loading posts from the server via@objc  PHP protocol
    func loadPosts(offset: Int, limit: Int) {
        isLoading = true
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)&action=feed"
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
                    
                    print(json as Any)
                    
                    // accessing json data - safe mode
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts = posts
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = posts.count
                    
                    
                    // clean up likes for the refetching
                    self.liked.removeAll(keepingCapacity: false)
                    
                    
                    // logic of tracking liked posts
                    for post in posts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                        }
                    }
                    
                    
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
    
    // MARK: - Load More
    // loading more posts from the server via PHP protocol
    func loadMore(offset: Int, limit: Int) {
        
        isLoading = true
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)&action=feed"
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
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts.append(contentsOf: posts)
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip += posts.count
                    
                    
                    // logic of tracking liked posts
                    for post in posts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                        }
                    }
                    
                    
                    // reloading tableView to have an affect - show posts
                    self.tableView.beginUpdates()
                    
                    for i in 0 ..< posts.count {
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
    
    // MARK: - Scroll Did Scroll
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
        let b = -tableView.frame.height
        
        if a > b && isLoading == false {
            loadMore(offset: skip, limit: limit)
        }
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
            let pictureURL = posts[indexPath.row]!["picture"] as! String
        
            let numOfLikes = posts[indexPath.row]!["quantity"] as! String
            
            // no picture in the post
            if pictureURL.isEmpty {
                
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
                
                
//                // manipulating the appearance of the button based is the post has been liken or not
//                DispatchQueue.main.async {
//                    if self.liked[indexPath.row] == 1 {
//                        cell.numberCompleted.text =
//                        //cell.numberCompleted.tintColor = self.likeColor
//                    }
////                        else {
////                        cell.numberCompleted.setImage(UIImage(named: "unlike.png"), for: .normal)
////                        cell.numberCompleted.tintColor = UIColor.darkGray
////                    }
//                }
                
                return cell
                
            // picture in the post
            } else {
                
                // accessing the cell from main.storyboard
                let cell = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
                
                // fullname logic
                let firstName = posts[indexPath.row]!["firstName"] as! String
                let lastName = posts[indexPath.row]!["lastName"] as! String
                cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
                cell.numberComplete.text = numOfLikes
                
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
                
                
                // pictures logic
                let pictureString = posts[indexPath.row]!["picture"] as! String
                let pictureURL = URL(string: pictureString)!
                
                // if there are still pictures to be loaded
                if posts.count != pictures.count {
                    
                    URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.pictures.append(image)
                                
                                DispatchQueue.main.async {
                                    cell.pictureImageView.image = image
                                }
                                
                            }
                            
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.pictures.append(image)
                            
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                            }
                        }
                        
                        }.resume()
                    
                // cached picture
                } else {
                    
                    DispatchQueue.main.async {
                        cell.pictureImageView.image = self.pictures[indexPath.row]
                    }
                }
                
                
                // get the index of the cell in order to get the certain post's id
                cell.numberComplete.tag = indexPath.row
                cell.optionsButton.tag = indexPath.row
                
                
//                // manipulating the appearance of the button based is the post has been liken or not
//                DispatchQueue.main.async {
//                    if self.liked[indexPath.row] == 1 {
//                        cell.likeButton.setImage(UIImage(named: "like.png"), for: .normal)
//                        cell.likeButton.tintColor = self.likeColor
//                    } else {
//                        cell.likeButton.setImage(UIImage(named: "unlike.png"), for: .normal)
//                        cell.likeButton.tintColor = UIColor.darkGray
//                    }
//                }
                
                
                return cell
                
            }
    }

    

}
