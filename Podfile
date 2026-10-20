platform :ios, '15.0'

target 'Image Search' do
  use_frameworks!

  # Pods for Image Search
  pod 'TOCropViewController', :git => 'https://github.com/DanielHusiuk/TOCropViewController.git', :branch => 'main'
  pod 'netfox', :configurations => ['Debug']

  target 'Image SearchTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Image SearchUITests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
  end
end
