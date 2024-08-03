//WebViewController.swift
//8/2/24
//Rachel Wu

import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView: WKWebView!
    var url: URL?

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }
}
