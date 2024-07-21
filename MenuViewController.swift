//
//  File.swift
//  What's Cookin'
//
//  Created by Jose Vasquez on 7/20/24.
//
import UIKit

class SidebarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let channels = ["Breakfast", "Lunch", "Dinner", "Baking"]
    var tableView: UITableView!
    var dismissSidebar: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        // Add swipe gesture recognizer
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }

    // Swipe gesture handler
    @objc private func handleSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
        dismissSidebar?()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = channels[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name("ChannelSelected"), object: channels[indexPath.row])
    }
}

