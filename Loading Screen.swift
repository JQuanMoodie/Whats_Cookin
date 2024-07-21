//
//  Loading Screen.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/21/24.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let images = ["burger", "barbeque", "barbeque1"] // Names of the images in Assets.xcassets

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        
        setupConstraints()
        displayRandomImage()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func displayRandomImage() {
        if let randomImageName = images.randomElement() {
            imageView.image = UIImage(named: randomImageName)
        }
    }
    
    // Simulate loading process
    func simulateLoading(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            // Simulate a network delay or loading process
            sleep(3)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
