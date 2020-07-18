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
    var limit = 25
    var isLoading = false
    var liked = [Int]()
    
    var lastNames : [String] = []
    
    
    // color obj
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    var refreshing = true
    
//    var postID:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPostsAfterDelete), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(deletePost), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        
        // run function
        loadPosts(offset: skip, limit: limit)
        
//        DispatchQueue.main.async {
//            let lock = DispatchSemaphore(value: 0)
//            // Load any saved meals, otherwise load sample data.
//            self.loadPosts(offset: self.skip, limit: self.limit, completion: {
//                lock.signal()
//            })
//            lock.wait()
//            // finished fetching data
//            self.tableView.reloadData()
//        }
    }
    
    
    
    @objc func refresh(sender:AnyObject)
    {
        refreshing = true
        loadPosts(offset: skip, limit: limit)
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        
        
        
    }
    

    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //loadPosts(offset: skip, limit: limit)
        //tableView.reloadData()
        
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
//        DispatchQueue.main.async {
//            let lock = DispatchSemaphore(value: 0)
//            // Load any saved meals, otherwise load sample data.
//            self.loadPosts(offset: self.skip, limit: self.limit, completion: {
//                lock.signal()
//            })
//            lock.wait()
//            // finished fetching data
//            self.tableView.reloadData()
//        }
        //tableView.reloadData()
        
        
    }
    
    @objc func test() {
        loadPosts(offset: skip, limit: limit)
    }
    
    // MARK: - Load Posts
    // loading posts from the server via@objc  PHP protocol
    @objc func loadPosts(offset: Int, limit: Int) {
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
                        self.lastNames.append(post["lastName"] as! String)
                    }
                    
                    print("Loaded----------------------------------------------------------")
                    // reloading tableView to have an affect - show posts
                    self.tableView.reloadData()
                    
                    self.isLoading = false
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    self.isLoading = false
                    print("JSON ERROR----------------------------------------------------------------------------")
                    return
                }
                
            }
            //completion!()
        }.resume()
        //self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Load New
    // exec-d when new post is published
        @objc func loadNewPosts() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts(offset: 0, limit: skip + 1)
    //        DispatchQueue.global().async {
    //            let lock = DispatchSemaphore(value: 0)
    //            // Load any saved meals, otherwise load sample data.
    //            self.loadPosts(offset: self.skip, limit: self.limit, completion: {
    //                lock.signal()
    //            })
    //            lock.wait()
    //            // finished fetching data
    //        }
        }
    // MARK: - Load Delete
    @objc func loadPostsAfterDelete() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts(offset: 0, limit: skip - 1)
    
        }
    
    // MARK: - Load Ava
    @objc func loadAvaAfterUpload() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts(offset: 0, limit: skip - 1 + 1)
    
        }
    
    // MARK: - Load More
    // loading more posts from the server via PHP protocol
    @objc func loadMore(offset: Int, limit: Int) {
        
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
                    print("End updates --------------------------------------------------------")
                    self.isLoading = false
                    
                } catch {
                    self.isLoading = false
                    return
                }
                
            }
            //completion!()
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

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
                
                if(currentUser?["lastName"] as! String == posts[indexPath.row]!["lastName"] as! String) {
                    cell.avaImageView.image = currentUser_ava
                    let avaString = posts[indexPath.row]!["ava"] as! String
                    Helper().downloadImage(from: avaString, showIn: cell.avaImageView, orShow: "user.png")
                } else {
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
                            //cell.avaImageView.image = currentUser_ava
                        }
                    }
                }
                
                
                
                // picture logic
                pictures.append(UIImage())
                
                // get the index of the cell in order to get the certain post's id
                cell.numberCompleted.tag = indexPath.row
                cell.optionsButton.tag = indexPath.row
                
                

                
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
                
                
                if(currentUser?["lastName"] as! String == posts[indexPath.row]!["lastName"] as! String) {
                    cell.avaImageView.image = currentUser_ava
                    let avaString = posts[indexPath.row]!["ava"] as! String
                    Helper().downloadImage(from: avaString, showIn: cell.avaImageView, orShow: "user.png")
                } else {
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
                            //cell.avaImageView.image = currentUser_ava
                        }
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
                
                return cell
            }
    }
    // MARK: - WillDisplayCell
    // exec-d whenever new cell is to be displayed
           override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
               
               
               // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
               let pictureURL = posts[indexPath.row]!["picture"] as! String
               
               // no picture in the post
               if pictureURL.isEmpty {
                   
                   
                   // accessing the cell from main.storyboard
                   let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
                   
                   
                   // fullname logic
                   let firstName = posts[indexPath.row]!["firstName"] as! String
                   let lastName = posts[indexPath.row]!["lastName"] as! String
                   cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
                   
                   
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
                   
                   if(currentUser?["lastName"] as! String == posts[indexPath.row]!["lastName"] as! String) {
                      cell.avaImageView.image = currentUser_ava
                      let avaString = posts[indexPath.row]!["ava"] as! String
                      Helper().downloadImage(from: avaString, showIn: cell.avaImageView, orShow: "user.png")
                  } else {
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
                              //cell.avaImageView.image = currentUser_ava
                          }
                      }
                  }
                   
                   
                   // picture logic
                   pictures.append(UIImage())
                   
                   // get the index of the cell in order to get the certain post's id
                   cell.numberCompleted.tag = indexPath.row
                
                   //cell.commentsButton.tag = indexPath.row
                   cell.optionsButton.tag = indexPath.row
                   

        
               // picture in the post
               } else {
                   
                   // accessing the cell from main.storyboard
                   let cell = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
                   
                   // fullname logic
                   let firstName = posts[indexPath.row]!["firstName"] as! String
                   let lastName = posts[indexPath.row]!["lastName"] as! String
                   cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
                   
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
                   
                    if(currentUser?["lastName"] as! String == posts[indexPath.row]!["lastName"] as! String) {
                      cell.avaImageView.image = currentUser_ava
                      let avaString = posts[indexPath.row]!["ava"] as! String
                      Helper().downloadImage(from: avaString, showIn: cell.avaImageView, orShow: "user.png")
                  } else {
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
                              //cell.avaImageView.image = currentUser_ava
                          }
                      }
                  }
                   
                   // pictures logic
                   // avas logic
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
                   //cell.commentsButton.tag = indexPath.row
                   cell.optionsButton.tag = indexPath.row
                   
                   
                   
               }
               
           }

    

}
