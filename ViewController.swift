//
//  ViewController.swift
//  IOSTestAssessment
//
//  Created by Shaan Raasti on 06/05/24.
//

import UIKit

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class ViewController:UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "PostCell")
        return table
    }()
    var diff: Double?
    var limit = 20
    var index = 0
    var displayPosts:[Post] = []
    var post_list: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //This function is used to fetch the PostsApi json data,Log the timing  & reload the tableView
    func fetchData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        URLSession.shared.dataTask(with: url) { [self] data, _, error in
            //Log TimeStart
            let start = CFAbsoluteTimeGetCurrent()
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            guard let data = data else { return }
            do {
                let post = try JSONDecoder().decode([Post].self, from: data)
                self.post_list = post
                while index<limit
                {
                    displayPosts.append(post_list[index])
                    index = index + 1
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.diff = CFAbsoluteTimeGetCurrent() - start
                    //Print the LogTime
                    print("LogTime \(self.diff) seconds")
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        let post = displayPosts[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row+1). \(displayPosts[indexPath.row])"
        return cell
    }
    
    //Implemented the Pagination/Infinite Scrolling
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == displayPosts.count-1
        {
            var index = displayPosts.count-1
            if index+20>post_list.count-1
            {
                limit = post_list.count-index
            }
            else
            {
                limit = index + 20
            }
            while index < limit
            {
                displayPosts.append(post_list[index])
                index = index + 1
            }
            self.perform(#selector(loadTable), with: nil, afterDelay: 0.5)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let postSelect = displayPosts[indexPath.row]
        
        let vc = listViewController(posts: displayPosts)
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func loadTable()
    {
        self.tableView.reloadData()
    }
}


