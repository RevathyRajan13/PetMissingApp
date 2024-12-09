# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PetMissingApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PetMissingApp

    pod 'IQKeyboardManagerSwift'
    pod 'DropDown'
    pod 'Toast-Swift', '~> 5.0.1'
    
    
    # Firebase
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Messaging'
    pod 'Firebase/Storage'
    pod 'Firebase/Firestore'


  target 'PetMissingAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PetMissingAppUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              end
          end
      end
  end

end
