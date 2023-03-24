# Uncomment the next line to define a global platform for your project
platform :ios, '13.6'

target 'ASA Pal' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ASA Pal
  
    pod 'Alamofire'

    # Firebase
    # Recommended: Add the Firebase pod for Google Analytics
    pod 'Firebase/Analytics'
    pod 'Firebase/DynamicLinks'
    pod 'Firebase/Performance'

end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.6'
  end
 end
end
