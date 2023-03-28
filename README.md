# MyMoola
This demo app demonstrates how to handle AsaVault dynamic link and which parameters you can expect in your app.
In order to build demo app you need to install dependencies from cocoapods package manager.

Execute this command in project directory. More details here https://cocoapods.org/
```
    pod install
```


# Using Dynamic Links

AsaVault uses Firebase Dynamic Links in order to pass data to other apps.

Quick guide how to config Firebase SDK to receive dynamic link you can find here https://firebase.google.com/docs/dynamic-links/ios/receive. 
You need to do it before going further.


At this point you should have configured project Firebase SDK.

In AppDelegate file as It is in our sample app you can handle AsaVault deeplink in next way.


```
class AppDelegate: UIResponder, UIApplicationDelegate {
    
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
        // Params which comes from AsaVault
        NSLog("AsaConsumerCode = %@", params["AsaConsumerCode"] ?? "")
        NSLog("AsaFintechCode = %@", params["AsaFintechCode"] ?? "")
        NSLog("FintechName = %@", params["FintechName"] ?? "")
    }
    
}
```

# Using ASA OpenApi 

In order to use ASA OpenApi take a look at the file ApiService.swift
You can find here special constants to configure access to ASA shared api.
API_KEY, AUTHORIZATION_KEY, APP_CODE should be filled with valid data.

```
struct APIStaticData {

    static let API_KEY  = "xxxxxxx"
    static let AUTHORIZATION_KEY  = "xxxxxxxx"
    static let APP_CODE  = "xxxx"
    
    static let BASE_URL = "https://openapi.asacore.com"

}
```



