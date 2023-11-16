//
//  BannoPluginVC.swift
//  ASA Pal
//
//  Created by Hrybeniuk Mykola on 02.11.2023.
//

import UIKit
import WebKit

final class BannoPluginVC: UIViewController, WKNavigationDelegate {
    
    let webView: WKWebView = .init(frame: .zero)
    let topView: UIStackView = .init(arrangedSubviews: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.backgroundColor = .lightGray
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.axis = .horizontal
        topView.spacing = 4.0
        topView.alignment = .center
        view.addSubview(topView)
        
        let textColor = UIColor.init(red: 0.0, green: 209.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        
        let refreshBt = UIButton(configuration: .plain(), primaryAction: .init(title: "Refresh", handler: { [weak self] item in
            self?.webView.reload()
        }))
        
        refreshBt.setTitleColor(textColor, for: .normal)
        refreshBt.translatesAutoresizingMaskIntoConstraints = false
        
        topView.addArrangedSubview(refreshBt)
        let spacer = UITextField()
        spacer.borderStyle = .roundedRect
        spacer.text = "https://bannodev.asacore.com/"
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.returnKeyType = .search
        spacer.delegate = self
        topView.addArrangedSubview(spacer)
        
        let closeBt = UIButton(configuration: .plain(), primaryAction: .init(title: "Close", handler: { [weak self] item in
            self?.dismiss(animated: true)
        }))
        closeBt.translatesAutoresizingMaskIntoConstraints = false
        closeBt.setTitleColor(textColor, for: .normal)
        topView.addArrangedSubview(closeBt)
        
        
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: 60),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeBt.widthAnchor.constraint(equalToConstant: 90),
            refreshBt.widthAnchor.constraint(equalToConstant: 90),
            spacer.heightAnchor.constraint(equalToConstant: 35),
            webView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let myURL = URL(string:"https://bannodev.asacore.com/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
}

extension BannoPluginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let myURL = URL(string:textField.text ?? "" ) {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        }
        return true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertVC.addAction(.init(title: "Ok", style: .cancel))
        present(alertVC, animated: true)
    }
}
