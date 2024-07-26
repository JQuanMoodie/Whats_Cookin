//
//  File.swift
//  What's Cookin'
//
//  Created by Jose Vasquez on 7/20/24.
//
import UIKit

class SidebarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let channels = ["Breakfast", "Lunch", "Dinner", "Dessert"]
    var tableView: UITableView!
    var dismissSidebar: (() -> Void)?

    let profileViewController = ProfileViewController()
    let profileContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        // Set the sidebar's frame to slide halfway
        let screenWidth = UIScreen.main.bounds.width
        let sidebarWidth = screenWidth / 2
        view.frame = CGRect(x: -sidebarWidth, y: 0, width: sidebarWidth, height: UIScreen.main.bounds.height)

        setupProfileView()
        setupTableView()

        // Add swipe gesture recognizer
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        // Add swipe gesture recognizer for opening the sidebar
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    private func setupProfileView() {
        profileContainerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 224)
        profileContainerView.backgroundColor = .lightGray
        
        addChild(profileViewController)
        profileContainerView.addSubview(profileViewController.view)
        profileViewController.view.frame = CGRect(x: 5, y: 5, width: profileContainerView.bounds.width - 10, height: profileContainerView.bounds.height - 10)
        profileViewController.didMove(toParent: self)
        
        view.addSubview(profileContainerView)
        
        // Optionally adjust profile view content for a more compact fit
        profileViewController.profileImageView.layer.cornerRadius = 30
        profileViewController.profileImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        profileViewController.nameLabel.font = .systemFont(ofSize: 16)
        profileViewController.nameLabel.frame = CGRect(x: 80, y: 25, width: profileContainerView.bounds.width - 90, height: 20)
    }

    private func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: profileContainerView.frame.maxY, width: view.bounds.width, height: view.bounds.height - profileContainerView.frame.height))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    // Swipe gesture handler for closing the sidebar
    @objc private func handleSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
        dismissSidebar?()
    }
    
    // Swipe gesture handler for opening the sidebar
    @objc private func handleSwipeRight(_ gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.x = 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = channels[indexPath.row]
        
        // Set the SF Symbol image for the cell
        let imageName: String
        switch channels[indexPath.row] {
        case "Breakfast":
            imageName = "sunrise.fill"
        case "Lunch":
            imageName = "sun.max.fill"
        case "Dinner":
            imageName = "moon.fill"
        case "Dessert":
            imageName = "flame.fill"
        default:
            imageName = "questionmark.circle.fill"
        }
        cell.imageView?.image = UIImage(systemName: imageName)
        
        return cell
    }

  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedChannel = channels[indexPath.row]
            
        if selectedChannel == "Breakfast" {
            let breakfastVC = BreakfastViewController()
            if let navController = navigationController {
                navController.pushViewController(breakfastVC, animated: true)
            } else {
                let navController = UINavigationController(rootViewController: breakfastVC)
                present(navController, animated: true, completion: nil)
            }
            } else if selectedChannel == "Lunch" {
                let lunchVC = LunchViewController()
                if let navController = navigationController {
                    navController.pushViewController(lunchVC, animated: true)
                } else {
                    let navController = UINavigationController(rootViewController: lunchVC)
                    present(navController, animated: true, completion: nil)
                }
            } else if selectedChannel == "Dinner" {
                let dinnerVC = DinnerViewController()
                if let navController = navigationController {
                    navController.pushViewController(dinnerVC, animated: true)
                } else {
                    let navController = UINavigationController(rootViewController: dinnerVC)
                    present(navController, animated: true, completion: nil)
                }
            } else if selectedChannel == "Dessert" {
                let dessertVC = DessertViewController()
                if let navController = navigationController {
                    navController.pushViewController(dessertVC, animated: true)
                } else {
                    let navController = UINavigationController(rootViewController: dessertVC)
                    present(navController, animated: true, completion: nil)
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name("ChannelSelected"), object: selectedChannel)
        }
   }
