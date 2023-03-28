//
//  AppDelegate.swift
//  ASA Pal
//
//  Created by Vakul Saini on 15/11/21.
//

import UIKit
// We need to have installed firebase SDK
// https://firebase.google.com/docs/ios/setup
import Firebase
import FirebaseDynamicLinks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let shared: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase configuration
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "com.asa.pal"
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // Here should be short url like this
        // https://asavaultpal.page.link/r2ctsf3xCVzNYwvL8
        
        print(userActivity.webpageURL!)
        
        // This Dynamic link should be converted into long deep link with prameters
        // We use firebase sdk to get long url
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { [self] (dynamiclink, error) in
            
            // At thhis point we have long url like this
            // https://asavaultpal.page.link?AsaFintechCode=12345678&AsaConsumerCode=1307480894&FintechName=After+Pay
            // This link should have all needed params for further process
            
            if let linkURL = dynamiclink?.url, let linkParams = linkURL.queryParameters {
                
                self.performDynamicLink(params: linkParams)
                
            }
        }
        
        if !handled {
            // Show the deep link URL from userActivity.
            if let linkURL = userActivity.webpageURL?.absoluteURL, let linkParams = linkURL.queryParameters {
                
                // Already long link
                self.performDynamicLink(params: linkParams)
            }
        }
        return handled
    }
    
    // Deeplink when app is opened at first time after installation
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        
        // Here should be short url like this
        // https://asavaultpal.page.link/r2ctsf3xCVzNYwvL8
        
        print(url)
        
        // This Dynamic link should be converted into long deep link with prameters
        // We use firebase sdk to get long url
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            
            if let linkURL = dynamicLink.url, let linkParams = linkURL.queryParameters {
                self.performDynamicLink(params: linkParams)
            }
            
            return true
        }
        
        return false
    }
    
    func performDynamicLink(params: [String: String]) {
        AppDelegate.shared.saveURLParams(params: params)
        
        // Params which comes from AsaVault
        NSLog("AsaConsumerCode = %@", params["AsaConsumerCode"] ?? "")
        NSLog("AsaFintechCode = %@", params["AsaFintechCode"] ?? "")
        NSLog("FintechName = %@", params["FintechName"] ?? "")

        if let rootViewController = window?.rootViewController as? ViewController {
            rootViewController.callPersonalInfoAPI()
        }
    }
    
}

// MARK:- App Deeplinks
extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

// MARK:- UserDefaults
extension AppDelegate {
    func saveURLParams(params: [String: String]) {
        UserDefaults.standard.setValue(params, forKey: "kLastSavedParams")
    }
    func getURLParams() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: "kLastSavedParams") as? [String: String] ?? [:]
    }
}
