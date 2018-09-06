//
//  PostListViewController.swift
//  Why iOS?
//
//  Created by Jason Goodney on 9/5/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    // MARK: - Properties
    let postController = PostController()
    private let teamId = "T039C2PUY"
    private let channelId = "CBTL98EN7"
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.register(UITableViewCell.self, forCellReuseIdentifier: "postCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()
    
    lazy var addPostButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.setTitle("No posts found ☹️.\nTap to create one!", for: .normal)
        view.setTitleColor(.lightGray, for: .normal)
        view.addTarget(self, action: #selector(addPostButtonTapped(_:)), for: .touchUpInside)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        view.titleLabel?.numberOfLines = 2
        view.titleLabel?.textAlignment = .center
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        performFetch()
    }
}

// MARK: - Update View
private extension PostListViewController {
    func updateView() {
        [tableView, addPostButton].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        setupConstraints()
        setupNavigationBar()
        setupRefreshControl()
        
        view.bringSubview(toFront: addPostButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addPostButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            addPostButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            addPostButton.topAnchor.constraint(equalTo: view.topAnchor),
            addPostButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func emptyState(isEmpty: Bool) {
        tableView.isHidden = isEmpty
        isEmpty ? (addPostButton.isHidden = false) : (addPostButton.isHidden = true)
    }
    
    func setupNavigationBar() {
        title = "Why 📱⁉️"
        let addPostBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddPost))
        navigationItem.rightBarButtonItem = addPostBarButtonItem
        let slackImage = UIImage(named: "slack")?.withRenderingMode(.alwaysOriginal)
        let openSlackBarButtonItem = UIBarButtonItem(image: slackImage, style: .plain, target: self, action: #selector(openSlackButtonTapped(_:)))
        navigationItem.leftBarButtonItem = openSlackBarButtonItem
    }
    
    func setupRefreshControl() {
        tableView.refreshControl = refreshControl
    }
}

// MARK: - Fetch Performer
private extension PostListViewController {
    func performFetch() {
        self.refreshControl.beginRefreshing()
        postController.fetchPosts { (success) in
            
            if success {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.emptyState(isEmpty: false)
                }
            } else {
                DispatchQueue.main.async {
                    self.emptyState(isEmpty: true)
                }
            }
        }
    }
}

// MARK: - Actions
private extension PostListViewController {
    @objc func openSlackButtonTapped(_ sender: UIBarButtonItem) {
        openSlack(teamId: teamId, channelId: channelId, userId: nil)
    }
    
    @objc func addPostButtonTapped(_ sender: UIButton) {
      
        presentAddPost()
    }
    
    @objc func presentAddPost() {
        let alert = UIAlertController(title: "Why iOS?", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Reason"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let reason = alert.textFields?[0].text, !reason.isEmpty,
                let name = alert.textFields?[1].text, !name.isEmpty else { return }

            self.postController.putPost(name: name, reason: reason, completion: { (success) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [submitAction, cancelAction].forEach({ alert.addAction($0) })
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func openSlack(teamId: String, channelId: String?, userId: String?) {
        var slackHook = ""
        if let channelId = channelId {
            slackHook = "slack://channel?team=\(teamId)&id=\(channelId)"
        } else if let userId = userId {
            slackHook = "slack://user?team=\(teamId)&id=\(userId)"
        }
        guard let slackURL = URL(string: slackHook) else { return }
        
        if UIApplication.shared.canOpenURL(slackURL)
        {
            UIApplication.shared.open(slackURL, options: [:], completionHandler: nil)
            
        } else {
            print("Slack not on device")
        }
    }
}

// MARK: - UITableViewDataSource
extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "postCell")
        
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.reason
        cell.detailTextLabel?.text = post.name
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = postController.posts[indexPath.row]
        
    }
}
