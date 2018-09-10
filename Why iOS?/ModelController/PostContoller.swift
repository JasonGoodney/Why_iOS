//
//  PostContoller.swift
//  Why iOS?
//
//  Created by Jason Goodney on 9/5/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import Foundation

class PostController {
    
    private enum HttpMethod: String {
        case GET
        case POST
        case PUT
    }
    
    var posts: [Post] = []
    let baseURL = URL(string: "https://whydidyouchooseios.firebaseio.com/reasons")
    
    func putPost(name: String, reason: String, completion: @escaping (Bool) -> Void) {
        let post = Post(name: name, reason: reason)
        guard let url = baseURL else {fatalError("bad baseURL")}
        let builtURL = url.appendingPathComponent(post.uuid).appendingPathExtension("json")
        var request = URLRequest(url: builtURL)
        
        let jsonEncoder = JSONEncoder()
        do{
            let data = try jsonEncoder.encode(post)
            request.httpMethod = "PUT"
            request.httpBody = data
        }catch let error {
            print("🤮 Error putting with data task: \(error) \(error.localizedDescription)")
            completion(false); return
        }

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print("PUT request error \(error) \(error.localizedDescription)")
            }
            
            guard let data = data,
                let responseData = String(data: data, encoding: .utf8)
                else {
                    print("responseData error")
                    completion(false); return
                }
            print(responseData)
            self.posts.append(post)
            completion(true)
        }.resume()
    }
    
    func fetchPosts(completion: @escaping (_ success: Bool) -> Void) {
     
        guard let url = baseURL?.appendingPathExtension("json") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.GET.rawValue
        request.httpBody = nil
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            do {
                if let error = error { throw error }
                guard let data = data
                    else { print("Bad request data"); completion(false); return }
                
                let postsDictionary = try JSONDecoder().decode([String : Post].self, from: data)
                self.posts = postsDictionary.compactMap({ $0.value })
                completion(true); return
            } catch let error {
                print("😳\nThere was an error in \(#function): \(error)\n\n\(error.localizedDescription)\n👿")
                completion(false); return
            }
        }.resume()
    }
}



























