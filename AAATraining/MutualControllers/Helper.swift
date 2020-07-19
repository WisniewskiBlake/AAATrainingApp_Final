//
//  Helper.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/19/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit



class Helper {
    
    
    // validate email address function / logic
    func isValid(email: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: email)
        
        return result
    }
    
    
    // validate name function / logic
    func isValid(name: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: name)
        
        return result
    }
    
    // validate name function / logic
    func isValid(position: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "^[a-zA-Z ]*${2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: position)
        
        return result
    }
    
    // validate name function / logic
    func isValid(number: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "[0-9]{1,3}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: number)
        
        return result
    }
    
    func isValid(weight: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "[0-9]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: weight)
        
        return result
    }
    
    func isValid(height: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "[0-9]{2,2}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: height)
        
        return result
    }
    
        // show alert message to the user
    func showAlert(title: String, message: String, in vc: UIViewController) {
        
        // creating alertController; creating button to the alertController; assigning button to alertController; presenting alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)        
    }
    
    // allows us to go to another ViewController programmatically
    func instantiateViewController(identifier: String, animated: Bool, by vc: UIViewController, completion: (() -> Void)?) {
        
        // accessing any ViewController from Main.storyboard via ID
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        // presenting accessed ViewController
        vc.present(newViewController, animated: animated, completion: completion)
    }
    
    // MIME for the Image
    func body(with parameters: [String: Any]?, filename: String, filePathKey: String?, imageDataKey: Data, boundary: String) -> NSData {
        
        let body = NSMutableData()
        // MIME Type for Parameters [id: 777, name: michael]
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        // MIME Type for Image
        let mimetype = "image/jpg"
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        
        body.append(imageDataKey)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
    
    // allows us to download the image from certain url string
    func downloadImage(from path: String, showIn imageView: UIImageView, orShow placeholder: String) {
        
        // if avaPath string is having a valid url, IT'S NOT EMPTY (e.g. if ava isn't assigned, than in DB the link is stored as blank string)
        if String(describing: path).isEmpty == false {
            DispatchQueue.main.async {
                
                // converting url string to the valid URL
                if let url = URL(string: path) {
                    
                    // downloading all data from the URL
                    guard let data = try? Data(contentsOf: url) else {
                        imageView.image = UIImage(named: placeholder)
                        return
                    }
                    
                    // converting donwloaded data to the image
                    guard let image = UIImage(data: data) else {
                        imageView.image = UIImage(named: placeholder)
                        return
                    }
                    
                    // assigning image to the imageView
                    imageView.image = image
                    
                }
            }
        }
    }
    
    // configure appearance of the fullname & fullname label
    func loadFullname(firstName: String, lastName: String, showIn label: UILabel) {
        DispatchQueue.main.async {
            label.text = "\(firstName.capitalized) \(lastName.capitalized)"
        }
    }
    
    // sends HTTP requests and return JSON results
    func sendHTTPRequest(url: String, body: String, success: @escaping () -> Void, failure: @escaping () -> Void) -> NSDictionary {
        
        // var to be returned
        var result = NSDictionary()
        
        // prerparing request
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // errors
                if error != nil {
                    failure()
                    return
                }
                
                do {
                    // casting data received from the server
                    guard let data = data else {
                        failure()
                        return
                    }
                    
                    // casting json from data
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // safe mode of accessing json
                    guard let parsedJSON = json else {
                        failure()
                        return
                    }
                    
                    // completionHandler. This can be customized whenever this func is called from any other swift classes / files
                    if parsedJSON["status"] as! String == "200" {
                        success()
                    } else {
                        failure()
                    }
                    
                    // assigning json data to the result var to be returned with the func
                    result = parsedJSON
                    
                } catch {
                    failure()
                    return
                }
                
            }
        }.resume()
        
        // reutrning json
        return result
        
    }
    
    
}