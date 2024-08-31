# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'kyuyo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'FSCalendar'

  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
                 end
            end
     end
  end

  target 'kyuyoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'kyuyoUITests' do
    # Pods for testing
  end

end
